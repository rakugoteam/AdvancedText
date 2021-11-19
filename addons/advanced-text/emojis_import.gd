tool
extends Object

const emoji_path = "res://addons/emojis-for-godot/emojis/emojis.gd"
const emoji_plugin_path = "res://addons/emojis-for-godot/plugin.cfg"
const emoji_panel = "res://addons/emojis-for-godot/EmojiPanel/EmojiPanel.tscn"
const emoji_icon_path ="res://addons/emojis-for-godot/icon.png"

var f := File.new()
var _emojis
var _emojis_plugin_enabled : = false

func is_emojis_plugin_enabled() -> bool:
	if not _emojis_plugin_enabled:
		var plugins : Array = ProjectSettings.get_setting("editor_plugins/enabled")
		_emojis_plugin_enabled = emoji_plugin_path in plugins

	if not _emojis_plugin_enabled:
		push_warning("emojis-for-godot are not enabled")
	
	return _emojis_plugin_enabled

func get_emojis():
	if _emojis:
		return _emojis

	if not is_emojis_plugin_enabled():
		return null

	if f.file_exists(emoji_path):
		_emojis = load(emoji_path)
		_emojis = _emojis.new()
		return _emojis

	else:
		push_warning("emojis.gd not found")
		return null

func get_emoji_panel() -> Node:
	if not is_emojis_plugin_enabled():
		return null
	
	var panel = load(emoji_panel)
	return panel.instance()

func get_icon() -> Texture:
	if not is_emojis_plugin_enabled():
		return null
	
	var icon = load(emoji_icon_path)
	return icon