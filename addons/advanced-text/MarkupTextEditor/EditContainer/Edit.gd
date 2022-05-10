tool
extends CodeEdit

export var configs_dict := {
		"markdown": "res://addons/advanced-text/highlights/bbcode.json",
		"bbcode": "res://addons/advanced-text/highlights/bbcode.json",
		"renpy": "res://addons/advanced-text/highlights/renpy.json",
		"json": "res://addons/advanced-text/highlights/json.json",
		"gdscript": "res://addons/advanced-text/highlights/gdscript.json",
	}

func _ready():
	TextEditorHelper.connect("selected_markup", self, "_on_markup_selected")
	TextEditorHelper.connect("selected_file", self, "_on_file_selected")
	connect("text_changed", self, "_on_text_changed")

func _on_markup_selected(markup:String):
	if markup == "plain":
		clear_colors()
		return
		
	var lang = [markup.to_lower()]
	change_configs(lang)

func change_configs(langues: Array) -> void:
	clear_colors()
	
	configs = []
	for langue in langues:
		configs.append(configs_dict[langue])

	_add_keywords_highlighting()

func _on_file_selected(f_data: Dictionary):
	text = f_data["text"]

func _on_text_changed():
	TextEditorHelper.update_data("text", text)
	


