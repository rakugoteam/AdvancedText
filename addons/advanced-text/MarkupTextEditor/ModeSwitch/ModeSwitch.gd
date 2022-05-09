tool
extends HBoxContainer

export (NodePath) onready var files_toggle = get_node(files_toggle) as Button
export (NodePath) onready var node_toggle = get_node(node_toggle) as Button

func _ready():
	node_toggle.connect("pressed", self, "_on_node_mode_toggled")
	node_toggle.icon = get_icon("Control", "EditorIcons")

	files_toggle.connect("pressed", self, "_on_files_mode_toggled")
	files_toggle.icon = get_icon("TextFile", "EditorIcons")

func _on_node_mode_toggled():
	TextEditorHelper.mode = "node"
	TextEditorHelper.emit_signal("selected_mode", "node")

func _on_file_mode_toggled():
	TextEditorHelper.mode = "file"
	TextEditorHelper.emit_signal("selected_mode", "file")