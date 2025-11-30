@tool
@icon("res://addons/icons-fonts/nodes/FontIconButton.svg")

# todo add description and docs links when ready
class_name FontIconCheckButton
extends FontIconButton

@export var on_icon_settings := FontIconSettings.new():
	set(value):
		on_icon_settings = value
		if !is_node_ready(): await ready
		if button_pressed:
			toggle_icon.icon_settings = value

@export var off_icon_settings := FontIconSettings.new():
	set(value):
		off_icon_settings = value
		if !is_node_ready(): await ready
		if !button_pressed:
			toggle_icon.icon_settings = value

var toggle_icon: FontIcon:
	get:
		if !_toggle_icon:
			_toggle_icon = FontIcon.new()
		return _toggle_icon

var _toggle_icon: FontIcon

func _ready():
	toggle_mode = true
	super._ready()
	var empty_style := StyleBoxEmpty.new()
	toggle_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toggle_icon.add_theme_stylebox_override("normal", empty_style)
	self.layout_order = layout_order

	Utils.connect_if_possible(
		on_icon_settings.changed,
		toggle_icon._on_icon_settings_changed
	)
	
	Utils.connect_if_possible(
		off_icon_settings.changed,
		toggle_icon._on_icon_settings_changed
	)

func _set_button_pressed(value: bool, _toggle_mode := toggle_mode):
	super._set_button_pressed(value, _toggle_mode)
	if value: toggle_icon.icon_settings = on_icon_settings
	else: toggle_icon.icon_settings = off_icon_settings

func _get_lay_dict() -> Dictionary:
	return {
		"Label": _label,
		"Icon": _font_icon,
		"Toggle": toggle_icon
	}

func _validate_property(property: Dictionary) -> void:
	if property.name == &"layout_order":
		property.hint_string = ",".join([
			"Label-Icon-Toggle", "Label-Toggle-Icon",
			"Toggle-Label-Icon", "Toggle-Icon-Label",
			"Icon-Label-Toggle", "Icon-Toggle-Label",
			"Label-Toggle", "Toggle-Label", "Toggle"
		])
