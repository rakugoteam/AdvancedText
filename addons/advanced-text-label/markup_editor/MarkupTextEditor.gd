extends VBoxContainer

export var markups_options_nodepath : NodePath
export var layout_options_nodepath : NodePath
export var layout_nodepath : NodePath
export var edit_tabs_nodepath : NodePath
export var advanced_text_label_nodepath : NodePath

onready var markups_options : OptionButton = get_node(markups_options_nodepath)
onready var layout_options : OptionButton = get_node(layout_options_nodepath)
onready var layout : GridContainer = get_node(layout_nodepath)
onready var edit_tabs : TabContainer = get_node(edit_tabs_nodepath)
onready var advanced_text_label = get_node(advanced_text_label_nodepath)

var markup_id := 0

func _ready():
	markups_options.connect("item_selected", self, "_on_option_selected")
	layout_options.connect("item_selected", self, "switch_layout")
	
	for ch in edit_tabs.get_children():
		ch.connect("text_changed", self, "_on_text_changed")

func switch_layout(id := 0):
	layout.columns = id + 1

func update_text_preview():
	var tabs := edit_tabs.get_children()
	var current_tab = tabs[markup_id]
	advanced_text_label.markup_text = current_tab.text

func _on_option_selected(id: int):
	if id != markup_id:
		
		edit_tabs.current_tab = id
		var markup = markups_options.get_item_text(id)
		advanced_text_label.markup = markup.to_lower()
		markup_id = id

		update_text_preview()

func _on_text_changed():
	var id = markups_options.get_selected_id()
	_on_option_selected(id)
	update_text_preview()
