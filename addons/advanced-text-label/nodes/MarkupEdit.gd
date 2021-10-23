tool
extends TextEdit
class_name MarkupEdit

var EmojisImport
export var color_colors := true
export(Array, String, FILE, "*.json") var configs

func _ready() -> void:
	EmojisImport = preload("../emojis_import.gd")
	EmojisImport = EmojisImport.new()
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

	for conf in config:
		read_conf_element(config, conf)

func read_conf_element(config : Dictionary, conf):
	var c = config[conf]
	var color := Color(c["color"].to_lower())

	match conf:
		"emojis":
			load_emojis_if_exists(color)

	read_region_if_exist(c, color)
	read_keywords_if_exist(c, color)

func load_emojis_if_exists(color: Color) -> void:
	var emojis_gd = EmojisImport.get_emojis()
	if emojis_gd:
		for e in emojis_gd.emojis.keys():
			add_keyword_color(e, color)

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
