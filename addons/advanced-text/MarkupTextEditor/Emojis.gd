tool
extends Button

var EmojisImport
var emojis_gd

func _ready():
	EmojisImport = preload("../emojis_import.gd")
	EmojisImport = EmojisImport.new()

	if EmojisImport.is_plugin_enabled():
		var emoji_panel : Popup = EmojisImport.get_emoji_panel()
		emoji_panel.visible = false
		add_child(emoji_panel)
		connect("pressed", emoji_panel, "popup_centered", [Vector2(450, 400)])
		show()
		return
	
	EmojisImport.free()
	hide()