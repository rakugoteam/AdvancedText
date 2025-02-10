@tool

## Base class used by AdvancedTexts addon Parsers
## @tutorial: https://rakugoteam.github.io/advanced-text-docs/2.0/TextParser/
class_name TextParser
extends Resource

## RegEx used by this class
var re := RegEx.new()

## Used to store result of last RegEx search
var result: RegExMatch

## Used to store replacement for RegEx search
var replacement := ""

## Root ref is needed to check if other compatible addons are installed
var root: Node

## This only exits to be override by Parsers classes that inherits from it
## This func just returns given with out any changes
func parse(text: String) -> String:
	return text

## Func that my parsers uses to replace result in given text with replacement.
func replace_regex_match(text: String, result: RegExMatch, replacement: String) -> String:
	var start_string := text.substr(0, result.get_start())
	var end_string := text.substr(result.get_end(), text.length())
	return start_string + replacement + end_string

## Returns given path to image as BBCode img
## Size must be given as "<height>x<width>" without "< >"
## Size is this way to be easy to use by Parsers
func to_bbcode_img(path: String, size:="") -> String:
	if size == "":
		return "[img]%s[/img]" % path
	
	return "[img=%s]%s[/img]" % [size, path]

## Returns given path/url to image as BBCode link
## If link_text != "" it will be displayed as link text
func to_bbcode_link(path: String, link_text:="") -> String:
	if link_text == "":
		return "[url]%s[/url]" % path
	
	return "[url=%s]%s[/url]" % [path, link_text]

## Used to replace given `what` Regex String
## with `for_what` String in given text,
## must be called first.
func safe_replace(what: String, for_what: String, text: String) -> String:
	re.compile(what)
	result = re.search(text)
	while result != null:
		
		text = replace_regex_match(text, result, for_what)
		result = re.search(text)

	return text
