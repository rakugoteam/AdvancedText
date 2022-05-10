tool
extends Node

const files_ram_path := "res://addons/advanced-text/MarkupTextEditor/ram.data"

var files_ram := {}
var mode := "file"
var markups := {"markdown":0, "renpy":1, "bbcode":2}
var current_markup := "markdown"
var f := File.new()
var current_f_data := {}

signal session_loaded
signal selected_mode(mode)
signal selected_markup(markup)
signal preview_toggled(toggle)
signal selected_preview(mode)
signal selected_file(file_data)
signal update_preview(file_data)

func _ready():
	if f.file_exists(files_ram_path):
		f.open_compressed(files_ram_path, File.READ)
		files_ram = f.get_var()
		f.close()

func save():
	print("save files ram")
	f.open_compressed(files_ram_path, File.WRITE)
	f.store_var(files_ram)
	f.close()

func get_current_markup():
	return markups[current_markup]

func set_markup(markup):
	current_markup = markup
	emit_signal("selected_mode", current_markup)

func select_file(f_data:Dictionary):
	current_f_data = f_data
	emit_signal("selected_file", current_f_data)

func update_data(key:String, value:String):
	current_f_data[key] = value
	emit_signal("update_preview", current_f_data)
