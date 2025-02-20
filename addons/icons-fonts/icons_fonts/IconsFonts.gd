@tool
# @singleton IconsFonts 
extends Node

const docked_setting_path := "application/addons/icon_finder/is_docked"
const prev_size_setting_path := "application/addons/icon_finder/preview_size"

## Material Icons
const material_icons_json := "res://addons/icons-fonts/icons_fonts/MaterialIcons/icons.json"
const material_icons_font := "res://addons/icons-fonts/icons_fonts/MaterialIcons/material_design_icons.ttf"

## Emojis
const emojis_json := "res://addons/icons-fonts/icons_fonts/emojis/emojis.json"
const emojis_font := "res://addons/icons-fonts/icons_fonts/emojis/NotoColorEmoji.ttf"

signal font_loaded(font_name: String)
var material_icons := {}
var emojis := {}

static var is_docked: bool:
	set(value):
		ProjectSettings.set_setting(docked_setting_path, value)
	get:
		return ProjectSettings.get_setting(docked_setting_path, true)

static var preview_size: int:
	set(value):
		ProjectSettings.set_setting(prev_size_setting_path, value)
	get:
		return ProjectSettings.get_setting(prev_size_setting_path, 24)

func _ready():
	var json: JSON
	var content: String
	if Engine.is_editor_hint():
		json = load(material_icons_json)
		init_material_icons_dict(json.data)
	else:
		json = JSON.new()
		content = get_file_content(material_icons_json)
		if json.parse(content) == OK:
			init_material_icons_dict(json.data)
	
	if Engine.is_editor_hint():
		json = load(emojis_json)
		init_emoji_dictionaries(json.data)
	else:
		json = JSON.new()
		content = get_file_content(emojis_json)
		if json.parse(content) == OK:
			init_emoji_dictionaries(json.data)
	
func get_file_content(path: String) -> String:
	var file := FileAccess.open(path, FileAccess.READ)
	var content := ""
	
	if file.get_error() == OK:
		content = file.get_as_text()
		file.close()

	return content

func init_material_icons_dict(data: Dictionary):
	material_icons = data
	for id in data:
		var hex = material_icons[id]
		material_icons[id] = ("0x" + hex).hex_to_int()
		# prints(id, material_icons[id])
	
	prints("FontsIcons: MaterialIcons loaded")
	font_loaded.emit("MaterialIcons")

func init_emoji_dictionaries(dict: Dictionary):
	for emoji in dict:
		var keys = dict[emoji]
		for key in keys:
			emojis[key] = emoji
		
	prints("FontsIcons: Emojis loaded")
	font_loaded.emit("Emojis")

func get_icon_code(font: String, id: String) -> int:
	if "," in id:
		id = id.split(",")[0]
	
	match font:
		"MaterialIcons":
			if id in material_icons:
				return material_icons[id]
	
	push_warning("Icon '%s' in font %s not found." % [id, font])
	return 0

func get_emoji_unicode(id: String) -> String:
	if id in emojis:
		# prints(id, emojis[id])
		return emojis[id]

	push_warning("Emoji %s not found." % id)
	return ""

func get_icon_char(font: String, id: String) -> String:
		match font:
			"MaterialIcons":
				return char(get_icon_code(font, id))
			
			"Emojis":
				return get_emoji_unicode(id)
		
		return ""

## will parse text using:
##	-  parse_material_icons()
##	-  parse_emojis()
##	-  parse_game_icons()
func parse_text(text: String) -> String:
	text = parse_material_icons(text)
	text = parse_emojis(text)
	# todo add game-icons parse
	return text

## will replace [mi:icon_name] with [font=MaterialIcons]icon_char[/font]
func parse_material_icons(text: String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[mi:(.*?)\\]")
	var x = regex.search(text)
	while x != null:
		var icon = x.get_string(1)
		var char = get_icon_char("MaterialIcons", icon)
		var r = "[font={font}]{char}[/font]"
		r = r.format({"font": material_icons_font, "char": char})

		if icon.split(",").size() > 1:
			var size = icon.split(",")[1]
			var s = "[font_size={size}]{r}[/font_size]"
			r = s.format({"size": size, "r": r})

		text = text.replace(x.get_string(), r)
		x = regex.search(text)
	
	return text

func get_emoji_bbcode(id: String, size := 0) -> String:
	var emoji := get_icon_char("Emojis", id)
	if !emoji: return ""

	var bbcode := "[font=%s]%s[/font]" % [emojis_font, emoji]
	if size <= 0: return bbcode
	
	return "[font_size=%s]%s[/font_size]" % [size, bbcode]

## will replace :emoji_name: with [font=Emojis]emoji_char[/font]
func parse_emojis(text: String):
	var re = RegEx.new()
	re.compile(":[\\w\\d]+(,\\s*\\d+)?:")
	var result = re.search(text)
	while result != null:
		var temp := result.get_string()
		temp = temp.replace(":", "")
		var emoji := temp
		var size := 0

		if "," in temp:
			var splited := temp.split(",")
			emoji = splited[0]
			size = int(splited[1].replace(" ", ""))

		var replacement := get_emoji_bbcode(emoji, size)
		text = text.replace(result.get_string(), replacement)
		result = re.search(text)
	
	return text
