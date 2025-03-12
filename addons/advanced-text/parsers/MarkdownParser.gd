@tool
@icon("res://addons/advanced-text/icons/md.svg")

## This parser is every limited as its just translates Markdown to BBCode,
## adds support for add Rakugo variables with <var_name>
## and Headers "#" and support for IconsFonts
## @tutorial: https://rakugoteam.github.io/advanced-text-docs/2.3/MarkdownParser/
class_name MarkdownParser
extends ExtendedBBCodeParser

## choose to use * or _ to open/close italics tag
@export_enum("both", "*", "_") var italics = "both"

## choose to use * or _ to open/close bold tag
@export_enum("both", "**", "__") var bold = "both"

## choose to use - or * to make points in bulleted list
@export_enum("both", "-", "*") var points = "both"

## returns given Markdown parsed into BBCode
func parse(text: String) -> String:
	text = _addons(text)
	text = parse_headers(text)
	text = parse_imgs(text)
	text = parse_imgs_size(text)
	text = parse_code(text)
	text = parse_hints(text)
	text = fix_hints(text)
	text = parse_links(text)
	text = parse_bold_italic(text)
	text = parse_bold(text)
	text = parse_italics(text)
	text = parse_strike_through(text)
	text = parse_table(text)
	text = parse_color_key(text)
	text = parse_color_hex(text)
	text = parse_spaces(text)
	
	# @center { text }
	text = parse_keyword(text, "center", "center")

	# alt
	# @> text <@
	text = parse_sing(text, "@>", "<@", "center")

	# @u { text }
	text = parse_keyword(text, "u", "u")

	# @right { text }
	text = parse_keyword(text, "right", "right")

	# alt
	# @> text >@
	text = parse_sing(text, "@>", ">@", "right")

	# @fill { text }
	text = parse_keyword(text, "fill", "fill")

	# @justified { text }
	text = parse_keyword(text, "justified", "fill")

	# alt
	# @< text >@
	text = parse_sing(text, "@<", ">@", "fill")

	# @indent { text }
	text = parse_keyword(text, "indent", "indent")

	# @tab { text }
	text = parse_keyword(text, "tab", "indent")

	# alt
	# @| text |@
	text = parse_sing(text, "@\\|", "\\|@", "indent")

	# @wave amp=50 freq=2{ text }
	text = parse_effect(text, "wave", ["amp", "freq"])

	# @tornado radius=5 freq=2{ text }
	text = parse_effect(text, "tornado", ["radius", "freq"])

	# @shake rate=5 level=10{ text }
	text = parse_effect(text, "shake", ["rate", "level"])

	# @fade start=4 length=14{ text }
	text = parse_effect(text, "fade", ["start", "length"])

	# @rainbow freq=0.2 sat=10 val=20{ text }
	text = parse_effect(text, "rainbow", ["freq", "sat", "val"])

	text = parse_points(text)
	text = parse_number_points(text)

	return text

## Parse @space=x, that it add space in text in size of x
func parse_spaces(text: String) -> String:
	re.compile("@space=(?P<size>\\d+)\n")
	result = re.search(text)
	while result != null:
		var size := result.get_string("size").to_int()
		replacement = "[font_size=%d] [/font_size]\n" % size
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)

	return text

## Parse md # Headers in given text into BBCode
func parse_headers(text: String) -> String:
	re.compile("(#+)\\s+(.+\n)")
	result = re.search(text)
	while result != null:
		var header_level = result.get_string(1).length() - 1
		var header_text = result.get_string(2)
		replacement = add_header(header_level, header_text, true)
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)
	
	return text

## Parse md images to in given text to BBCode
## Example of md image: ![](path/to/img)
func parse_imgs(text: String) -> String:
	re.compile("!\\[\\]\\((.*?)\\)")
	result = re.search(text)
	while result != null:
		replacement = "[img]%s[/img]" % result.get_string(1)
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)
	return text

## Parse md images with size to in given text to BBCode
## Example of md image with size: ![height x width](path/to/img)
func parse_imgs_size(text: String) -> String:
	re.compile("!\\[(\\d+)x(\\d+)\\]\\((.*?)\\)")
	result = re.search(text)
	while result != null:
		var height = result.get_string(1)
		var width = result.get_string(2)
		var path = result.get_string(3)
		replacement = "[img=%sx%s]%s[/img]" % [height, width, path]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)
	
	return text

## Parse md links to in given text to BBCode
## Examples of md link:
## [link](path/to/file.md)
## <https://www.example.com>
func parse_links(text: String) -> String:
	# [link](path/to/file.md)
	re.compile("\\[(.+)\\]\\((.+)\\)")
	result = re.search(text)
	while result != null:
		var link = result.get_string(1)
		var url = result.get_string(2)
		replacement = "[url=%s]%s[/url]" % [url, link]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)

	# <https://www.example.com>
	re.compile("<(\\w+:\\/\\/[A-Za-z0-9\\.\\-\\_\\@\\/]+)>")
	result = re.search(text)
	while result != null:
		replacement = "[url]%s[/url]" % result.get_string(1)
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)

	return text

## Parse md hint to in given text to BBCode
## @[text](hint)
func parse_hints(text: String) -> String:
	# @[text](hint)
	re.compile("@\\[(.+)\\]\\((.+)\\)")
	result = re.search(text)
	while result != null:
		var t = result.get_string(1)
		var hint = result.get_string(2)
		replacement = "[hint=%s]%s[/hint]" % [hint, t]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)
	
	return text

func parse_sing(text: String, open: String, close: String, tag: String):
	var search := "(\\W+)%s(.*?)%s(\\W+)" % [open, close]
	re.compile(search)
	result = re.search(text)

	while result != null:
		var r := result.get_string(2)
		
		var r_start := result.get_string(1)
		if r_start.ends_with(open):
			result = re.search(text)
			continue

		var r_end := result.get_string(3)
		if r_end.begins_with(close):
			result = re.search(text)
			continue

		var op_tag = "["
		if "," in tag:
			var tags := tag.split(",", false)
			op_tag += "][".join(tags)
		else: op_tag += tag
		op_tag += "]"

		if " " in open:
			op_tag = " " + op_tag

		var cl_tag = "[/"
		if "," in tag:
			var tags := tag.split(",", false)
			tags.reverse()
			cl_tag += "][/".join(tags)
		else: cl_tag += tag
		cl_tag += "]"

		if " " in close:
			cl_tag += " "

		var arr = [r_start, op_tag, r, cl_tag, r_end]
		replacement = "%s%s%s%s%s" % arr
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)
	
	return text

func get_italics_sing(_italics: String = italics) -> String:
	match _italics:
		"*": return "\\*"
		"_": return "\\_"
	return "[_|\\*]"

func get_bold_sing(_bold: String = bold) -> String:
	match _bold:
		"**": return "\\*\\*"
		"__": return "\\_\\_"
	return "[_\\*]{2}"

## Parse md italics to in given text to BBCode
## Example of md italics:
## If italics = "*" : *italics*
## If italics = "_" : _italics_
func parse_italics(text: String,) -> String:
	var sing := get_italics_sing(italics)
	return parse_sing(text, sing, sing, "i")

## Parse md bold to in given text to BBCode
## Example of md bold:
## If bold = "**" : **bold**
## If bold = "__" : __bold__
func parse_bold(text: String) -> String:
	var sing := get_bold_sing(bold)
	return parse_sing(text, sing, sing, "b")

func parse_bold_italic(text: String) -> String:
	var sing := "[\\*_]{3}"
	var _bold := get_bold_sing(bold)
	var _italics := get_italics_sing(italics)

	if "both" in [bold, italics]:
		sing = "%s%s" % [_bold, _italics]
	else:
		sing = "[%s%s]{3}" % [_bold, _italics]
	
	return parse_sing(text, sing, sing, "i,b")

## Parse md strike through to in given text to BBCode
## Example of md strike through: ~~strike through~~
func parse_strike_through(text: String) -> String:
	# ~~strike through~~
	return parse_sing(text, "~~", "~~", "s")

## Parse md code to in given text to BBCode
## Example of md code:
## one line code: `code`
## multiline code: ```code```
func parse_code(text: String) -> String:
	# `code` or ```code```
	return parse_sing(text, "`{1,3}", "`{1,3}", "code")

## Parse md table to in given text to BBCode
## Example of md table:
## @tabel=2 {
## | cell1 | cell2 |
## }
func parse_table(text: String) -> String:
	# @tabel=2 {
	# | cell1 | cell2 |
	# }
	re.compile("@table=([0-9]+)\\s*\\{\\s*((\\|.+)\n)+\\}")
	result = re.search(text)
	while result != null:
		replacement = "[table=%s]" % result.get_string(1)
		# cell 1 | cell 2
		var r = result.get_string()
		var lines = r.split("\n")
		for line in lines:
			if line.begins_with("|"):
				var cells: Array = line.split("|", false)

				for cell in cells:
					replacement += "[cell]%s[/cell]" % cell

				replacement += "\n"
		replacement += "[/table]"
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)
	
	return text

## Parse md color name from Color class tag to in given text to BBCode
func parse_color_key(text: String) -> String:
	# @color=red { text }
	re.compile("@color=([a-z]+)\\s*\\{\\s*([^\\}]+)\\s*\\}")
	result = re.search(text)
	while result != null:
		var color = result.get_string(1)
		var _text = result.get_string(2)
		replacement = "[color=%s]%s[/color]" % [color, _text]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)
	
	return text

## Parse md color hex to in given text to BBCode
func parse_color_hex(text: String) -> String:
	# @color=#ffe820 { text }
	re.compile("@color=(#[0-9a-f]+)\\s*\\{\\s*([^\\}]+)\\s*\\}")
	for i in range(0, 3):
		result = re.search(text)
		while result != null:
			var color = result.get_string(1)
			var _text = result.get_string(2)
			replacement = "[color=%s]%s[/color]" % [color, _text]
			text = replace_regex_match(text, result, replacement)
			result = re.search(text)
		i += 1
	
	return text

## Parse md effects to in given text to BBCode
func parse_effect(text: String, effect: String, args: Array) -> String:
	# @effect args { text }
	# where args: arg_name=arg_value, arg_name=arg_value
	re.compile("@%s([\\s\\w=0-9\\.]+)\\s*{(.+)}" % effect)
	result = re.search(text)
	while result != null:
		var _args = result.get_string(1)
		var _text = result.get_string(2)
		replacement = "[%s %s]%s[/%s]" % [effect, _args, _text, effect]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)

	# @effect val1,val2 { text }
	re.compile("@%s\\s([0-9\\.\\,\\s]+)\\s*{(.+)}" % effect)
	result = re.search(text)
	while result != null:
		var _values = result.get_string(1)
		_values = _values.replace(" ", "")
		_values = _values.split(",", false)
		var _text = result.get_string(2)
		var _args = ""

		for i in range(0, _values.size()):
			_args += "%s=%s " % [args[i], _values[i]]

		replacement = "[%s %s]%s[/%s]" % [effect, _args, _text, effect]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)
	
	return text

## Parse md keyword to in given text to BBCode
func parse_keyword(text: String, keyword: String, tag: String) -> String:
	# @keyword {text}
	re.compile("@%s\\s*{(.+)}" % keyword)
	result = re.search(text)
	while result != null:
		replacement = "[%s]%s[/%s]" % [tag, result.get_string(1), tag]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)

	return text

## Parse md points list to in given text to BBCode
func parse_points(text: String, _points: String = points) -> String:
	var regex := "^(\\t*)%s\\s+(.+)$"
	match _points:
		"-": regex %= "-"
		"*": regex %= "\\*"
		"both":
			text = parse_points(text, "-")
			return parse_points(text, "*")

	return parse_list(text, "[ul]", "[/ul]", regex)

## Parse md number points list to in given text to BBCode
func parse_number_points(text: String) -> String:
	return parse_list(text, "[ol type=1]", "[/ol]", "^(\\t*)\\d+\\.\\s+(.+)$")

## Parse md list to in given text to BBCode
func parse_list(text: String, open: String, close: String, regex: String):
	re.compile(regex)

	var lines := text.split("\n")
	var new_lines: Array[String] = []
	var in_list := false
	var indent := 0

	for line in lines:
		var result := re.search(line)
		
		if result == null:
			if in_list:
				in_list = false
				new_lines.append(close)

			new_lines.append(line)
			continue

		if not in_list:
			in_list = true
			new_lines.append(open)

		var current_indent := result.get_string(1).count("\t")
		if indent < current_indent:
			indent = current_indent
			new_lines.append(open)
		
		if indent > current_indent:
			indent = current_indent
			new_lines.append(close)
		
		new_lines.append(result.get_string(2))

	text = "\n".join(new_lines)

	return text
