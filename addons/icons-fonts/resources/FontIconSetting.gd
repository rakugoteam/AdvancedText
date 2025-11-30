@tool
@icon("res://addons/icons-fonts/resources/FontIconSettings.svg")
class_name FontIconSettings
extends Resource

@export_enum("MaterialIcons", "Emojis")
var icon_font := "MaterialIcons"

## Name of Icon to display
@export var icon_name := "image-outline":
	set(value):
		icon_name = value
		emit_changed()

## Size of the icon in range 16-128
@export_range(16, 128, 1)
var icon_size := 16:
	set(value):
		icon_size = value
		emit_changed()

@export var icon_color := Color.WHITE:
	set(value):
		icon_color = value
		emit_changed()

@export_group("Outline", "outline_")
@export var outline_color := Color.WHITE:
	set(value):
		outline_color = value
		emit_changed()

@export var outline_size := 0:
	set(value):
		outline_size = value
		emit_changed()

@export_group("Shadow", "shadow_")
@export var shadow_color := Color.WHITE:
	set(value):
		shadow_color = value
		emit_changed()

@export var shadow_size := 0:
	set(value):
		shadow_size = value
		emit_changed()

@export var shadow_offset := Vector2.ZERO:
	set(value):
		shadow_offset = value
		emit_changed()

func update_label_settings(label_settings: LabelSettings) -> void:
	match icon_font:
		"MaterialIcons":
			label_settings.font = load(IconsFonts.material_icons_font)
		"Emojis":
			label_settings.font = load(IconsFonts.emojis_font)

	label_settings.font_size = icon_size
	label_settings.font_color = icon_color
	label_settings.outline_color = outline_color
	label_settings.outline_size = outline_size
	label_settings.shadow_color = shadow_color
	label_settings.shadow_offset = shadow_offset
	label_settings.shadow_size = shadow_size
