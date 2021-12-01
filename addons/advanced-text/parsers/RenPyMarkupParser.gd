tool
extends EBBCodeParser
class_name RenPyMarkupParser

# RenPy Markup Parser
# Adds support for :emojis:
# For emojis you need to install emojis-for-godot

func parse(text:String, headers_fonts:=[], variables:={}) -> String:
	text = convert_renpy_markup(text)
	text = .parse(text, headers_fonts, variables)
	return text

func replace_variables(text:String, variables:Dictionary) -> String:
	return .replace_variables(text, variables)

func convert_renpy_markup(text:String) -> String:
	var re = RegEx.new()
	var output = "" + text
	var replacement = ""
	
	# match unescaped "{a=" and "{/a}"
	re.compile("(?<!\\{)\\{(\\/{0,1})a(?:(=[^\\}]+)\\}|\\})")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[%surl%s]" % [result.get_string(1), result.get_string(2)]
			output = regex_replace(result, output, replacement)
	text = output
	
	# match unescaped "{img=<path>}"
	re.compile("(?<!\\{)\\{img=([^\\}\\s]+)\\}")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[img]%s[/img]" % result.get_string(1)
			output = regex_replace(result, output, replacement)
	text = output

	# match unescaped "{img=<path> size=<height>x<width>}"
	re.compile("(?<!\\{)\\{img=([^\\}\\s]+) size=([^\\}]+)\\}")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[img=%s]%s[/img]" % [result.get_string(2), result.get_string(1)]
			output = regex_replace(result, output, replacement)
	
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
