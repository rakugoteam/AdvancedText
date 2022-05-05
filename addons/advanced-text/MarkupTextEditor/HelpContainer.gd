tool
extends Control

onready var popup := $PopupHelp
onready var button := $Help
onready var tabs := $PopupHelp/HelperContainer

func _ready():
	button.connect("pressed", self, "_on_help_pressed")
	button.icon = get_icon("Help", "EditorIcons")

func _on_help_pressed():
	var mode_id = EditorHelper.get_current_markup()
	tabs.current_tab = mode_id
	popup.popup_centered(Vector2(700, 500))
