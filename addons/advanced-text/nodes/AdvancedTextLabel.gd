tool
extends RichTextLabel
class_name AdvancedTextLabel, "res://addons/advanced-text/icons/AdvancedTextLabel.svg"

var f : File

export(String, FILE, "*.md, *.rpy, *.txt") var markup_text_file := "" setget _set_markup_text_file, _get_markup_text_file
export(String, MULTILINE) var markup_text := "" setget _set_markup_text, _get_markup_text
export(String, "markdown", "renpy", "bbcode") var markup := "markdown" setget _set_markup, _get_markup
export(Array, DynamicFont) var headers_fonts := [] 

# should be overrider by the user
var variables := {
	"test_string" : "test string",
	"test_int" : 1,
	"test_bool" : true,
	"test_list" : [1],
	"test_dict" : {"key1" : "value1"},
	"test_color" : Color("#1acfa0"),
}

var _markup_text := ""
var _markup := "markdown"
var _markup_text_file := ""
var _parser

func _ready() -> void:
	bbcode_enabled = true
	if _markup_text_file:
		_set_markup_text_file(_markup_text_file)
		
	else:
		_set_markup_text(_markup_text)

func get_hf_paths() -> Array:
	var paths := []
	for font in headers_fonts:
		paths.append(font.resource_path)

	return paths 

func get_text_parser() -> EBBCodeParser:
	if _parser:
		return _parser
	
	return _get_text_parser()

func _get_text_parser() -> EBBCodeParser:
	match _markup:
		"bbcode":
			_parser = EBBCodeParser.new()
		"renpy":
			_parser = RenPyMarkupParser.new()
		"markdown":
			_parser = MarkdownParser.new()

	return _parser

func _set_markup_text_file(value:String) -> void:
	_markup_text_file = value
	if value:
		_load_file(value)

func _load_file(file_path:String) -> void:
	f = File.new()
	f.open(file_path, File.READ)
	var file_ext = file_path.get_extension()

	match file_ext:
		"md":
			_set_markup("markdown")
		"rpy":
			_set_markup("renpy")
		"txt":
			_set_markup("bbcode")

	_set_markup_text(f.get_as_text())
	f.close()

func _get_markup_text_file() -> String:
	return _markup_text_file

func _set_markup_text(value:String) -> void:
	bbcode_enabled = true
	_markup_text = value

	if value == null:
		return

	var p = get_text_parser() 
	if p == null:
		return
	
	var default_vars = parse_json(ProjectSettings.get("advanced_text/default_vars"))
	if default_vars:
		variables = join_dicts([default_vars, variables])
	bbcode_text = p.parse(value, get_hf_paths(), variables)

func join_dicts(dicts:Array) -> Dictionary:
	var result := {}
	for dict in dicts:
		for key in dict:
			result[key] = dict[key]

	return result
	
func _get_markup_text() -> String:
	if _markup_text_file:
		_load_file(_markup_text_file)

	return _markup_text

func _set_markup(value:String) -> void:
	if value != _markup:
		_markup = value
		_get_text_parser()
		_set_markup_text(_markup_text)

func _get_markup() -> String:
	return _markup

func resize_to_text(char_size:Vector2, axis:="xy"):
	if "x" in axis:
		rect_size.x += _markup_text.length() * char_size.x
	if "y" in axis:
		var new_lines:int = _markup_text.split("\n", false).size()
		rect_size.y += new_lines * char_size.y;
