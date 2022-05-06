tool
extends Button

var IconsImport
var icons_gd

func _ready():
	IconsImport = preload("res://addons/advanced-text/material_icons_import.gd")
	IconsImport = IconsImport.new()

	if IconsImport.is_plugin_enabled():
		var icon_panel : Popup = IconsImport.get_icons_panel()
		icon_panel.visible = false
		add_child(icon_panel)
		connect("pressed", icon_panel, "popup_centered", [Vector2(450, 400)])
		show()
		return
	
	IconsImport.free()
	hide()
