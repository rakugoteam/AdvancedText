tool
extends EditorPlugin


func _enter_tree():
	add_custom_type(
		"AdvancedTextLabel", "RichTextLabel",
		preload("nodes/AdvancedTextLabel.gd"),
		preload("icons/AdvancedTextLabel.svg")
	)


func _exit_tree():
	remove_custom_type("AdvancedTextLabel")
