tool
extends ColorPickerButton

func _ready():
	connect("color_changed", self, "_on_color_changed")

func _on_color_changed(color: Color):
	OS.clipboard = "#"+color.to_html()
