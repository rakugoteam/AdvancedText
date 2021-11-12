extends Panel

export var tab_button_scene : PackedScene
export var text_view_scene : PackedScene

onready var tabs : TabContainer = $HSplitContainer/TabContainer
onready var tabs_box : VBoxContainer = $HSplitContainer/ScrollContainer/VBoxContainer

var current_text_view : AdvancedTextLabel

func _ready():
	current_text_view = tabs.get_current_tab_control()
	current_text_view.connect("meta_clicked", self, "_on_meta_clicked")

func _on_meta_clicked(meta:String):
	pass
