@tool
class_name IconsFontsRender
extends RichTextLabel

@export_enum("MaterialIcons", "Emojis")
var icon_font := "MaterialIcons"

@export var start_size := 1065
@export var size_slider: Slider
@export var search_line_edit : LineEdit

func set_icons_size(value:int):
	IconsFonts.preview_size = value
	set("theme_override_font_sizes/normal_font_size", value)

func get_font_data() -> Dictionary:
	var data := {}
	match icon_font:
		"MaterialIcons": data =  IconsFonts.material_icons
		"Emojis": data = IconsFonts.emojis
		_: text = "Unsupported IconsFont %s" % icon_font

	return data

func get_icon(key:String) -> String:
	match icon_font:
		"MaterialIcons": return IconsFonts.get_icon_char("MaterialIcons", key)
		"Emojis": return str(IconsFonts.emojis[key])

	return ""

func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if visible:
		set_icons_size(IconsFonts.preview_size)
		update_table(search_line_edit.text)

func setup():
	set_meta_underline(false)
	set_icons_size(IconsFonts.preview_size)

func update_table(filter := ""):
	var table = "[table={columns}, {inline_align}]"
	var columns := int(size.x / IconsFonts.preview_size) + 1
	if columns <= 10:
		# size.x on start gives me 8 and slider.value is 16, so columns equals 1
		# so I add new fallback var start_size = 1056,
		# which is size.x after when it works
		columns = int(start_size / IconsFonts.preview_size) + 1

	table = table.format({
		"columns": columns,
		"inline_align": INLINE_ALIGNMENT_CENTER
	})

	var data := get_font_data()
	if !data: return

	var cells := columns
	for key: String in data:
		if filter and filter.to_lower() not in key: continue
		cells -= 1
		if cells <= 0: cells = columns
		var link := "[url={link}]{icon}[/url]"
		var icon := get_icon(key)
		link = link.format({"link": key, "icon": icon})

		var cell := "[cell]{link}[/cell]"
		table += cell.format({"link": link})

	cells = abs(cells)
	while cells > columns:
		cells -= 1

	if cells > 0:
		for c in cells:
			table += "[cell] [/cell]"

	table += "[/table]"
	parse_bbcode(table)
