@tool
@icon("res://addons/icons-fonts/nodes/FontIcon.svg")

# todo add description and docs links when ready
class_name FontIcon
extends Label

@export var icon_settings := FontIconSettings.new()

func _ready():
	_on_icon_settings_changed()
	Utils.connect_if_possible(
		icon_settings, "changed", _on_icon_settings_changed)

func _on_icon_settings_changed():
	if !label_settings:
		label_settings = LabelSettings.new()
	
	icon_settings.update_label_settings(label_settings)
	text = IconsFonts.get_icon_char(
		icon_settings.icon_font,
		icon_settings.icon_name
	)

func _validate_property(property : Dictionary) -> void:
	if property.name in [&"text", &"label_settings"]:
		property.usage &= ~PROPERTY_USAGE_EDITOR
