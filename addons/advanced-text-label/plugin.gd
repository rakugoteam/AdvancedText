tool
extends EditorPlugin

var atl_inspector

func _enter_tree():
	add_custom_type(
		"AdvancedTextLabel", "RichTextLabel",
		preload("nodes/AdvancedTextLabel.gd"),
		preload("icons/AdvancedTextLabel.svg")
	)
	atl_inspector = preload("inspector/AdvancedTextLabelInspector.gd")
	atl_inspector = atl_inspector.new()
	add_inspector_plugin(atl_inspector)

func _exit_tree():
	remove_inspector_plugin(atl_inspector)
	remove_custom_type("AdvancedTextLabel")
