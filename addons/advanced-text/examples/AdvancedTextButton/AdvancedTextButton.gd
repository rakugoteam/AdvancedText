# tool
extends Button
class_name AdvancedTextButton

onready var adv_label := $AdvancedTextLabel
func _ready():
	adv_label.connect("resized", self, "_on_button_resized")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	connect("pressed", self, "_on_pressed")
	connect("toggled", self, "_on_toggled")

func set_markup_text(text: String):
	adv_label.markup_text = text

func set_markup(markup: String):
	adv_label.markup = markup

func _set_label_color(color_name:String):
	adv_label.modulate = get_color(color_name, "Button")

func _set(property:String, value)->bool:
	if property in get_property_list():
		set(property, value)
	else:
		return false

	match property:
		"disabled":
			if value:
				_set_label_color("font_color_disabled")
			else:
				_set_label_color("font_color")
				
	return true

func _on_button_resized():
	adv_label.rect_size = rect_size

func is_toggled():
	return pressed and toggle_mode

func _on_mouse_entered():
	if not (disabled or is_toggled()):
		_set_label_color("font_color_hover")

func _on_mouse_exited():
	if not (disabled or is_toggled()):
		_set_label_color("font_color")

func _on_pressed():
	if not disabled:
		_set_label_color("font_color_pressed")

func _on_toggled(value:bool):
	if not disabled:
		if value:
			_set_label_color("font_color_pressed")
		else:
			_set_label_color("font_color")


