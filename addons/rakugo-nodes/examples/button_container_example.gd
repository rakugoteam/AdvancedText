@tool
extends ButtonContainer

@onready var label: Label = $Label


func _on_toggled(value: bool) -> void:
	if value: label.text = "Pressed"
	else: label.text = "UnPressed"
