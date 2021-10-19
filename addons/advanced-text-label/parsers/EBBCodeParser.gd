extends Node
class_name EBBCodeParser

# Extended BBCode Parser
# Adds support for <values> and :emojis:
# For emojis you need to install emojis-for-godot

var f := File.new()
var _emojis
const emoji_path = "res://addons/emojis-for-godot/emojis/emojis.gd"

func get_emojis():
	if _emojis:
		return _emojis

	if f.file_exists(emoji_path):
		_emojis = load(emoji_path)
		_emojis = _emojis.new()
		return _emojis

	else:
		push_warning("Emojis not found")
		return null

func parse(text:String, editor:=false, variables:={}) -> String:
	text = dirty_escaping(text)

	if !editor and !variables.empty():
		text = replace_variables(text, editor)
	
	var emojis = get_emojis()
	if emojis:
		text = emojis.parse_emojis(text)
		
	return text

func dirty_escaping(text:String) -> String:
	var re = RegEx.new()
	var output = "" + text
	
	re.compile("(\\\\)(.)")
	for result in re.search_all(text):
		if result.get_string():
			output = regex_replace(result, output, "\u200B" + result.get_string(2) + "\u200B")
	
	return output

func replace_variables(text:String, editor:=false) -> String:
	var re = RegEx.new()
	var output = "" + text
	var replacement = ""
	
	re.compile("<([\\w.]+)>")
	for result in re.search_all(text):
		if result.get_string():
			
			if editor:
				replacement = str(get_variable(result.get_string(1)))
			else:
				replacement = "[code]" + result.get_string(1) + "[/code]"

			output = regex_replace(result, output, replacement)
	
	return output

func regex_replace(result:RegExMatch, output:String, replacement:String, string_to_replace=0) -> String:
	var offset = output.length() - result.subject.length()
	var left = output.left(result.get_start(string_to_replace) + offset)
	var right = output.right(result.get_end(string_to_replace) + offset)
	return left + replacement + right 

func get_variable(var_name:String, variables:={}):
	var parts = var_name.split('.', false)
	
	var output = variables
	var i = 0
	var error = false
	while output and i < parts.size():
		output = output.get(parts[i])
		i += 1
		if not output:
			error = true
			push_warning("The variable '%s' does not exist." % var_name)
	if error:
		output = null
	return output
