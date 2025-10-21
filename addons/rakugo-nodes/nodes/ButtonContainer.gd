@tool
@icon("res://addons/custom-ui-elements/nodes/ButtonContainer.svg")
extends PanelContainer

# todo add description and docs links when ready
class_name ButtonContainer

## Emitted when button is pressed
signal pressed

## Emitted when button is toggled
## Works only if `toggle_mode` is on.
signal toggled(value: bool)

signal state_changed(state_name: StringName)

## If true, button will be disabled
@export var disabled := false:
	set(value):
		disabled = value
		if disabled:
			_change_stylebox("disabled")
			state_changed.emit(&"disabled")
			return
		
		_change_stylebox("normal")
		state_changed.emit(&"normal")

## If true, button will be in toggle mode
@export var toggle_mode := false
var _toggled := false:
	get: return _toggled

## If true, button will be in pressed state
@export var button_pressed := false:
	set(value):
		if toggle_mode:
			button_pressed = value
			_togglef(null, value)
			return
		
		emit_signal("pressed")

## Name of node group to be used as button group
## It changes all buttons with toggle_mode in group into radio buttons
@export var button_group: StringName = ""

@export_group("Styles", "style_")
@export var style_normal: StyleBox:
	set(value):
		style_normal = value
		if !disabled or !button_pressed:
			_change_stylebox("normal")

@export var style_focus: StyleBox

@export var style_pressed: StyleBox:
	set(value):
		style_pressed = value
		if !disabled and button_pressed:
			_change_stylebox("pressed")

@export var style_hover: StyleBox

@export var style_disabled: StyleBox:
	set(value):
		style_disabled = value
		if disabled:
			_change_stylebox("disabled")

var current_style: StringName

func _ready() -> void:
	_change_stylebox("normal")
	state_changed.emit(&"normal")
	Utils.connect_if_possible(self, &"mouse_entered", _on_mouse_entered)
	Utils.connect_if_possible(self, &"mouse_exited", _on_mouse_exited)
	
	if button_group: add_to_group(button_group)

func _on_mouse_exited():
	if disabled: return
	if toggle_mode and _toggled: return
	_change_stylebox("normal")
	state_changed.emit(&"normal")

func _on_mouse_entered():
	if disabled: return
	_change_stylebox("hover")
	state_changed.emit(&"hover")

func _change_stylebox(button_style: StringName = "normal"):
	# prints("changed style to:", button_style)
	var stylebox := get_theme_stylebox(button_style, "Button")
	match button_style:
		"normal":
			stylebox = style_normal if style_normal else stylebox
		"focus":
			stylebox = style_focus if style_focus else stylebox
		"pressed":
			stylebox = style_pressed if style_pressed else stylebox
		"hover":
			stylebox = style_hover if style_hover else stylebox
		"disabled":
			stylebox = style_disabled if style_disabled else stylebox

	if current_style != button_style:
		current_style = button_style
		add_theme_stylebox_override("panel", stylebox)

func _gui_input(event: InputEvent) -> void:
	if disabled: return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if toggle_mode:
				var t := !_toggled
				_togglef(null, t)
				
				if button_group:
					get_tree().call_group(
						button_group, "_togglef", self, !t)
					return
			
			state_changed.emit(&"pressed")
			pressed.emit()

func _togglef(main_button: ButtonContainer, value: bool):
	if disabled: return
	if main_button == self: return

	_toggled = value
	if value:
		_change_stylebox("pressed")
		state_changed.emit(&"pressed")
	else:
		_change_stylebox("normal")
		state_changed.emit(&"normal")

	toggled.emit(_toggled)
