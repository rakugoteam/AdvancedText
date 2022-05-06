tool
extends CodeEdit

export var configs_dict := {
		"markdown": "res://addons/advanced-text/highlights/bbcode.json",
		"bbcode": "res://addons/advanced-text/highlights/bbcode.json",
		"renpy": "res://addons/advanced-text/highlights/renpy.json",
		"json": "res://addons/advanced-text/highlights/json.json",
		"gdscript": "res://addons/advanced-text/highlights/gdscript.json",
	}

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



