extends Timer

var root: Node
var raku: Node

func _ready():
	if Engine.is_editor_hint():
		root = get_tree().edited_scene_root
		
	else:
		root = get_tree().root
	
	if root.has_node("Rakugo"):
		raku = root.get_node("Rakugo")
	
	timeout.connect(_timeout)
	start()

func _timeout():
	if raku:
		# test_string = <test_string>
		raku.set_variable("test_string", "Hello Rakugo!")
		
		# test_int = <test_int>
		raku.set_variable("test_int", 123)

		# test_bool = <test_bool>
		raku.set_variable("test_bool", true)
		
		# @color=<test_color> {text in custom color from variable}
		var rand_color = Color.WHITE
		randomize()
		rand_color.r = randf()
		randomize()
		rand_color.g = randf()
		randomize()
		rand_color.b = randf()
		raku.set_variable("test_color", "#" + rand_color.to_html())
