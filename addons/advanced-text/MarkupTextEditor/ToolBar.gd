tool
extends Control

var EmojisImport
var emojis_gd

var IconsImport
var icons_gd

export (NodePath) onready var node_toggle = get_node(node_toggle) as Button
export (NodePath) onready var files_toggle = get_node(files_toggle) as Button

export (NodePath) onready var file_icon = get_node(file_icon) as TextureRect
export (NodePath) onready var file_name = get_node(file_name) as Label
export (NodePath) onready var markup_switch = get_node(markup_switch) as OptionButton

export (NodePath) onready var preview_toggle = get_node(preview_toggle) as Button
export (NodePath) onready var preview_switch = get_node(preview_switch) as OptionButton

export (NodePath) onready var help_button = get_node(help_button) as Button
export (NodePath) onready var help_popup = get_node(help_popup) as Popup

export (NodePath) onready var emoji_button = get_node(emoji_button) as Button
export (NodePath) onready var icon_button = get_node(icon_button) as Button

signal preview_toggled(toggle)
signal help_pressed
signal selected_mode(mode)
signal selected_markup(mode)
signal selected_preview(mode)

func _ready():
	import_emojis()
	import_mat_icons()
	preview_toggle.connect("toggled", self, "_on_preview_toggled")
	preview_toggle.icon = get_icon("RichTextEffect", "EditorIcons")

	preview_switch.connect("item_selected", self, "_on_preview_changed")
	preview_switch.set_item_icon(0, get_icon("ControlAlignRightWide", "EditorIcons"))
	preview_switch.set_item_icon(1, get_icon("ControlAlignBottomWide", "EditorIcons"))

	help_button.connect("pressed", self, "_on_help_pressed")
	help_button.icon = get_icon("Help", "EditorIcons")
	markup_switch.connect("item_selected", self, "set_markup")

	node_toggle.connect("pressed", self, "_on_node_mode_toggled")
	node_toggle.icon = get_icon("Control", "EditorIcons")

	files_toggle.connect("pressed", self, "_on_files_mode_toggled")
	files_toggle.icon = get_icon("TextFile", "EditorIcons")

func _on_preview_toggled(toggle:bool):
	emit_signal("preview_toggled", toggle)

func _on_help_pressed():
	var mode_id = markup_switch.selected
	emit_signal("help_pressed", mode_id)

func _on_preview_changed(mode):
	var txt_mode = preview_switch.get_item_text(mode)
	emit_signal("selected_preview", txt_mode)

func set_markup(mode):
	var txt_mode = markup_switch.get_item_text(mode)
	emit_signal("selected_markup", txt_mode)

func _on_node_mode_toggled():
	emit_signal("selected_mode", "node")

func _on_file_mode_toggled():
	emit_signal("selected_mode", "file")

func import_emojis():
	EmojisImport = preload("../emojis_import.gd")
	EmojisImport = EmojisImport.new()

	if EmojisImport.is_plugin_enabled():
		var emoji_panel : Popup = EmojisImport.get_emoji_panel()
		emoji_panel.visible = false
		add_child(emoji_panel)
		emoji_button.connect("pressed", emoji_panel, "popup_centered", [Vector2(450, 400)])
		emoji_button.show()
	else:
		EmojisImport.free()

func import_mat_icons():
	IconsImport = preload("../material_icons_import.gd")
	IconsImport = IconsImport.new()

	if IconsImport.is_plugin_enabled():
		var icon_panel : Popup = IconsImport.get_icons_panel()
		icon_panel.visible = false
		add_child(icon_panel)
		icon_button.connect("pressed", icon_panel, "popup_centered", [Vector2(450, 400)])
		icon_button.show()
	else:
		IconsImport.free()
