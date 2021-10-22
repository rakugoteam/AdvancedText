tool
extends Control

export var markups_options_nodepath : NodePath
export var edit_tabs_nodepath : NodePath
export var preview_tabs_nodepath : NodePath
export var preview_toggle_nodepath : NodePath
export var help_button_nodepath : NodePath
export var help_tabs_nodepath : NodePath
export var help_popup_nodepath : NodePath

onready var markups_options : OptionButton = get_node(markups_options_nodepath)
onready var edit_tabs : TabContainer = get_node(edit_tabs_nodepath)
onready var preview_tabs : TabContainer = get_node(preview_tabs_nodepath)
onready var preview_toggle : CheckButton = get_node(preview_toggle_nodepath)
onready var help_button : Button = get_node(help_button_nodepath)
onready var help_tabs : TabContainer = get_node(help_tabs_nodepath)
onready var help_popup : WindowDialog = get_node(help_popup_nodepath)

var markup_id := 0
var text: = ""

func _ready():
	update_text_preview(get_current_edit_tab())
	markups_options.connect("item_selected", self, "_on_option_selected")
	preview_toggle.connect("toggled", self, "_on_toggle")
	help_button.connect("pressed", self, "_on_help_button_pressed")
	
	for ch in edit_tabs.get_children():
		ch.connect("text_changed", self, "update_text_preview", [ch, true])

func _on_toggle(toggled: bool):
	preview_tabs.visible = toggled

func get_current_edit_tab() -> TextEdit:
	var e_tabs := edit_tabs.get_children()
	var e_id := edit_tabs.current_tab
	return e_tabs[e_id]

func update_text_preview(caller:TextEdit, change_text := true):
	if not caller.visible:
		return
		
	var current_edit_tab := get_current_edit_tab()
	if change_text:
		text = current_edit_tab.text
	else:
		current_edit_tab.text = text

	var l_tabs := preview_tabs.get_children()
	var l_id := preview_tabs.current_tab
	var current_preview_tab = l_tabs[l_id]

	current_preview_tab.markup_text = text

func _on_option_selected(id: int):
	if id != markup_id:
		edit_tabs.current_tab = id
		preview_tabs.current_tab = id
		help_tabs.current_tab = id
		markup_id = id

		var current := get_current_edit_tab()
		update_text_preview(current, text.empty())

func _on_help_button_pressed():
	help_popup.window_title = markups_options.get_item_text(markup_id) + " Help"
	help_popup.popup_centered(Vector2(700, 500))
