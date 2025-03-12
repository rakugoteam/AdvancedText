@tool
@icon("res://addons/advanced-text/icons/AdvancedTextLabel.svg")

## This class parses given text to bbcode using given TextParser
## @tutorial: https://rakugoteam.github.io/advanced-text-docs/2.0/AdvancedTextLabel/
class_name AdvancedTextLabel
extends RichTextLabel

## By default links (begins with `http`) will be opened in web browser
## For custom links you can connect to `custom_link` signal
signal custom_link(url:String)

## Text to be parsed in too BBCode
## Use it instead of `text` from RichTextLabel
## I had to make this way as I can't override `text` var behavior
@export_multiline var advanced_text := "":
	set(value):
		advanced_text = value
		if value == "":
			text = ""
			return
		
		_parse_text()

@export var hint_popup_size := Vector2(315, 100)

## TextParser that will be used to parse `advanced_text`
@export var parser: TextParser:
	set(value):
		parser = value
		update_configuration_warnings()
		if parser:
			if not parser.changed.is_connected(_parse_text):
				parser.changed.connect(_parse_text)

			if parser is ExtendedBBCodeParser:
				for h in parser.headers:
					if not h.changed.is_connected(_parse_text):
						h.changed.connect(_parse_text)

			_parse_text()
			# print("parse text")

var font_size : int:
	get:
		if !theme: return 16
		return theme.get_font_size(get_class(), &"normal")

func _ready():
	bbcode_enabled = true
	meta_clicked.connect(_on_meta)
	meta_hover_started.connect(_on_meta_hover_started)
	meta_hover_ended.connect(_on_meta_hover_ended)

	if not advanced_text:
		custom_minimum_size = Vector2.ONE * font_size

	_parse_text()

func _parse_text() -> void:
	if !is_node_ready(): return
	if parser:
		if AdvancedText.rakugo:
			var r = AdvancedText.rakugo
			var sg = r.sg_variable_changed
			if !sg.is_connected(_on_rakuvars_changed):
				sg.connect(_on_rakuvars_changed)
	
	if !parser:
		push_warning("parser is null at " + str(name))
		text = advanced_text
		return
	
	text = parser.parse(advanced_text)

func _on_rakuvars_changed(var_name, value) -> void:
	if "<%s>" % var_name in advanced_text:
		_parse_text()

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	if !parser:
		warnings.append("Need parser.")

	return warnings

func _on_meta(url: String) -> void:
	if url.begins_with("http"):
		OS.shell_open(url)
		return
	
	emit_signal("custom_link", url)

func _on_meta_hover_started(url: String) -> void:
	if url.begins_with("hint:"):
		var hint_id := url.trim_prefix("hint:")
		var hint := _hint_requested(hint_id)

		if hint != tr(hint):
			HintPopup.text = tr(hint)

		var hint_rect: Rect2 = HintPopup.get_rect()
		hint_rect.position = get_global_mouse_position()
		hint_rect.size = hint_popup_size
		HintPopup.popup(hint_rect)

func _on_meta_hover_ended(_url: String) -> void:
	HintPopup.hide()

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"text":
			property.usage = PROPERTY_HINT_NONE
		&"bbcode_enabled":
			property.usage = PROPERTY_HINT_NONE

## Override it to make hint_id system working
func _hint_requested(hint_id:StringName) -> String:
	return ""
