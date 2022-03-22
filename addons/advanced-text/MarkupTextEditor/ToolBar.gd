tool
extends Control

var EmojisImport
var emojis_gd

var IconsImport
var icons_gd

export var AdvancedTextLabelIcon : Texture
export var CodeEditIcon : Texture
export var MarkdownIcon : Texture
export var RpyIcon : Texture
export var BBCodeIcon : Texture

onready var preview_toggle : Button = $HBoxContainer/HBoxContainer/PreviewToggle
onready var help_button : Button = $HBoxContainer/HBoxContainer/HelpButton
onready var selected_node_toggle : Button = $HBoxContainer/EditSelectedNode
onready var files_toggle : Button = $HBoxContainer/EditSelectedFile
onready var help_popup : Popup = $PopupHelp
onready var markup_switch : OptionButton = $HBoxContainer/CenterContainer/HBoxContainer/MarkupOption
onready var preview_switch : OptionButton = $HBoxContainer/HBoxContainer/PreviewOption
onready var emoji_button : Button = $HBoxContainer/HBoxContainer/EmojisButton
onready var icon_button : Button = $HBoxContainer/HBoxContainer/IconsButton

signal preview_toggle
signal help_pressed
signal selected_mode(mode)
signal selected_markup(mode)
signal selected_preview(mode)

func _ready():
	import_emojis()
	import_mat_icons()
	preview_toggle.connect("toggled", self, "emit_signal", ["preview_toggle"])
	preview_toggle.icon = get_icon("RichTextEffect", "EditorIcons")

	preview_switch.connect("item_selected", self, "_on_preview_changed")
	preview_switch.set_item_icon(0, get_icon("ControlAlignRightWide", "EditorIcons"))
	preview_switch.set_item_icon(1, get_icon("ControlAlignBottomWide", "EditorIcons"))

	help_button.connect("pressed", self, "_on_help_pressed")
	help_button.icon = get_icon("Help", "EditorIcons")
	markup_switch.connect("item_selected", self, "_on_markup_changed")

	selected_node_toggle.connect("toggled", self, "emit_signal", ["selected_mode", "node"])
	selected_node_toggle.icon = get_icon("Control", "EditorIcons")

	files_toggle.connect("toggled", self, "emit_signal", ["selected_mode", "file"])
	files_toggle.icon = get_icon("TextFile", "EditorIcons")

func _on_help_pressed():
	var mode_id = markup_switch.selected
	emit_signal("help_pressed", mode_id)

func _on_preview_changed(mode):
	var txt_mode = preview_switch.get_item_text(mode)
	emit_signal("selected_preview", txt_mode)

func _on_markup_changed(mode):
	var txt_mode = markup_switch.get_item_text(mode)
	emit_signal("selected_markup", txt_mode)

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
