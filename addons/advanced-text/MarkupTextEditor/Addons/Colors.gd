tool
extends Button

onready var color_picker = $WindowDialog/ColorPicker
onready var popup = $WindowDialog

func _ready():
	icon = get_icon("ColorPick", "EditorIcons")
	connect("pressed", popup, "popup_centered", [Vector2(700, 400)])
	color_picker.connect("color_changed", self, "_on_color_changed")

func _on_color_changed(color: Color):
	OS.clipboard = "#"+color.to_html()
