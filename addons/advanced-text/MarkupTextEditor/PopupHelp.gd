extends WindowDialog

export var tb_path : NodePath
onready var toolbar : Control = get_node(tb_path)
onready var tabs : TabContainer = $HelperContainer

func _ready():
	toolbar.connect("help_pressed", self, "_on_help_pressed")

func _on_help_pressed(mode):
	tabs.current_tab = mode
	popup_centered(Vector2(700, 500))
