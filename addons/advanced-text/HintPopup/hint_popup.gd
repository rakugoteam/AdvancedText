# singleton_name HintPopup
extends Window

var mouse_in := false

var text := "":
	set(value):
		if not is_node_ready(): return
		%AdvancedTextLabel._text = value

	get:
		if not is_node_ready(): return ""
		return %AdvancedTextLabel._text

func get_rect() -> Rect2:
	if not is_node_ready(): return Rect2()
	return %AdvancedTextLabel.get_rect()

func _ready():
	visibility_changed.connect(_on_popup)
	hide()

func _on_popup():
	if not visible: return
	var viewport_size := get_tree().root\
		.get_viewport().get_visible_rect().size
	var popup_size := size
	var new_position := position

	if new_position.x < 0: new_position.x = 0
	elif new_position.x + popup_size.x > viewport_size.x:
		new_position.x = int(viewport_size.x - popup_size.x)

	if new_position.y < 0: new_position.y = 0
	elif new_position.y + popup_size.y > viewport_size.y:
		new_position.y = int(viewport_size.y - popup_size.y)

	position = new_position 
	
	%ScrollContainer.scroll_vertical = 0
	%ScrollContainer.scroll_horizontal = 0
	%ScrollContainer.grab_focus()

func _on_mouse_exited() -> void:
	await get_tree().create_timer(0.2).timeout
	if mouse_in:
		mouse_in = false
		hide()

func _on_mouse_entered() -> void:
	mouse_in = true
