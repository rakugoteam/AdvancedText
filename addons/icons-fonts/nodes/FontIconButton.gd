@tool
@icon("res://addons/icons-fonts/nodes/FontIconButton.svg")

# todo add description and docs links when ready
class_name FontIconButton
extends ButtonContainer

@export_group("Layout", "layout_")
@export_enum("Label-Icon", "Icon-Label")
var layout_order := "Label-Icon":
	set(value):
		layout_order = value
		if !is_node_ready(): await ready
		_set_order(value)

@export var layout_vertical := true:
	set(value):
		layout_vertical = value
		if !is_node_ready(): await ready
		_box.vertical = value

@export_group("Icon", "icon_")
@export var icon_settings := FontIconSettings.new():
	set(value):
		icon_settings = value
		if !is_node_ready(): await ready
		_font_icon.icon_settings = value

@export_group("Label", "label_")
@export var label_text := "":
	set(value):
		label_text = value
		if !is_node_ready(): await ready
		_label.text = label_text

@export var label_settings := LabelSettings.new():
	set(value):
		label_settings = value
		if !is_node_ready(): await ready
		_label.label_settings = label_settings

@export var button_margin := 5:
	set(value):
		button_margin = value
		if !is_node_ready(): await ready
		var margins := [
			"margin_top", "margin_left",
			"margin_bottom", "margin_right"
		]
		for margin in margins:
			_margins.add_theme_constant_override(margin, button_margin)

var _font_icon: FontIcon
var _label: Label
var _box: BoxContainer
var _margins: MarginContainer

func _get_lay_dict() -> Dictionary:
	return {
		"Label": _label,
		"Icon": _font_icon,
	}

func _ready():
	for ch: Control in get_children():
		ch.queue_free()

	var empty_style := StyleBoxEmpty.new()
	_box = BoxContainer.new()
	_font_icon = FontIcon.new()
	_font_icon.add_theme_stylebox_override("normal", empty_style)

	_label = Label.new()
	_label.add_theme_stylebox_override("normal", empty_style)
	self.layout_order = layout_order

	_margins = MarginContainer.new()
	_margins.add_child(_box)
	add_child(_margins)

	Utils.connect_if_possible(
		label_settings, "changed", _on_label_settings_changed)
	
	Utils.connect_if_possible(
		icon_settings, "changed", _on_icon_settings_changed)

func _on_label_settings_changed():
	if label_settings != _label.label_settings:
		_label.label_settings = label_settings

func _on_icon_settings_changed():
	if icon_settings != _font_icon.icon_settings:
		_font_icon.icon_settings = icon_settings
	Utils.connect_if_possible(
		icon_settings, "changed",
		_font_icon._on_icon_settings_changed)

func _clear_box():
	if _box.get_child_count() == 0: return
	for ch: Control in _box.get_children():
		_box.remove_child(ch)

func _set_order(order:String):
	_clear_box()
	await get_tree().create_timer(0.2).timeout
	_apply_layout(_crate_layout(order))

func _crate_layout(order:String) -> Array[Control]:
	var layout: Array[Control] = []
	var order_split := order.split("-")
	var dict := _get_lay_dict()
	for con in order_split:
		layout.append(dict[con])
	return layout

func _apply_layout(layout: Array[Control]):
	for control: Control in layout:
		if control.get_parent() == _box: continue
		_box.add_child(control)
		if control is FontIcon:
			control.size_flags_horizontal\
				= Control.SIZE_SHRINK_CENTER
