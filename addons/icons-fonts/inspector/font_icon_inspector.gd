@tool
extends EditorInspectorPlugin

func _can_handle(object: Object):
	return object is FontIconSettings

func _parse_begin(object: Object) -> void:
	var ref: FontIconSettings = object
	var preview := FontIcon.new()
	preview.icon_settings = ref
	preview.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	add_custom_control(preview)
