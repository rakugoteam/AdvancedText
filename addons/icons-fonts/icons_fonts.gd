@tool
# @singleton IconsFonts
extends EditorPlugin

const plugin_dir := "res://addons/icons-fonts/"
const icons_db := plugin_dir + "icons_fonts/IconsFonts.gd"
const inspector_plugin_path := plugin_dir + "inspector/font_icon_inspector.gd"
const sub_dir := "icon_finder/"
const icon_finder_dir := plugin_dir + sub_dir
const icon_finder_window_scene := icon_finder_dir + "IconFinderWindow.tscn"
const icon_finder_scene := icon_finder_dir + "IconFinder.tscn"

var command_palette := get_editor_interface().get_command_palette()
var editor_interface := get_editor_interface().get_base_control()
var icon_finder_window: Window
var icon_finder: Control
var popup_size := Vector2i(775, 400)
var inspector_plugin : EditorInspectorPlugin

var commands := [
	[	
		"Icon Finder Window",
		sub_dir + "icon_finder_window",
		show_icon_finder_window
	],
	[
		"Icon Finder Dock",
		sub_dir + "icon_finder_dock",
		add_to_dock
	],
	# todo uncomment when docs are ready!
	# [
	# 	"IconsFonts Help",
	# 	sub_dir + "icon_help",
	# 	help
	# ],
]

var is_docked: bool
var icon_finder_loaded: PackedScene
var icon_finder_window_loaded: PackedScene

func _enter_tree():
	add_autoload_singleton("IconsFonts", icons_db)
	# await IconsFonts.ready

	icon_finder_loaded = load(icon_finder_scene)
	icon_finder_window_loaded = load(icon_finder_window_scene)

	is_docked = ProjectSettings.get_setting(
		"application/addons/icon_finder/is_docked", true)
	if is_docked: await add_to_dock()

	for command: Array in commands:
		add_tool_menu_item(command[0], command[2])
		command_palette.add_command(command[0], command[1], command[2])
	
	inspector_plugin = preload(inspector_plugin_path).new()
	add_inspector_plugin(inspector_plugin)

func help():
	# todo update when docs are ready!
	# OS.shell_open("https://rakugoteam.github.io/material-icons-docs/")
	pass

func add_to_dock():
	if icon_finder_window:
		editor_interface.remove_child.call_deferred(icon_finder_window)
	
	await get_tree().create_timer(0.5).timeout
	icon_finder = icon_finder_loaded.instantiate()
	add_control_to_bottom_panel(icon_finder, "Icons Finder")
	if !icon_finder.is_node_ready(): await ready
	await icon_finder.setup()

func show_icon_finder_window():
	if icon_finder:
		remove_control_from_bottom_panel(icon_finder)
	
	if !icon_finder_window:
		icon_finder_window = icon_finder_window_loaded.instantiate()
		editor_interface.add_child.call_deferred(icon_finder_window)
		if !icon_finder_window.is_node_ready(): await ready

	icon_finder_window.theme = editor_interface.theme
	icon_finder_window.popup_centered(popup_size)

func _exit_tree():
	if inspector_plugin:
		remove_inspector_plugin(inspector_plugin)

	for command: Array in commands:
		remove_tool_menu_item(command[0])
		command_palette.remove_command(command[0])
	
	remove_autoload_singleton("IconsFonts")

	if icon_finder:
		remove_control_from_bottom_panel(icon_finder)
		icon_finder.queue_free()

	if icon_finder_window:
		editor_interface.remove_child.call_deferred(icon_finder_window)
		icon_finder_window.queue_free()
