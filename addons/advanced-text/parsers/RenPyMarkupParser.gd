extends EBBCodeParser
class_name RenPyMarkupParser

# RenPy Markup Parser
# Adds support for :emojis:
# For emojis you need to install emojis-for-godot

func parse(text:String, editor:=false, headers_fonts:=[], variables:={}) -> String:
	text = convert_renpy_markup(text)
	text = .parse(text, editor, headers_fonts, variables)
	return text

func replace_variables(text:String, editor:=false, open:="[", close:="]") -> String:
	return .replace_variables(text, editor, open, close)

func convert_renpy_markup(text:String) -> String:
	var re = RegEx.new()
	var output = "" + text
	var replacement = ""
	
	re.compile("(?<!\\{)\\{(\\/{0,1})a(?:(=[^\\}]+)\\}|\\})")# match unescaped "{a=" and "{/a}"
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[" + result.get_string(1) + "url" + result.get_string(2) + "]"
			output = regex_replace(result, output, replacement)
	text = output
	
	re.compile("(?<!\\{)\\{img=([^\\}]+)\\}")# match unescaped "{img=<path>}"
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[img]" + result.get_string(1) + "[/img]"
			output = regex_replace(result, output, replacement)
	text = output
	
	re.compile("(?:(?<!\\{)\\{[^\\{\\}]+)(\\})")# math "}" part of a valid tag
	for result in re.search_all(text):
		if result.get_string():
			output = regex_replace(result, output, "]", 1)
	text = output
	
	re.compile("(?<!\\{)\\{(?!\\{)")# match unescaped "{"
	for result in re.search_all(text):
		if result.get_string():
			output = regex_replace(result, output, "[")
	text = output
	
	re.compile("([\\{]+)")# match escaped braces "{{" transform them into "{"
	for result in re.search_all(text):
		if result.get_string():
			output = regex_replace(result, output, "{")
	text = output

	return text
