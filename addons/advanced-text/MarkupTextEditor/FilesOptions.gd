extends VBoxContainer

export (NodePath) onready var parent = get_node(parent) as Control
export (NodePath) onready var new_file_button = get_node(new_file_button) as Button
export (NodePath) onready var open_file_button = get_node(open_file_button) as Button
export (NodePath) onready var save_file_button = get_node(save_file_button) as Button
export (NodePath) onready var save_file_as_button = get_node(save_file_as_button) as Button
export (NodePath) onready var files_box = get_node(files_box) as VBoxContainer
export (NodePath) onready var file_dialog = get_node(file_dialog) as FileDialog

export var file_dialog_size := Vector2(700, 500)
export var file_tab_scene : PackedScene

var text: = ""
var saving_as_mode := false
var files_ram := {}
var files_boxes := {}
var current_file_path := ""
var current_file_data := {}
var last_file_data := {}
var paths_dir := {}

var f := File.new()
var b_group := ButtonGroup.new()

const files_ram_path := "res://addons/advanced-text/MarkupTextEditor/ram.data"


func _ready():
	# new_file_button.connect("pressed", self, "_on_new_file_pressed")
	open_file_button.connect("pressed", self, "_on_open_file_pressed")
	# save_file_button.connect("pressed", self, "_on_save_file_pressed")
	save_file_as_button.connect("pressed", self, "_on_save_file_as_pressed")

func _on_file_open_pressed():
	file_dialog.mode = FileDialog.MODE_OPEN_FILES
	file_dialog.popup_centered(file_dialog_size)

func _on_file_save_as_pressed():
	file_dialog.mode = FileDialog.MODE_SAVE_FILE
	file_dialog.popup_centered(file_dialog_size)

func _on_file_selected(file_path:String):
	match file_dialog.mode:
		FileDialog.MODE_OPEN_FILES:
			# print("open file", file_path)
			_on_file_open(file_path)

		FileDialog.MODE_SAVE_FILE:
			var f_data : Dictionary = current_file_data
			if saving_as_mode:
				if f_data["path"] == file_path:
					saving_as_mode = false
				
				else:
					_on_file_open(file_path, f_data["text"])

			_on_file_save_button_pressed()

func _on_files_selected(file_paths:Array):
	print("open files", file_paths)
	for file_path in file_paths:
		_on_file_open(file_path)

func _on_file_open(file_path:String, modified_text := ""):
	if file_path.empty():
		return

	if current_file_path == file_path:
		return
	
	print_debug("open file ", file_path)
	var file_name = file_path.get_file()
	var file_ext = file_path.get_extension()
	
	# if file is already open so just switch to it
	if file_path in paths_dir.keys():
		# add switching to file
		print_debug("file already open")
		var f_tab_button = paths_dir[file_path].get_node("FileButton")
		print_debug("switch to tab ", f_tab_button.text)
		f_tab_button.emit_signal("pressed")
		return

	print("open not opened file", file_path)

	var f_tab = file_tab_scene.instance()
	f_tab.name = file_name

	var f_button : Button = f_tab.get_node("FileButton")
	f_button.text = file_name
	files_box.add_child(f_tab)
	f_button.group = b_group
	f_button.pressed = true
	f_button.connect("pressed", self, "_on_file_button_pressed", [f_tab])

	var f_close_button : Button = f_tab.get_node("CloseButton")
	f_close_button.connect("pressed", self, "_on_file_close_button_pressed", [f_tab])
	f_close_button.text = ""
	f_close_button.icon = get_icon("Close", "EditorIcons")

	var f_modified_icon : TextureRect = f_tab.get_node("ModifiedIcon")
	f_modified_icon.texture = get_icon("Edit", "EditorIcons")
	f_modified_icon.hide()

	var data := ""
	
	if modified_text:
		f_modified_icon.show()
		data = text
	
	elif f.file_exists(file_path):
		f.open(file_path, File.READ)
		data = f.get_as_text()
		f.close()

	var f_data = {
		"f_button": f_button,
		"file_name": file_name,
		"file_ext": file_ext,
		"path": file_path,
		"text": data,
		"modified": false,
		"modified_icon": f_modified_icon,
	}

	paths_dir[file_path] = f_tab
	files_ram[f_tab] = f_data
	files_boxes[file_name] = f_tab
	_update_file_data(f_data, file_path)

	save_files_ram()

	f_button.emit_signal("pressed")

func save_files_ram():
	print("save files ram")
	f.open_compressed(files_ram_path, File.WRITE)
	var data_to_save := {}

	for f_tab in files_ram:
		var f_data = files_ram[f_tab]
		data_to_save[f_data["file_name"]] = {}
		data_to_save[f_data["file_name"]]["path"] = f_data["path"]

		var modified : bool = f_data["modified"]
		data_to_save[f_data["file_name"]]["modified"] = modified

		if modified:
			data_to_save[f_data["file_name"]]["text"] = f_data["text"]
	
	f.store_var(data_to_save)
	f.close()

func _update_file_data(f_data:Dictionary, file_path:String):
	if last_file_data == f_data:
		return
	
	last_file_data = f_data

	if file_path == current_file_path:
		return
	
	current_file_path = file_path

	print("load file data to ram")
	var b : Button = f_data["f_button"]
	var t = parent.toolbar
	t.file_name = f_data["file_name"]
	match f_data["file_ext"]:
		"md":
			_set_markup_id(0)
			b.icon = MarkdownIcon
			file_icon.texture = MarkdownIcon

		"rpy":
			_set_markup_id(1)
			b.icon = RpyIcon
			file_icon.texture = RpyIcon

		"txt":
			_set_markup_id(2)
			markups_options.disabled = false
			b.icon = get_icon("TextFile", "EditorIcons")

		_:
			_set_markup_id(3)
			markups_options.disabled = false
			b.icon = get_icon("TextFile", "EditorIcons")

	text = f_data["text"]
	update_text_preview(get_current_edit_tab(), false)
	current_file_data = f_data
	file_save_button.disabled = not f_data["modified"]
	print("file loaded")

func _on_file_button_pressed(file_box: Node):
	var f_data = files_ram[file_box]
	var file_path = f_data["path"]
	_update_file_data(f_data, file_path)

func _on_file_close_button_pressed(file_box: Node):
	var f_data = files_ram[file_box]
	var f_button = f_data["f_button"]
	# todo add ask for save if text was changed
	files_box.remove_child(file_box)
	files_boxes.erase(file_box.name)
	files_ram.erase(file_box)

	if files_ram.empty():
		text = ""
		update_text_preview(get_current_edit_tab(), false)
		_on_files_toggle(true)

	else:
		_on_file_button_pressed(files_ram.keys().back())

	file_box.queue_free()
	save_files_ram()

func _on_new_file_button_pressed():
	var id := files_ram.size()
	var file_name = "NewFile " + str(id)
	_on_file_open(file_name)

func _on_file_save_button_pressed():
	var f_data : Dictionary = current_file_data
	var file_path : String = f_data["path"]
	var _text : String = f_data["text"]

	if file_path.begins_with("NewFile"):
		_on_file_save_as_button_pressed()
		return

	f.open(file_path, File.WRITE)
	f.store_string(_text)
	f.close()

	f_data["modified"] = false
	_update_file_data(f_data, file_path)
	save_files_ram()




