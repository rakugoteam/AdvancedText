tool
extends EditorPlugin

var atl_inspector
var markup_text_editor_button := ToolButton.new()
var markup_text_editor
var editor_parent : Control
var button_parent : Control

func _enter_tree():
	atl_inspector = preload("inspector/AdvancedTextLabelInspector.gd")
	atl_inspector = atl_inspector.new()
	add_inspector_plugin(atl_inspector)

	markup_text_editor = preload("MarkupTextEditor/MarkupTextEditor.tscn")
	markup_text_editor = markup_text_editor.instance()
	markup_text_editor.visible = false
	markup_text_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	markup_text_editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	editor_parent = get_editor_interface().get_editor_viewport()
	editor_parent.add_child(markup_text_editor)
	
	markup_text_editor_button.text = "Markup Text Editor"
	markup_text_editor_button.icon = preload("MarkupTextEditor/MarkupTextEditor.svg")
	markup_text_editor_button.toggle_mode = true
	markup_text_editor_button.pressed = false
	markup_text_editor_button.action_mode = ToolButton.ACTION_MODE_BUTTON_RELEASE

	# hack to add the button to the editor modes tabs
	add_control_to_container(CONTAINER_TOOLBAR, markup_text_editor_button)
	button_parent = markup_text_editor_button.get_parent()
	button_parent.remove_child(markup_text_editor_button)
	button_parent = button_parent.get_child(2)

	for b in button_parent.get_children():
		b.connect("pressed", self, "_on_toggle", [false])

	markup_text_editor_button.connect("toggled", self, "_on_toggle")
	button_parent.add_child(markup_text_editor_button)

func _exit_tree():
	remove_inspector_plugin(atl_inspector)
	markup_text_editor.queue_free()
	markup_text_editor_button.queue_free()

func hide_current_editor():
	for ch in editor_parent.get_children():
		if ch.visible:
			ch.visible = false
			return

func unpressed_current_button():
	for ch in button_parent.get_children():
		if ch.pressed:
			ch.pressed = false
			return

func _on_toggle(toggled:bool):
	if toggled:
		hide_current_editor()
		unpressed_current_button()
		
	markup_text_editor.visible = toggled