tool
extends VBoxContainer

export var file_box_scene : PackedScene

var b_group := ButtonGroup.new()
var f = File.new()

var open_files := {}

func _ready():
	# maybe it should be called in other way as seesion_loaded can be called before ui is ready
	EditorHelper.connect("session_loaded", self, "_on_session_loaded")

func _on_session_loaded():
	for file in EditorHelper.files_ram:
		pass

func new_file_tab(file_path : String):
	if file_path.empty():
		return

	print_debug("open file ", file_path)
	var file_name = file_path.get_file()
	var file_ext = file_path.get_extension()

	if file_path in open_files.keys():
		print_debug("file already open")
		return
	
	var f_box = file_box_scene.instance()
	f_box.name = file_name

	var f_button : Button = f_box.get_node("FileButton")
	f_button.text = file_name
	add_child(f_box)
	f_button.group = b_group
	f_button.pressed = true
	f_button.connect("pressed", self, "_on_file_button_pressed", [f_box])

	var f_close_button : Button = f_box.get_node("CloseButton")
	f_close_button.connect("pressed", self, "_on_file_close_button_pressed", [f_box])
	f_close_button.text = ""
	f_close_button.icon = get_icon("Close", "EditorIcons")

	var f_modified_icon : TextureRect = f_box.get_node("ModifiedIcon")
	f_modified_icon.texture = get_icon("Edit", "EditorIcons")
	f_modified_icon.hide()

	var text := ""
	if f.file_exists(file_path):
		f.open(file_path, File.READ)
		text = f.get_as_text()
		f.close()

	var f_data = {
		"f_button": f_button,
		"file_name": file_name,
		"file_ext": file_ext,
		"path": file_path,
		"text": text,
		"modified": false,
		"modified_icon": f_modified_icon,
	}

	open_files[file_path] = f_box
	EditorHelper.files_ram[f_box] = f_data
