tool
extends TextEdit

export(Array, String, FILE, "*.json") var configs

func _ready() -> void:
	syntax_highlighting = true
	_add_keywords_highlighting()

func switch_config(json_file:String, id:=0) -> void:
	clear_colors()
	configs[id] = json_file
	_add_keywords_highlighting()

func _add_keywords_highlighting() -> void:
	if configs.size() > 0:
		for json in configs:
			load_json_config(json)

func add_json_keywords_colors(json: String, color: Color) -> void:
	var content : = get_file_content(json)
	var keywords : Array = parse_json(content)
	
	for keyword in keywords:
		add_keyword_color(keyword, color)

func load_json_config(json: String) -> void:
	var content : = get_file_content(json)
	var config : Dictionary = parse_json(content)

	var member_color := Color(0, 0, 0)

	for conf in config:
		read_conf_element(config, member_color, conf)

func read_conf_element(config : Dictionary, member_color: Color, conf):
	var c = config[conf]
	var color : Color = Color(c["color"])
	# prints(conf, color)

	match conf:
		"member":
			member_color = color
	
	read_sings_if_exist(c, color)

func read_sings_if_exist(c, color:Color): 
	if c.has("sings"):
		var s = c["sings"]
		add_color_region(s[0], s[1], color)

func get_file_content(path:String) -> String:
	var file = File.new()
	var error : int = file.open(path, file.READ)
	var content : = ""
	
	if error == OK:
		content = file.get_as_text()
		file.close()

	return content
