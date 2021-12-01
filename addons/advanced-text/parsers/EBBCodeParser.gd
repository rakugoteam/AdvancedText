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

func replace_variables(text:String, variables:Dictionary, placeholder := "<_>") -> String:
	var variables_array = []
	for k in variables.keys():
		variables_array.append([k, variables[k]])

		if variables[k] is Dictionary:
			for k2 in variables[k].keys():
				variables_array.append([k + "." + k2, variables[k][k2]])

		if variables[k] is Array:
			for i in range(0, variables[k].size()):
				variables_array.append([k + "[" + str(i) + "]", variables[k][i]])

	return text.format(variables_array, placeholder)

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
