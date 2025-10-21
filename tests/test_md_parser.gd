@tool
extends TextParserTest

func setup_parser():
	if !parser:
		parser = MarkdownParser.new()

func test_headers():
	setup_parser()
	assert_parser("# text\n", "[font_size=22]text[/font_size]\n")
	assert_parser("## text\n", "[font_size=20]text[/font_size]\n")
	assert_parser("### text\n", "[font_size=18]text[/font_size]\n")
	assert_parser("#### text\n", "[font_size=16]text[/font_size]\n")

func test_headers_custom_font():
	setup_parser()
	parser.custom_header_font = load(
		"res://addons/advanced-text/font/DejaVuSans-Oblique.ttf")
	assert_parser("# text\n", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=22]text[/font_size]\n[/font]")
	assert_parser("## text\n", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=20]text[/font_size]\n[/font]")
	assert_parser("### text\n", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=18]text[/font_size]\n[/font]")
	assert_parser("#### text\n", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=16]text[/font_size]\n[/font]")

func test_headers_custom_sizes():
	setup_parser()
	parser.headers = [32, 30, 28, 26] as Array[int]
	assert_parser("# text\n", "[font_size=32]text[/font_size]\n")
	assert_parser("## text\n", "[font_size=30]text[/font_size]\n")
	assert_parser("### text\n", "[font_size=28]text[/font_size]\n")
	assert_parser("#### text\n", "[font_size=26]text[/font_size]\n")

# func test_links():
# 	setup_parser()
# 	assert_parser("[link](https://some_domain.com)", "[url=https://some_domain.com]link[/url]")
# 	assert_parser("<https://some_domain.com>", "[url]https://some_domain.com[/url]")

# func test_imgs():
# 	setup_parser()
# 	assert_parser("![](res://icon.png)", "[img]res://icon.png[/img]")
# 	assert_parser( "![24x24](res://icon.png)", "[img=24x24]res://icon.png[/img]")

# func test_rakugo_vars_tricks():
# 	Rakugo.set_variable("test_color", "#3268")
# 	assert_parser("@color=<test_color>{colored text}", "[color=#3268]colored text[/color]")

# 	var hex_red := Color.RED.to_html()
# 	Rakugo.set_variable("red_color", "#" + hex_red)
# 	assert_parser("@color=#%s{colored text}" % hex_red, "[color=#%s]colored text[/color]" % hex_red)

# 	Rakugo.set_variable("test_link", "https://some_domain.com")
# 	assert_parser("<<test_link>>", "[url]https://some_domain.com[/url]")

# 	Rakugo.set_variable("path_to_img", "res://icon.png")
# 	assert_parser("![]{<path_to_img>}", "[img]res://icon.png[/img]")
