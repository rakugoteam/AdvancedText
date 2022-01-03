tool
extends EditorPlugin

var markup_text_editor_button := ToolButton.new()
var markup_text_editor
var editor_parent : Control
var button_parent : Control

var default_property_list:Dictionary = {
	"advanced_text/markup" : [
		"markdown", PropertyInfo.new(
			"", TYPE_STRING, PROPERTY_HINT_ENUM, 
			"markdown,renpy,bbcode",
			PROPERTY_USAGE_CATEGORY)
		],
	"advanced_text/default_vars" : [
		# json string
		JSON.print({
			"test_setting" : "variable from project settings" 
		}, "\t"),
		PropertyInfo.new(
			"", TYPE_STRING, PROPERTY_HINT_MULTILINE_TEXT, 
			"",
			PROPERTY_USAGE_CATEGORY)
		],
}

func _enter_tree():
	# loads all parser onces
	var parsers_dir := "res://addons/advanced-text/parsers/" 
	add_autoload_singleton("EBBCodeParser",  parsers_dir + "EBBCodeParser.gd")
	add_autoload_singleton("MarkdownParser", parsers_dir + "MarkdownParser.gd")
	add_autoload_singleton("RenpyParser", 	parsers_dir + "RenpyParser.gd")

	# load and add MarkupTextEditor to EditorUI
	markup_text_editor = preload("MarkupTextEditor/MarkupTextEditor.tscn")
	markup_text_editor = markup_text_editor.instance()
	editor_parent = get_editor_interface().get_editor_viewport()
	markup_text_editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	markup_text_editor.size_flags_vertical = Control.SIZE_EXPAND_FILL
	markup_text_editor.visible = false
	markup_text_editor.editor = get_editor_interface()
	editor_parent.add_child(markup_text_editor)
	
	# add button for MarkupTextEditor to toolbar
	markup_text_editor_button.text = "Markup Text Editor"
	markup_text_editor_button.icon = preload("icons/MarkupTextEditor.svg")
	markup_text_editor_button.toggle_mode = true
	markup_text_editor_button.pressed = false
	markup_text_editor_button.action_mode = ToolButton.ACTION_MODE_BUTTON_RELEASE

	# hack to add the button to the editor modes tabs
	add_control_to_container(CONTAINER_TOOLBAR, markup_text_editor_button)
	button_parent = markup_text_editor_button.get_parent()
	button_parent.remove_child(markup_text_editor_button)
	button_parent = button_parent.get_child(2)
	button_parent.add_child(markup_text_editor_button)

	for b in button_parent.get_children():
		var args := [false, b]
		if b == markup_text_editor_button:
			args[0] = true
		
		b.connect("pressed", self, "_on_toggle", args)
	
	connect("scene_changed", self, "_on_scene_changed")

	for property_key in default_property_list.keys():
		var property_value = default_property_list[property_key]
		ProjectTools.set_setting(property_key, property_value[0], property_value[1])

func _exit_tree():
	# remove MarkupTextEditor from EditorUI
	markup_text_editor.queue_free()

	# remove button from toolbar
	markup_text_editor_button.queue_free()
	
	# unloaded all parsers
	remove_autoload_singleton("EBBCodeParser")
	remove_autoload_singleton("MarkdownParser")
	remove_autoload_singleton("RenpyParser")

func hide_current_editor():
	for editor in editor_parent.get_children():
		if editor.has_method("show"):
			if editor.visible:
				editor.visible = false
				break

	for b in button_parent.get_children():
		if b.pressed:
			b.pressed = false
			return

func _on_scene_changed(scene_root: Node):
	for b in button_parent.get_children():
		if b.pressed:
			show_editor(b)
		
	markup_text_editor_button.pressed = false
	markup_text_editor.visible = false

func show_editor(button: ToolButton):
	for editor in editor_parent.get_children():
		if editor is Control:
			match button.text:
				"2D":
					if editor.get_class() == "CanvasItemEditor":
						editor.show()

				"3D":
					if editor.get_class() == "SpatialEditor":
						editor.show()

				"Script":
					if editor.get_class() == "ScriptEditor":
						editor.show()

				"AssetLib":
					if editor.get_class() == "AssetLibraryEditor":
						editor.show()
				_:
					continue

func _on_toggle(toggled:bool, button:ToolButton):
	if toggled:
		hide_current_editor()
	
	else:
		button.pressed = true
		show_editor(button)

	markup_text_editor_button.pressed = toggled
	markup_text_editor.visible = toggled