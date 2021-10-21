tool
extends EditorPlugin

var atl_inspector
var markup_text_editor_button := ToolButton.new()
var markup_text_editor

func _enter_tree():
	atl_inspector = preload("inspector/AdvancedTextLabelInspector.gd")
	atl_inspector = atl_inspector.new()
	add_inspector_plugin(atl_inspector)

	markup_text_editor = preload("MarkupTextEditor/MarkupTextEditor.tscn")
	markup_text_editor = markup_text_editor.instance()
	markup_text_editor.visible = false
	markup_text_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	get_editor_interface().get_editor_viewport().add_child(markup_text_editor)
	
	markup_text_editor_button.text = "Markup Text Editor"
	markup_text_editor_button.icon = preload("MarkupTextEditor/MarkupTextEditor.svg")
	markup_text_editor_button.toggle_mode = true
	add_control_to_container(CONTAINER_TOOLBAR, markup_text_editor_button)
	var button_parent = markup_text_editor_button.get_parent()
	button_parent.remove_child(markup_text_editor_button)
	button_parent = button_parent.get_child(2)
	markup_text_editor_button.connect("toggled", self, "_on_toggle")
	button_parent.add_child(markup_text_editor_button)

func _exit_tree():
	remove_inspector_plugin(atl_inspector)
	markup_text_editor.queue_free()
	markup_text_editor_button.queue_free()

func _on_toggle(toggled:bool):
	markup_text_editor.visible = toggled