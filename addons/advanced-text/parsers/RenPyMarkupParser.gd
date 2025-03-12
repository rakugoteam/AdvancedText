@tool
@icon("res://addons/advanced-text/icons/ren16.png")

## This parser is every limited as its just translates RenPy Markup to BBCode
## adds Headers {h1}, FontsIcons and Rakugo variables with <var_name>
## @tutorial: https://rakugoteam.github.io/advanced-text-docs/2.0/RenPyMarkupParser/
class_name RenPyMarkupParser
extends ExtendedBBCodeParser

## Returns given RenPyMarkup parsed into BBCode
func parse(text: String) -> String:
	## BBCode and Ren'Py has a lot of the same tags,
	## but RenPy uses '{}' instead of '[]',
	## so we need to replace them

	text = _addons(text)
	text = parse_links(text)
	text = parse_imgs(text)
	text = parse_imgs_size(text)
	text = safe_replace("{", "[", text)
	text = safe_replace("}", "]", text)
	text = parse_headers(text)
	text = parse_spaces(text)
	text = fix_hints(text)

	return text

func _addons(text := "") -> String:
	re.compile("\\{(mi:.*?)\\}")
	result = re.search(text)
	while result != null:
		replacement = "[%s]" % result.get_string(1)
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)
		
	return super._addons(text)

## parse Ren'Py links into BBCode
## Ren'Py links examples:
## {a=https://some_domain.com}link{/a}
## {a}https://some_domain.com{/a}
func parse_links(text: String) -> String:
	re.compile("(?<!\\{)\\{(\\/{0,1})a(?:(=[^\\}]+)\\}|\\})")
	result = re.search(text)
	while result != null:
		replacement = "[%surl%s]" % [
			result.get_string(1), result.get_string(2)]
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)
		
	return text

## parse Ren'Py images with out size into BBCode
## Ren'Py images example:
## {img=<path>}
func parse_imgs(text: String) -> String:
	re.compile("(?<!\\{)\\{img=([^\\}\\s]+)\\}")
	result = re.search(text)
	while result != null:
		replacement = to_bbcode_img(result.get_string(1))
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)

	return text

## parse Ren'Py images with size into BBCode
## Ren'Py images with size example:
# {img=<path> size=<height>x<width>}
func parse_imgs_size(text: String) -> String:
	re.compile("(?<!\\{)\\{img=([^\\}\\s]+) size=([^\\}]+)\\}")
	result = re.search(text)
	while result != null:
		replacement = to_bbcode_img(result.get_string(1), result.get_string(2))
		text = replace_regex_match(text, result, replacement)
		result = re.search(text)

	return text
