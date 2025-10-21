@tool
extends TextParserTest

func setup_parser():
	if !parser:
		parser = ExtendedBBCodeParser.new()

func test_code():
	setup_parser()
	assert_parser("[code][h1]text[/h1][/code]", "[code][h1]text[/h1][/code]")

func test_headers():
	setup_parser()
	assert_parser("[h1]text[/h1]", "[font_size=22]text[/font_size]")
	assert_parser("[h2]text[/h2]", "[font_size=20]text[/font_size]")
	assert_parser("[h3]text[/h3]", "[font_size=18]text[/font_size]")
	assert_parser("[h4]text[/h4]", "[font_size=16]text[/font_size]")

func test_headers_custom_font():
	setup_parser()
	parser.custom_header_font = load(
		"res://addons/advanced-text/font/DejaVuSans-Oblique.ttf")
	assert_parser("[h1]text[/h1]", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=22]text[/font_size][/font]")
	assert_parser("[h2]text[/h2]", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=20]text[/font_size][/font]")
	assert_parser("[h3]text[/h3]", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=18]text[/font_size][/font]")
	assert_parser("[h4]text[/h4]", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=16]text[/font_size][/font]")

func test_headers_custom_sizes():
	setup_parser()
	parser.headers = [32, 30, 28, 26] as Array[int]
	assert_parser("[h1]text[/h1]", "[font_size=32]text[/font_size]")
	assert_parser("[h2]text[/h2]", "[font_size=30]text[/font_size]")
	assert_parser("[h3]text[/h3]", "[font_size=28]text[/font_size]")
	assert_parser("[h4]text[/h4]", "[font_size=26]text[/font_size]")

func test_emojis():
	setup_parser()
	assert_parser(":grinning:",
	"[img]res://addons/emojis-for-godot/emojis/16x16/1f600.tres[/img]")
	assert_parser(":grinning, 36:",
	"[img]res://addons/emojis-for-godot/emojis/36x36/1f600.tres[/img]")

func test_icons():
	setup_parser()
	assert_parser("[im:folder-open]", "[font=res://addons/material-design-icons/fonts/material_design_icons.ttf]󰝰[/font]")
	assert_parser("[im:folder-open, 32]", "[font_size=32][font=res://addons/material-design-icons/fonts/material_design_icons.ttf]󰝰[/font][/font_size]")

func test_rakugo_vars():
	setup_parser()
	Rakugo.define_character("syl", "Sylvia")
	assert_parser("<syl.name>", "Sylvia")

	Rakugo.set_variable("test_string", "test_string")
	assert_parser("<test_string>", "test_string")

	Rakugo.set_variable("test_int", 32)
	assert_parser("<test_int>", "32")
	
	Rakugo.set_variable("test_bool", true)
	assert_parser("<test_bool>", "true")

func test_rakugo_vars_tricks():
	Rakugo.set_variable("test_color", "#3268")
	assert_parser("[color=<test_color>]colored text[/color]", "[color=#3268]colored text[/color]")

	var hex_red := Color.RED.to_html()
	Rakugo.set_variable("red_color", "#" + hex_red)
	assert_parser("[color=#%s]colored text[/color]" % hex_red, "[color=#%s]colored text[/color]" % hex_red)

	Rakugo.set_variable("test_link", "https://some_domain.com")
	assert_parser("[url]<test_link>[/url]", "[url]https://some_domain.com[/url]")

	Rakugo.set_variable("path_to_img", "res://icon.png")
	assert_parser("[img]<path_to_img>[/img]", "[img]res://icon.png[/img]")


