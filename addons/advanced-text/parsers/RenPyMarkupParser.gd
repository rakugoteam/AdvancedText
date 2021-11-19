extends EBBCodeParser
class_name RenPyMarkupParser

# RenPy Markup Parser
# Adds support for :emojis:
# For emojis you need to install emojis-for-godot

func parse(text:String, editor:=false, headers_fonts:=[], variables:={}) -> String:
	text = convert_renpy_markup(text)
	return .parse(text, editor, headers_fonts, variables)

func replace_variables(text:String, editor:=false, open:="[", close:="]") -> String:
	return .replace_variables(text, editor, open, close)

func convert_renpy_markup(text:String) -> String:
	var re = RegEx.new()
	var output = "" + text
	var replacement = ""
	
	# match unescaped "{a=" and "{/a}"
	re.compile("(?<!\\{)\\{(\\/{0,1})a(?:(=[^\\}]+)\\}|\\})")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[" + result.get_string(1) + "url" + result.get_string(2) + "]"
			output = regex_replace(result, output, replacement)
	text = output
	
	# match unescaped "{img=<path>}"
	re.compile("(?<!\\{)\\{img=([^\\}]+)\\}")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[img]" + result.get_string(1) + "[/img]"
			output = regex_replace(result, output, replacement)
	text = output
	
	# math "}" part of a valid tag
	re.compile("(?:(?<!\\{)\\{[^\\{\\}]+)(\\})")
	for result in re.search_all(text):
		if result.get_string():
			output = regex_replace(result, output, "]", 1)
	text = output
	
	# match unescaped "{"
	re.compile("(?<!\\{)\\{(?!\\{)")
	for result in re.search_all(text):
		if result.get_string():
			output = regex_replace(result, output, "[")
	text = output
	
	# match escaped braces "{{" transform them into "{"
	re.compile("([\\{]+)")
	for result in re.search_all(text):
		if result.get_string():
			output = regex_replace(result, output, "{")
	text = output

	return text
