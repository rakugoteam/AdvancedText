@tool
@icon("res://addons/custom-ui-elements/nodes/ButtonContainer.svg")
extends PanelContainer

# todo add description and docs links when ready
class_name ButtonContainer

## Emitted when button is pressed
signal pressed

## Emitted when button is toggled
## [br] Works only if `toggle_mode` is on.
signal toggled(value: bool)

## If true, button will be disabled
@export var disabled := false:
	set(value):
		disabled = value
		_disable(value)

## If true, button will be in toggle mode
@export var toggle_mode := false

## If true, button will be in pressed state
@export var button_pressed := false:
	set(value):
		if disabled:
			push_warning(name + " button is disabled")
			return
		# must be done using extra priv 
		if toggle_mode and value == _button_pressed: return
		_button_pressed = value
		_set_button_pressed(value)
	get: return _button_pressed

## Name of node group to be used as button group
## [br] It changes all buttons with toggle_mode in group into radio buttons
@export var button_group: StringName = ""

@export_group("Styles", "style_")
@export_enum("normal", "focus", "pressed", "hover", "hover_pressed", "disabled")
var style_current := "normal":
	set(value):
		style_current = value
		_change_stylebox(style_current)
		
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
@export var style_hover_pressed: StyleBox

@export var style_disabled: StyleBox:
	set(value):
		style_disabled = value
		if disabled:
			_change_stylebox("disabled")

var signals_methods: Dictionary[Signal, Callable] = {
	mouse_entered: _on_mouse_entered,
	mouse_exited: _on_mouse_exited,
	focus_entered: _on_focus_entered,
	focus_exited: _on_focus_exited,
}

var _button_pressed := false

func _ready() -> void:
	if Engine.is_editor_hint():
		set_process_input(false)
	disabled = disabled # we need this
	if button_group: add_to_group(button_group)

func _disable(disable := true) -> void:
	if disable:
		_change_stylebox("disabled")
		if Engine.is_editor_hint(): return
		set_process_input(!disable)
		for sig in signals_methods:
			Utils.disconnect_if_possible(sig, signals_methods[sig])
	else:
		_change_stylebox("normal")
		if Engine.is_editor_hint(): return
		set_process_input(!disable)
		for sig in signals_methods:
			Utils.connect_if_possible(sig, signals_methods[sig])

func _on_focus_entered():
	_change_stylebox("focus")

func _on_focus_exited():
	_change_stylebox("normal")

func _on_mouse_entered():
	# prints("mouse_entered", name)
	if toggle_mode and button_pressed:
		_change_stylebox("hover_pressed")
	else: _change_stylebox("hover")
	
func _on_mouse_exited():
	# prints("mouse_exited", name)
	if toggle_mode and button_pressed:
		_change_stylebox("pressed")
	else: _change_stylebox("normal")

func _change_stylebox(button_style: StringName = "normal"):
	# prints("changed style to:", button_style)
	var stylebox := get_theme_stylebox(button_style, "Button")
	match button_style:
		"normal": stylebox = Utils.get_var(style_normal, stylebox)
		"focus": stylebox = Utils.get_var(style_focus, stylebox)
		"pressed": stylebox = Utils.get_var(style_pressed, stylebox)
		"hover": stylebox = Utils.get_var(style_hover, stylebox)
		"disabled": stylebox = Utils.get_var(style_disabled, stylebox)
		"hover_pressed": stylebox = Utils.get_var(style_hover_pressed, stylebox)

	add_theme_stylebox_override("panel", stylebox)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				if toggle_mode: button_pressed = !button_pressed
				else: button_pressed = true

			elif event.is_released():
				if !toggle_mode: button_pressed = false

func _toggle_group_if_needed(toggle: bool):
	if !button_group: return
	var buttons := get_tree().get_nodes_in_group(button_group)
	if buttons.size() <= 1: return
	for button: ButtonContainer in buttons:
		if button == self: continue
		if button.disabled: continue
		button._button_pressed = toggle
		button._set_button_pressed(toggle, false)

func _set_button_pressed(value: bool, _toggle_mode := toggle_mode):
	if _toggle_mode: _toggle_group_if_needed(!value)
	if value:
		_change_stylebox("pressed")
		if toggle_mode: toggled.emit(true)
		pressed.emit()
		# prints(name, "pressed")
	else:
		_change_stylebox("normal")
		if toggle_mode: toggled.emit(false)

func add_button_child(child: Control, parent: Control = self):
	parent.add_child(child)
	child.mouse_filter = Control.MOUSE_FILTER_IGNORE
	child.owner = parent