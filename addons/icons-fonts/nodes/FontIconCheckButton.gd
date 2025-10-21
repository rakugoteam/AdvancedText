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
			_toggle_icon.icon_settings = value

@export var off_icon_settings := FontIconSettings.new():
	set(value):
		off_icon_settings = value
		if !is_node_ready(): await ready
		if !button_pressed:
			_toggle_icon.icon_settings = value

var _toggle_icon : FontIcon

func _ready():
	toggle_mode = true
	super._ready()
	var empty_style := StyleBoxEmpty.new()
	_toggle_icon = FontIcon.new()
	_toggle_icon.add_theme_stylebox_override("normal", empty_style)
	self.layout_order = layout_order

	Utils.connect_if_possible(
		on_icon_settings, "changed",
		_toggle_icon._on_icon_settings_changed)
	
	Utils.connect_if_possible(
		off_icon_settings, "changed",
		_toggle_icon._on_icon_settings_changed)

func _togglef(main_button: ButtonContainer, value: bool):
	if disabled: return
	if main_button == self: return

	if value: _toggle_icon.icon_settings = on_icon_settings
	else: _toggle_icon.icon_settings = off_icon_settings
	super._togglef(main_button, value)

func _get_lay_dict() -> Dictionary:
	return {
		"Label": _label,
		"Icon": _font_icon,
		"Toggle": _toggle_icon
	}

func _validate_property(property : Dictionary) -> void:
	if property.name == &"layout_order":
		property.hint_string = ",".join([
			"Label-Icon-Toggle", "Label-Toggle-Icon",
			"Toggle-Label-Icon", "Toggle-Icon-Label",
			"Icon-Label-Toggle", "Icon-Toggle-Label",
			"Label-Toggle", "Toggle-Label"
		])
