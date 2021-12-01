tool
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

func parse(text:String, headers_fonts:=[], variables:={}) -> String:

	# Parse headers
	text = parse_headers(text, headers_fonts)

	if !variables.empty():
		text = replace_variables(text, variables)
	
	# prints("emojis_gd:", emojis_gd)
	if emojis_gd:
		text = emojis_gd.parse_emojis(text)
		
	return text

func replace_variables(text:String, variables:Dictionary) -> String:
	text = text.format(variables, "<_>")

	for k in variables.keys():
		if variables[k] is Dictionary:
			text = parse_variable(text, k, variables[k])

		if variables[k] is Array:
			text = parse_variable(text, k, variables[k])

		if variables[k] is String:
			text = parse_variable(text, k, variables[k])

	return text

func parse_variable(text:String, variable:String, value) -> String:
	var re = RegEx.new()
	var output = "" + text

	re.compile("<(" + variable + ".*?)>")
	for result in re.search_all(text):
		if result.get_string():
			if "." in result.get_string(1):
				var parts = result.get_string(1).split(".")
				var key = parts[1]
				var _value = value[key]

				# if parts.size() > 2:
				# 	return parse_variable(text, , va)
				
				output = regex_replace(result, output, str(_value))
			
			if "[" in result.get_string():
				if "]" in result.get_string():
					var parts = result.get_string().split("[")
					var index = int(parts[1].split("]")[0])
					var _value = value[index]
					# if parts.size() > 2:
					# 	return parse_variable(text, variable + "[" + index + "]", _value)

					output = regex_replace(result, output, str(_value))

	return output


func regex_replace(result:RegExMatch, output:String, replacement:String, string_to_replace=0) -> String:
	var offset = output.length() - result.subject.length()
	var left = output.left(result.get_start(string_to_replace) + offset)
	var right = output.right(result.get_end(string_to_replace) + offset)
	return left + replacement + right

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
