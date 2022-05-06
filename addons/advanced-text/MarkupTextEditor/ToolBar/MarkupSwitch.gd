tool
extends OptionButton

func _ready():
	connect("item_selected", self, "set_markup")

func set_markup(mode):
	var txt_mode = get_item_text(mode)
	EditorHelper.set_markup(txt_mode)