tool
extends Control

export (NodePath) onready var popup = get_node(popup) as Popup
export (NodePath) onready var button = get_node(button) as Button

func _ready():
	button.connect("pressed", self, "_on_help_pressed")
	button.icon = get_icon("Help", "EditorIcons")

func _on_help_pressed():
	var mode_id = EditorHelper.get_current_markup()
	popup.tabs.current_tab = mode_id
	popup.popup_centered(Vector2(700, 500))