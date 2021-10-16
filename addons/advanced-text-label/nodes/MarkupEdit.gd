tool
extends TextEdit

export(Array, String, FILE, "*.json") var configs

func _ready() -> void:
	syntax_highlighting = true
	# clear_colors()
	_add_keywords_highlighting()

func switch_config(json_file:String, id:=0) -> void:
	clear_colors()
	configs[id] = json_file
	_add_keywords_highlighting()

func _add_keywords_highlighting() -> void:
	if configs.size() > 0:
		for json in configs:
			load_json_config(json)

func load_json_config(json: String) -> void:
	var content := get_file_content(json)
	var config : Dictionary = parse_json(content)

	var member_color := Color(0, 0, 0)

	for conf in config:
		read_conf_element(config, member_color, conf)

func read_conf_element(config : Dictionary, member_color: Color, conf):
	var c = config[conf]
	var color := Color(c["color"].to_lower())
	# prints(conf, color)

	match conf:
		"member":
			member_color = color
	
	read_region_if_exist(c, color)
	read_keywords_if_exist(c, color)

func read_region_if_exist(c, color:Color): 
	if c.has("region"):
		var r = c["region"]
		add_color_region(r[0], r[1], color)
	
func read_keywords_if_exist(c, color:Color):
	if c.has("keywords"):
		var keywords = c["keywords"]
		for k in keywords:
			add_keyword_color(k, color)

func get_file_content(path:String) -> String:
	var file = File.new()
	var error : int = file.open(path, file.READ)
	var content : = ""
	
	if error == OK:
		content = file.get_as_text()
		file.close()

	return content
