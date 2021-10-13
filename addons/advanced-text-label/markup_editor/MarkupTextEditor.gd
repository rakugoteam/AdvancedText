extends VBoxContainer

export var markups_options_nodepath : NodePath
export var layout_options_nodepath : NodePath
export var layout_nodepath : NodePath
export var edit_tabs_nodepath : NodePath
export var label_tabs_nodepath : NodePath

onready var markups_options : OptionButton = get_node(markups_options_nodepath)
onready var layout_options : OptionButton = get_node(layout_options_nodepath)
onready var layout : GridContainer = get_node(layout_nodepath)
onready var edit_tabs : TabContainer = get_node(edit_tabs_nodepath)
onready var label_tabs : TabContainer = get_node(label_tabs_nodepath)

var markup_id := 0
var text: = ""

func _ready():
	markups_options.connect("item_selected", self, "_on_option_selected")
	layout_options.connect("item_selected", self, "switch_layout")
	
	for ch in edit_tabs.get_children():
		ch.connect("text_changed", self, "update_text_preview")

func switch_layout(id := 0):
	layout.columns = id + 1

func update_text_preview(change_text := true):
	var e_tabs := edit_tabs.get_children()
	var e_id := edit_tabs.current_tab
	var current_edit_tab = e_tabs[e_id]

	if change_text:
		text = current_edit_tab.text
	else:
		current_edit_tab.text = text

	var l_tabs := label_tabs.get_children()
	var l_id := label_tabs.current_tab
	var current_label_tab = l_tabs[l_id]
	current_label_tab.markup_text = text

func _on_option_selected(id: int):
	if id != markup_id:
		
		edit_tabs.current_tab = id
		label_tabs.current_tab = id
		markup_id = id

		update_text_preview(text.empty())

