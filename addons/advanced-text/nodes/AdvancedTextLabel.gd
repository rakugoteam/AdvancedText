tool
extends RichTextLabel
class_name AdvancedTextLabel, "res://addons/advanced-text/icons/AdvancedTextLabel.svg"

var f : File
signal update

export(String, FILE, "*.md, *.rpy, *.txt") var markup_text_file := "" setget _set_markup_text_file
export(String, MULTILINE) var markup_text := "" setget _set_markup_text
export(String, "default", "markdown", "renpy", "bbcode") var markup := "default" setget _set_markup
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

var _parser : EBBCodeParser
var hf_paths : Array

func _ready() -> void:
	bbcode_enabled = true
	connect("update", self, "_on_update")

func get_hf_paths() -> Array:
	var paths := []
	for font in headers_fonts:
		paths.append(font.resource_path)

	return paths 

func get_text_parser(_markup:String) -> EBBCodeParser:
	if _parser == null:
		_parser = _get_text_parser(_markup)
	elif markup != _markup:
		_parser = _get_text_parser(_markup)
	
	return _parser

func _get_text_parser(_markup_str:String) -> EBBCodeParser:
	match _markup_str:
		"default":
			var default = ProjectSettings.get("advanced_text/markup")
			return _get_text_parser(default)
		"bbcode":
			_parser = EBBCodeParser.new()
		"renpy":
			_parser = RenPyMarkupParser.new()
		"markdown":
			_parser = MarkdownParser.new()

	return _parser

func _set_markup_text_file(value:String) -> void:
	markup_text_file = value
	emit_signal("update")

func _load_file(file_path:String) -> void:
	f = File.new()
	f.open(file_path, File.READ)
	var file_ext = file_path.get_extension()

	bbcode_enabled = true
	match file_ext:
		"md":
			markup = "markdown"
		"rpy":
			markup = "renpy"
		"txt":
			markup = "bbcode"

	markup_text = f.get_as_text()
	f.close()

func _set_markup_text(value:String) -> void:
	markup_text = value
	emit_signal("update")

func _on_update() -> void:
	bbcode_enabled = true
	if markup_text_file:
		_load_file(markup_text_file)

	var p = _get_text_parser(markup) 
	if p == null:
		return
	
	var vars_json = ProjectSettings.get("advanced_text/default_vars")
	var default_vars = parse_json(vars_json)
	
	if default_vars:
		variables = join_dicts([default_vars, variables])
	
	if hf_paths == null:
		hf_paths = get_hf_paths()
	
	bbcode_text = p.parse(markup_text, hf_paths, variables)

func join_dicts(dicts:Array) -> Dictionary:
	var result := {}
	for dict in dicts:
		for key in dict:
			result[key] = dict[key]

	return result

func _set_markup(value:String) -> void:
	markup = value
	emit_signal("update")

func resize_to_text(char_size:Vector2, axis:="xy"):
	if "x" in axis:
		rect_size.x += markup_text.length() * char_size.x
	if "y" in axis:
		var new_lines:int = markup_text.split("\n", false).size()
		rect_size.y += new_lines * char_size.y;
