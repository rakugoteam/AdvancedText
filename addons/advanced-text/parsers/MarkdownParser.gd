extends EBBCodeParser
class_name MarkdownParser

# Markdown Parser
# With support for <values> and :emojis:
# For emojis you need to install emojis-for-godot

func parse(text:String, editor:=false, headers_fonts :=[], variables:={}) -> String:
	# run base.parse
	text = convert_markdown(text)
	return .parse(text, editor, headers_fonts, variables)

func convert_markdown(text:String) -> String:
	var re = RegEx.new()
	var output = "" + text
	var replacement = ""
	
	# ![](path/to/img)
	re.compile("!\u200B?\\[\u200B?\\]\\(([^\\(\\)\\[\\]]+)\\)")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[img]" + result.get_string(1) + "[/img]"
			output = regex_replace(result, output, replacement)
	text = output

	# either plain "prot://url" and "[link](url)" and not "[img]url[\img]"
	re.compile("(\\[img\\][^\\[\\]]*\\[\\/img\\])|(?:(?:\\[([^\\]\\)]+)\\]\\(([a-zA-Z]+:\\/\\/[^\\)]+)\\))|([a-zA-Z]+:\\/\\/[^ \\[\\]]*[a-zA-Z0-9_]))")

	for result in re.search_all(text):
		# having anything in 1 meant it matched "[img]url[\img]"
		if result.get_string() and not result.get_string(1): 
			if result.get_string(4):
				replacement = "[url]" + result.get_string(4) + "[/url]"
			else:
				# That can can be the user erroneously writing "[b](url)[\b]" need to be pointed in the doc
				replacement = "[url=" + result.get_string(3) + "]" + result.get_string(2) + "[/url]"
			output = regex_replace(result, output, replacement)
	text = output

	# **bold**
	re.compile("\\*\\*([^\\*]+)\\*\\*")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[b]" + result.get_string(1) + "[/b]"
			output = regex_replace(result, output, replacement)
	text = output
	
	# *italic*
	re.compile("\\*([^\\*]+)\\*")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[i]" + result.get_string(1) + "[/i]"
			output = regex_replace(result, output, replacement)
	text = output

	# ~~strike through~~
	re.compile("~~([^~]+)~~")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[s]" + result.get_string(1) + "[/s]"
			output = regex_replace(result, output, replacement)
	text = output

	# `code`
	re.compile("`([^`]+)`")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[code]" + result.get_string(1) + "[/code]"
			output = regex_replace(result, output, replacement)
	text = output

	return text

func parse_headers(text:String, headers_fonts:=[]) -> String:
	var headers_count = headers_fonts.size()

	if headers_count == 0:
		return text

	var re = RegEx.new()
	var output = "" + text

	re.compile("(#+)\\s+(.+)\n")
	for result in re.search_all(text):
		if result.get_string():
			var header_level = headers_count - result.get_string(1).length()
			header_level = clamp(header_level, 0, headers_count)
			var header_text = result.get_string(2)
			var header_font = headers_fonts[header_level]
			var replacement = "[font=%s]%s[/font]\n" % [header_font, header_text]
			output = regex_replace(result, output, replacement)
	
	return output
