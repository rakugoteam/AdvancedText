extends Object
class_name EBBCodeParser

# Extended BBCode Parser
# Adds support for <values> and :emojis:
# For emojis you need to install emojis-for-godot

var EmojisImport
var emojis_gd

func _init():
	EmojisImport = preload("../emojis_import.gd")
	EmojisImport = EmojisImport.new()
	emojis_gd = EmojisImport.get_emojis()

func parse(text:String, editor:=false, headers_fonts:=[], variables:={}) -> String:

	# Parse headers
	text = parse_headers(text, headers_fonts)

	if !variables.empty():
		text = replace_variables(text, editor, variables)
	
	# prints("emojis_gd:", emojis_gd)
	if emojis_gd:
		text = emojis_gd.parse_emojis(text)
		
	return text

func replace_variables(text:String, editor:bool, variables:Dictionary, open:="<", close:=">") -> String:
	var re = RegEx.new()
	var output = "" + text
	var replacement = ""
	
	re.compile("%s([\\w.]+)%s" % [open, close])
	for result in re.search_all(text):
		if result.get_string():
			
			# if !editor:
			replacement = str(get_variable(result.get_string(1), variables))
			# else:
			# 	replacement = "[code]%s[/code]" % result.get_string(1)

			output = regex_replace(result, output, replacement)
	
	return output

func regex_replace(result:RegExMatch, output:String, replacement:String, string_to_replace=0) -> String:
	var offset = output.length() - result.subject.length()
	var left = output.left(result.get_start(string_to_replace) + offset)
	var right = output.right(result.get_end(string_to_replace) + offset)
	return left + replacement + right 

func get_variable(var_name:String, variables:Dictionary) -> String:
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

func parse_headers(text:String, headers_fonts:Array) -> String:
	var headers_count = headers_fonts.size()
	
	if headers_count == 0:
		return text
	
	var re = RegEx.new()
	var output = "" + text

	re.compile("\\[h([1-4])\\](.+)\\[/h[1-4]\\]")
	for result in re.search_all(text):
		if result.get_string():
			var header_level = headers_count - int(result.get_string(1))
			header_level = clamp(header_level, 0, headers_count - 1)
			var header_text = result.get_string(2)
			var header_font = headers_fonts[header_level]
			var replacement = "[font=%s]%s[/font]" % [header_font, header_text]
			output = regex_replace(result, output, replacement)
	
	return output
