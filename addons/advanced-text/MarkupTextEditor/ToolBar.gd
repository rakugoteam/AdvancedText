tool
extends Control

export (NodePath) onready var file_icon = get_node(file_icon) as TextureRect
export (NodePath) onready var file_name = get_node(file_name) as Label
export (NodePath) onready var markup_switch = get_node(markup_switch) as OptionButton

export (NodePath) onready var preview_toggle = get_node(preview_toggle) as Button
export (NodePath) onready var preview_switch = get_node(preview_switch) as OptionButton

signal preview_toggled(toggle)
signal selected_markup(mode)
signal selected_preview(mode)

func _ready():
	preview_toggle.connect("toggled", self, "_on_preview_toggled")
	preview_toggle.icon = get_icon("RichTextEffect", "EditorIcons")

	preview_switch.connect("item_selected", self, "_on_preview_changed")
	preview_switch.set_item_icon(0, get_icon("ControlAlignRightWide", "EditorIcons"))
	preview_switch.set_item_icon(1, get_icon("ControlAlignBottomWide", "EditorIcons"))

	markup_switch.connect("item_selected", self, "set_markup")

func _on_preview_toggled(toggle:bool):
	emit_signal("preview_toggled", toggle)

func _on_preview_changed(mode):
	var txt_mode = preview_switch.get_item_text(mode)
	emit_signal("selected_preview", txt_mode)

func set_markup(mode):
	var txt_mode = markup_switch.get_item_text(mode)
	emit_signal("selected_markup", txt_mode)



