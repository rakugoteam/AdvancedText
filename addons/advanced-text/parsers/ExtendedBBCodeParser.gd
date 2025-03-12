@tool
@icon("res://addons/advanced-text/icons/bbcode.svg")

## This parser adds Headers {h1} and support for IconsFonts
## add Rakugo variables with <var_name> to BBCode
## @tutorial: https://rakugoteam.github.io/advanced-text-docs/2.0/ExtendedBBCodeParser/
class_name ExtendedBBCodeParser
extends TextParser

## Setting for headers
## By default those settings are just sizes: 22, 20, 18 and 16
## Due to BBCode limitations shadow_color is used as background color
## Ignored properties: line_spacing, shadow_offset and shadow_size
@export var headers := _gen_headers([22, 20, 18, 16])

## Generates LabelSettings set based on the given sizes
## It is used to generate headers initial settings.
func _gen_headers(sizes: Array[int], color:=Color.BLACK) -> Array[LabelSettings]:
	var _headers: Array[LabelSettings] = []
	for size in sizes:
		var ls := LabelSettings.new()
		ls.font_size = size
		ls.font_color = color
		_headers.append(ls)
	
	return _headers

## Must be run at start of parsing
## Needed for plugins with other addons to work
func _addons(text: String) -> String:
	if AdvancedText.rakugo:
		text = AdvancedText.rakugo.replace_variables(text)
	
	if AdvancedText.icons_fonts:
			text = AdvancedText.icons_fonts.parse_text(text)
	
	return text

## Returns given ExtendedBBCode parsed into BBCode
func parse(text: String) -> String:
	text = _addons(text)
	text = parse_headers(text)
	text = parse_spaces(text)
	text = fix_hints(text)
	return text

## Parse headers in given text into BBCode
func parse_headers(text: String) -> String:
	re.compile("\\[h(?P<size>[1-4])\\](?P<text>.+?)\\[/h(?P=size)\\]")
	result = re.search(text)
	while result != null:
		var h_size := result.get_string("size").to_int() - 1
		var h_text := result.get_string("text")
		replacement = add_header(h_size, h_text)
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)
	
	return text

## Parse [space=x], that it add space in text in size of x
func parse_spaces(text: String) -> String:
	re.compile("\\[space=(?P<size>\\d+)\\]\n")
	result = re.search(text)
	while result != null:
		var size := result.get_string("size").to_int()
		replacement = "[font_size=%d] [/font_size]\n" % size
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)

	return text

## Returns given text with added BBCode for header with given size (1-4) to it
func add_header(header_size: int, text: String, add_new_line:=false) -> String:
	if !headers: return text
	if headers.is_empty(): return text
	
	var label_settings := headers[header_size]
	var size = label_settings.font_size
	text = text.replace("\n", "")
	replacement = "[font_size=%s]%s[/font_size]" % [size, text]

	if label_settings.font:
		var path := label_settings.font.resource_path
		replacement = "[font=%s]%s[/font]" % [path, replacement]
	
	if label_settings.font_color:
		var color := "#" + label_settings.font_color.to_html()
		replacement = "[color=%s]%s[/color]" % [color, replacement]
	
	if label_settings.outline_size > 0:
		if label_settings.outline_color:
			var ocolor := "#" + label_settings.outline_color.to_html()
			replacement = "[outline_color=%s]%s[/outline_color]" % [ocolor, replacement]
		
		var osize := label_settings.outline_size
		replacement = "[outline_size=%s]%s[/outline_size]" % [osize, replacement]
	
	if label_settings.shadow_color:
		var bgcolor := "#" + label_settings.shadow_color.to_html()
		replacement = "[bgcolor=%s]%s[/bgcolor]" % [bgcolor, replacement]

	if add_new_line:
		return replacement + "\n"
	
	return replacement

## If true hint's into url tags,
## like this [url=hint:something]{text}[\url]
func fix_hints(text:String) -> String:
	re.compile("\\[hint=(?P<hint_id>[\\w-]*)\\](?P<text>.+?)\\[\\/hint\\]")
	result = re.search(text)
	while result != null:
		var hint_id := result.get_string("hint_id")
		var h_text := result.get_string("text")
		replacement = "[url=hint:%s]%s[/url]" % [hint_id, h_text]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)

	return text
