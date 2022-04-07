tool
extends Button

export (NodePath) onready var help_popup = get_node(help_popup) as Popup

func _ready():
	connect("pressed", self, "_on_help_pressed")
	icon = get_icon("Help", "EditorIcons")

func _on_help_pressed():
	# var mode_id = markup_switch.selected
	# emit_signal("help_pressed", mode_id)
	# tabs.current_tab = mode
	help_popup.popup_centered(Vector2(700, 500))