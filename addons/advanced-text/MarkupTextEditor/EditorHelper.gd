tool
extends Node

const files_ram_path := "res://addons/advanced-text/MarkupTextEditor/ram.data"

var files_ram := {}
var mode := "file"
var markups := {"markdown":0, "renpy":1, "bbcode":2}
var current_markup := "markdown"
var f := File.new()

signal session_loaded
signal selected_mode(mode)
signal selected_markup(markup)
signal preview_toggled(toggle)
signal selected_preview(mode)

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