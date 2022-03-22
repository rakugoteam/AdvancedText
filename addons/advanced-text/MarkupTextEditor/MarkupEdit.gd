extends CodeEdit

export var configs_sets := {
		"markdown": ["res://addons/advanced-text/highlights/bbcode.json"],
		"bbcode": ["res://addons/advanced-text/highlights/bbcode.json"],
		"renpy": ["res://addons/advanced-text/highlights/renpy.json"],
		"json": ["res://addons/advanced-text/highlights/json.json"],
		"gdscript": ["res://addons/advanced-text/highlights/gdscript.json"],
	}

func change_markup(markup:String):
	clear_colors()
	configs = configs_sets[markup]
	_add_keywords_highlighting()
