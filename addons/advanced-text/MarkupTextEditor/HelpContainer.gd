tool
extends Control

onready var popup := $PopupHelp
onready var button := $Help

func _ready():
	button.connect("pressed", self, "_on_help_pressed")
	button.icon = get_icon("Help", "EditorIcons")

func _on_help_pressed():
	var mode_id = EditorHelper.get_current_markup()
	popup.tabs.current_tab = mode_id
	popup.popup_centered(Vector2(700, 500))