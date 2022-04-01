extends WindowDialog

export (NodePath) onready var toolbar = get_node(toolbar) as Control
export (NodePath) onready var tabs = get_node(tabs) as TabContainer

func _ready():
	toolbar.connect("help_pressed", self, "_on_help_pressed")

func _on_help_pressed(mode):
	tabs.current_tab = mode
	popup_centered(Vector2(700, 500))
