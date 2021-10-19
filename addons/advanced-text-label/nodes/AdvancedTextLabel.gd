tool
extends RichTextLabel
class_name AdvancedTextLabel, "res://addons/advanced-text-label/icons/AdvancedTextLabel.svg"

export(String, MULTILINE) var markup_text:String setget _set_markup_text, _get_markup_text
export(String, "markdown", "renpy", "bbcode") var markup setget _set_markup, _get_markup
export var variables := {}

var _markup_text := ""
var _markup := "Extended BBCode"
var ebbcode_parser := EBBCodeParser.new()
var markdown_parser := MarkdownParser.new()
var renpy_parser := RenPyMarkupParser.new()

func _ready() -> void:
	bbcode_enabled = true
	_set_markup_text(_markup_text)

func _get_text_parser():
	match _markup:
		"bbcode":
			return ebbcode_parser
		"renpy":
			return renpy_parser
		"markdown":
			return markdown_parser

func _set_markup_text(value:String) -> void:
	bbcode_enabled = true
	_markup_text = value

	var p = _get_text_parser()
	if p == null:
		return
	
	if value == null:
		return

	bbcode_text = p.parse(value, Engine.editor_hint, variables)
	
func _get_markup_text() -> String:
	return _markup_text

func _set_markup(value:="") -> void:	
	_markup = value
	_set_markup_text(_markup_text)

func _get_markup() -> String:
	return _markup

func resize_to_text(char_size:Vector2, axis:="xy"):
	if "x" in axis:
		rect_size.x += _markup_text.length() * char_size.x
	if "y" in axis:
		var new_lines:int = _markup_text.split("\n", false).size()
		rect_size.y += new_lines * char_size.y;
