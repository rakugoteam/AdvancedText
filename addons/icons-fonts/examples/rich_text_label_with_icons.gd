@tool
extends RichTextLabel

@export_multiline
var text_with_icons: String:
	set(value):
		if !is_node_ready(): await ready
		text_with_icons = value
		bbcode_enabled = true
		text = IconsFonts.parse_text(value)

	get: return text_with_icons

func _ready():
	bbcode_enabled = true
	text = IconsFonts.parse_text(text_with_icons)
