extends EBBCodeParser
class_name MarkdownParser

# Markdown Parser
# With support for <values> and :emojis:
# For emojis you need to install emojis-for-godot

func parse(text:String, editor:=false, headers_fonts :=[], variables:={}) -> String:
	# run base.parse
	text = convert_markdown(text)
	text = .parse(text, editor, headers_fonts, variables)
	return text

func convert_markdown(text:String) -> String:
	var re = RegEx.new()
	var output = "" + text
	var replacement = ""
	
	# ![](path/to/img)
	re.compile("!\u200B?\\[\u200B?\\]\\(([^\\(\\)\\[\\]]+)\\)")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[img]%s[/img]" % result.get_string(1)
			output = regex_replace(result, output, replacement)
	text = output

	# either plain "prot://url" and "[link](url)" and not "[img]url[\img]"
	re.compile("(\\[img\\][^\\[\\]]*\\[\\/img\\])|(?:(?:\\[([^\\]\\)]+)\\]\\((\\w+:\\/\\/[^\\)]+)\\))|(\\w+:\\/\\/[^ \\[\\]]*[\\w\\d_]+))")

	for result in re.search_all(text):
		# having anything in 1 meant it matched "[img]url[\img]"
		if result.get_string() and not result.get_string(1): 
			if result.get_string(4):
				replacement = "[url]%s[/url]" % result.get_string(4)
			else:
				# That can can be the user erroneously writing "[b](url)[\b]" need to be pointed in the doc
				replacement = "[url=%s]%s[/url]" % [result.get_string(3), result.get_string(2)]
			output = regex_replace(result, output, replacement)
	text = output

	# **bold**
	re.compile("\\*\\*([^\\*]+)\\*\\*")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[b]%s[/b]" % result.get_string(1)
			output = regex_replace(result, output, replacement)
	text = output
	
	# *italic*
	re.compile("\\*([^\\*]+)\\*")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[i]%s[/i]" % result.get_string(1)
			output = regex_replace(result, output, replacement)
	text = output

	# ~~strike through~~
	re.compile("~~([^~]+)~~")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[s]%s[/s]" % result.get_string(1)
			output = regex_replace(result, output, replacement)
	text = output

	# `code`
	re.compile("`([^`]+)`")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[code]%s[/code]" % result.get_string(1)
			output = regex_replace(result, output, replacement)
	text = output

	# @tabel=2 {
	# | cell1 | cell2 |
	# }
	re.compile("@table=([0-9]+)\\s*\\{\\s*((\\|.+)\n)+\\}")
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[table=%s]" % result.get_string(1)
			# cell 1 | cell 2
			var r = result.get_string()
			var lines = r.split("\n")
			for line in lines:
				if line.begins_with("|"):
					var cells : Array = line.split("|", false)
					for cell in cells:
						replacement += "[cell]%s[/cell]" % cell
					replacement += "\n"
			replacement += "[/table]"
			output = regex_replace(result, output, replacement)
	text = output

	# @center { text }
	text = parse_keyword(text, "center", "center")

	# @u { text}
	text = parse_keyword(text, "u", "u")

	# @right { text }
	text = parse_keyword(text, "right", "right")

	# @fill { text }
	text = parse_keyword(text, "fill", "fill")

	# @indent { text }
	text = parse_keyword(text, "indent", "indent")

	
	return text

func parse_keyword(text:String, keyword:String, tag:String) -> String:
	var re = RegEx.new()
	var output = "" + text
	var replacement = ""

	# @keyword {text}
	re.compile("@%s\\s*\\{([^\\}]+)\\}" % keyword)
	for result in re.search_all(text):
		if result.get_string():
			replacement = "[%s]%s[/%s]" % [tag, result.get_string(1), tag]
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
