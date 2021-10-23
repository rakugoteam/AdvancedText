tool
extends Object

var f := File.new()
var _emojis
const emoji_path = "res://addons/emojis-for-godot/emojis/emojis.gd"
const emoji_plugin_path = "res://addons/emojis-for-godot/plugin.cfg"

func get_emojis():
	if _emojis:
		return _emojis

	var plugins : Array = ProjectSettings.get_setting("editor_plugins/enabled")
	var plugin_enabled := emoji_plugin_path in plugins

	if not plugin_enabled:
		push_warning("emojis-for-godot are not enabled")
		return null

	if f.file_exists(emoji_path):
		_emojis = load(emoji_path)
		_emojis = _emojis.new()
		return _emojis

	else:
		push_warning("emojis.gd not found")
		return null
