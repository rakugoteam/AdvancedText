tool
extends Node

const files_ram_path := "res://addons/advanced-text/MarkupTextEditor/ram.data"

var files_ram := {}
var f := File.new()
signal session_loaded

func _ready():
	if f.file_exists(files_ram_path):
		f.open_compressed(files_ram_path, File.READ)
		files_ram = f.get_var()
		f.close()

func _get(property):
	return files_ram[property] 

func _set(property, value):
	files_ram[property] = value
	save()

func save():
	print("save files ram")
	f.open_compressed(files_ram_path, File.WRITE)
	f.store_var(files_ram)
	f.close()