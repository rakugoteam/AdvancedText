extends Control

var EmojisImport
var emojis_gd

export var AdvancedTextLabelIcon : Texture
export var CodeEditIcon : Texture
export var MarkdownIcon : Texture
export var RpyIcon : Texture
export var BBCodeIcon : Texture

export var file_box_scene : PackedScene

export (NodePath) onready var markups_options = get_node(markups_options) as OptionButton
export (NodePath) onready var edit_tabs = get_node(edit_tabs) as TabContainer
export (NodePath) onready var preview_tabs = get_node(preview_tabs) as TabContainer
export (NodePath) onready var preview_toggle = get_node(preview_toggle) as CheckButton
export (NodePath) onready var help_button = get_node(help_button) as Button
export (NodePath) onready var help_tabs = get_node(help_tabs) as TabContainer
export (NodePath) onready var help_popup = get_node(help_popup) as WindowDialog
export (NodePath) onready var emoji_button = get_node(emoji_button) as Button
export (NodePath) onready var selected_node_toggle = get_node(selected_node_toggle) as CheckBox
export (NodePath) onready var files_tab = get_node(files_tab) as VBoxContainer
export (NodePath) onready var files_toggle = get_node(files_toggle) as CheckBox
export (NodePath) onready var file_name_label = get_node(file_name_label) as Label
export (NodePath) onready var file_icon = get_node(file_icon) as TextureRect
export (NodePath) onready var file_modified_icon = get_node(file_modified_icon) as TextureRect
export (NodePath) onready var files_box = get_node(files_box) as VBoxContainer
export (NodePath) onready var new_file_button = get_node(new_file_button) as Button
export (NodePath) onready var file_open_button = get_node(file_open_button) as Button
export (NodePath) onready var file_popup = get_node(file_popup) as FileDialog
export (NodePath) onready var file_save_button = get_node(file_save_button) as Button
export (NodePath) onready var file_save_as_button = get_node(file_save_as_button) as Button

var markup_id := 0
var text: = ""
var editor : EditorInterface
var last_selected_node : Node
var saving_as_mode := false
const markups_str := ["markdown", "renpy", "bbcode"]

var files_ram := {}
var files_boxes := {}
var current_file_path := ""
var current_file_data := {}
var last_file_data := {}
var paths_dir := {}

var f := File.new()
var b_group := ButtonGroup.new()

const files_ram_path := "res://addons/advanced-text/MarkupTextEditor/ram.data"

func import_emojis():
	EmojisImport = preload("../emojis_import.gd")
	EmojisImport = EmojisImport.new()

	if EmojisImport.is_plugin_enabled():
		var emoji_panel : Popup = EmojisImport.get_emoji_panel()
		emoji_panel.visible = false
		add_child(emoji_panel)
		emoji_button.connect("pressed", emoji_panel, "popup_centered", [Vector2(450, 400)])
		emoji_button.show()
	else:
		EmojisImport.free()

func load_last_session(files_ram_path : String):
	f.open_compressed(files_ram_path, File.READ)
	var loaded_data : Dictionary = f.get_var()
	f.close()

	for data in loaded_data.values():
		var path : String = data["path"]
		var modified : bool = data["modified"]
		var _text := ""
		if modified:
			text = data["text"]
			_on_file_open(path, text)
		
		else:
			_on_file_open(path)
	
	files_tab.visible = true

func _ready():
	emoji_button.hide()
	_on_nodes_toggle(true)
	
	# emojis import if possible
	import_emojis()
		
	# load perviously edited files
	if f.file_exists(files_ram_path):
		load_last_session(files_ram_path)
		
	update_text_preview(get_current_edit_tab())

	markups_options.connect("item_selected", self, "_on_option_selected")

	self.connect("visibility_changed", self, "_on_visibility_changed")

	new_file_button.icon = get_icon("New", "EditorIcons")
	new_file_button.connect("pressed", self, "_on_new_file_button_pressed")

	file_open_button.icon = get_icon("Load", "EditorIcons")
	file_open_button.connect("pressed", self, "_on_file_open_button_pressed")

	file_save_button.icon = get_icon("Save", "EditorIcons")
	file_save_button.connect("pressed", self, "_on_file_save_button_pressed")

	file_save_as_button.icon = get_icon("Save", "EditorIcons")
	file_save_as_button.connect("pressed", self, "_on_file_save_as_button_pressed")

	file_popup.connect("file_selected", self, "_on_file_selected")
	file_popup.connect("files_selected", self, "_on_files_selected")

	file_modified_icon.texture = get_icon("Edit", "EditorIcons")
	file_modified_icon.hide()

	for ch in edit_tabs.get_children():
		ch.connect("text_changed", self, "update_text_preview", [ch, true])
		ch.connect("text_changed", self, "_on_text_changed", [ch])

func _on_visibility_changed():
	set_process(visible)

func _on_nodes_toggle(toggled:bool):
	last_file_data = current_file_data
	text = ""
	var tab = get_current_edit_tab()
	update_text_preview(tab, false)

	var last_selected_node = get_selected_node()

	if last_selected_node:
		_on_node_selected(last_selected_node)

	else:
		file_icon.texture = get_icon("NodeWarning", "EditorIcons")
		file_name_label.text = "None Node is Selected"

func _on_files_toggle(toggled:bool):
	files_tab.visible = toggled
	if last_file_data:
		_update_file_data(last_file_data, current_file_path)

	else:
		file_icon.texture = get_icon("New", "EditorIcons")
		file_name_label.text = "Unnamed Text File"

func _on_toggle(toggled: bool):
	preview_tabs.visible = toggled

func get_current_edit_tab() -> TextEdit:
	var e_tabs = edit_tabs.get_children()
	var e_id = edit_tabs.current_tab
	return e_tabs[e_id]

func update_text_preview(caller:TextEdit, text_from_edit_tab := true):
	if not caller.visible:
		return
		
	var current_edit_tab := get_current_edit_tab()
	if text_from_edit_tab:
		text = current_edit_tab.text
	else:
		current_edit_tab.text = text

	var l_tabs = preview_tabs.get_children()
	var l_id = preview_tabs.current_tab
	var current_preview_tab = l_tabs[l_id]

	current_preview_tab.markup_text = text

func _on_text_changed(caller:TextEdit):
	if !caller.visible:
		return

	if current_file_data:
		current_file_data["text"] = caller.text
		current_file_data["modified"] = true
		current_file_data["modified_icon"].show()
		file_modified_icon.show()
		file_save_button.disabled = false
		
	if last_selected_node:
		if last_selected_node is AdvancedTextLabel:
			last_selected_node.markup_text = caller.text
		
		if last_selected_node is RichTextLabel:
			if last_selected_node.bbcode_enabled:
				last_selected_node.markup_text = caller.text
			else:
				last_selected_node.text = caller.text
		
		if last_selected_node is CodeEdit:
			last_selected_node.text = caller.text

func _on_option_selected(id: int):
	if id != markup_id:
		_set_markup_id(id)
		var current := get_current_edit_tab()
		update_text_preview(current, text.empty())

func _set_markup_id(id: int):
	if id == markup_id:
		return
		
	markup_id = id
	markups_options.selected = id
	edit_tabs.current_tab = id
	preview_toggle.visible = id != 3
	preview_tabs.visible = id != 3
	help_button.visible = id != 3

	if id == 3:
		return

	preview_tabs.current_tab = id
	help_tabs.current_tab = id
	
	if last_selected_node:
		if last_selected_node is AdvancedTextLabel:
			last_selected_node.markup = markups_str[id]

func _on_help_button_pressed():
	var m = markups_options.get_item_text(markup_id) 
	help_popup.window_title = m + " Help"
	help_popup.popup_centered(Vector2(700, 500))

func toggle_nodes_mode():
	selected_node_toggle.pressed = true
	_on_nodes_toggle(true)

func toggle_files_mode():
	files_toggle.pressed = true
	_on_files_toggle(true)

func get_selected_node() -> Node:
	if editor == null:
		return null

	var s = editor.get_selection()
	var selected_nodes = s.get_selected_nodes()

	# print("selected_nodes ", selected_nodes.size())
	if selected_nodes.size() == 0:
		return null

	if last_selected_node != selected_nodes[0]:
		return selected_nodes[0]
	else:
		return null

var mouse_button_released = true
var mouse_button_just_pressed = false

func _process(delta: float) -> void:
	if not editor:
		return
	
	# there is no selected node changed signal
	# so I need to check if the selected node changed in _process()
	# also adding InputMap.add_action() doesn't work in editor
	if Input.is_mouse_button_pressed(BUTTON_LEFT):
		if mouse_button_released:
			mouse_button_just_pressed = true
			mouse_button_released = false
		else:
			mouse_button_just_pressed = false
	
	else:
		mouse_button_released = true
		mouse_button_just_pressed = false
		
	if !mouse_button_just_pressed:
		return

	var selected_node = get_selected_node()
	if !selected_node:
		return
	
	if selected_node == last_selected_node:
		return

	last_selected_node = selected_node
	preview_toggle.pressed = true
	preview_tabs.visible = true
	file_name_label.text = selected_node.name
	toggle_nodes_mode()
	_on_node_selected(selected_node)

	# print("type", last_selected_node.get_class())

func _on_node_selected(node: Node):
	if node is AdvancedTextLabel:
		var _markup_str_id = node.markup
		
		if _markup_str_id == "default":
			_markup_str_id = ProjectSettings.get_setting("addons/advanced_text/markup")

		var _markup_id = markups_str.find(_markup_str_id)
		markups_options.disabled = false
		_set_markup_id(_markup_id)

		if node.markup_text_file:
			toggle_files_mode()
			print("loading text file from node")
			_on_file_open(node.markup_text_file)
		
		else:
			text = node.markup_text
			update_text_preview(get_current_edit_tab(), false)
			file_icon.texture = AdvancedTextLabelIcon
		
	elif node is RichTextLabel:
		_set_markup_id(2)
		markups_options.disabled = true
		text = node.bbcode_text
		update_text_preview(get_current_edit_tab(), false)
		file_icon.texture = get_icon("RichTextLabel", "EditorIcons")
	
	elif node is CodeEdit:
		markups_options.disabled = true
		preview_toggle.pressed = false
		preview_tabs.visible = false

		if node.text_file:
			toggle_files_mode()
			_on_file_open(node.text_file)
		
		else:
			text = node.text
			update_text_preview(get_current_edit_tab(), false)
			file_icon.icon = CodeEditIcon
			file_icon.texture = get_icon("TextEdit", "EditorIcons")
		
	else:
		file_icon.texture = get_icon("NodeWarning", "EditorIcons")
		file_name_label.text = "Unsupported Node Type"

func _on_file_open_button_pressed():
	file_popup.mode = FileDialog.MODE_OPEN_FILES
	file_popup.popup_centered(Vector2(700, 500))

func _on_file_save_as_button_pressed():
	file_popup.mode = FileDialog.MODE_SAVE_FILE
	saving_as_mode = true
	file_popup.popup_centered(Vector2(700, 500))

func _on_file_selected(file_path:String):
	# var file_path = file_popup.current_path
	match file_popup.mode:
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

	var f_box = file_box_scene.instance()
	f_box.name = file_name

	var f_button : Button = f_box.get_node("FileButton")
	f_button.text = file_name
	files_box.add_child(f_box)
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

	paths_dir[file_path] = f_box
	files_ram[f_box] = f_data
	files_boxes[file_name] = f_box
	_update_file_data(f_data, file_path)

	save_files_ram()

	f_button.emit_signal("pressed")

func save_files_ram():
	print("save files ram")
	f.open_compressed(files_ram_path, File.WRITE)
	var data_to_save := {}

	for f_box in files_ram:
		var f_data = files_ram[f_box]
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

	markups_options.disabled = true
	var b : Button = f_data["f_button"]
	file_name_label.text = f_data["file_name"]
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
	