@tool
extends TextParserTest

func setup_parser():
	if !parser:
		parser = RenPyMarkupParser.new()

func test_code():
	setup_parser()
	assert_parser("{code}{h1}text{/h1}{/code}", "[code]{h1}text{/h1}[/code]")

func test_headers():
	setup_parser()
	assert_parser("{h1}text{/h1}", "[font_size=22]text[/font_size]")
	assert_parser("{h2}text{/h2}", "[font_size=20]text[/font_size]")
	assert_parser("{h3}text{/h3}", "[font_size=18]text[/font_size]")
	assert_parser("{h4}text{/h4}", "[font_size=16]text[/font_size]")

func test_headers_custom_font():
	setup_parser()
	parser.custom_header_font = load("res://addons/advanced-text/font/DejaVuSans-Oblique.ttf")
	assert_parser("{h1}text{/h1}", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=22]text[/font_size][/font]")
	assert_parser("{h2}text{/h2}", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=20]text[/font_size][/font]")
	assert_parser("{h3}text{/h3}", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=18]text[/font_size][/font]")
	assert_parser("{h4}text{/h4}", "[font=res://addons/advanced-text/font/DejaVuSans-Oblique.ttf][font_size=16]text[/font_size][/font]")

func test_headers_custom_sizes():
	setup_parser()
	parser.headers = [32, 30, 28, 26] as Array[int]
	assert_parser("{h1}text{/h1}", "[font_size=32]text[/font_size]")
	assert_parser("{h2}text{/h2}", "[font_size=30]text[/font_size]")
	assert_parser("{h3}text{/h3}", "[font_size=28]text[/font_size]")
	assert_parser("{h4}text{/h4}", "[font_size=26]text[/font_size]")

func test_links():
	setup_parser()
	assert_parser("{a=https://some_domain.com}link{/a}", "[url=https://some_domain.com]link[/url]")
	assert_parser("{a}https://some_domain.com{/a}", "[url]https://some_domain.com[/url]")

func test_imgs():
	setup_parser()
	assert_parser("{img=res://icon.png}", "[img]res://icon.png[/img]")
	assert_parser( "{img=res://icon.png size=24x24}", "[img=24x24]res://icon.png[/img]")

func test_rakugo_vars_tricks():
	Rakugo.set_variable("test_color", "#3268")
	assert_parser("{color=<test_color>}colored text{/color}", "[color=#3268]colored text[/color]")

	var hex_red := Color.RED.to_html()
	Rakugo.set_variable("red_color", "#" + hex_red)
	assert_parser("{color=#%s}colored text{/color}" % hex_red, "[color=#%s]colored text[/color]" % hex_red)

	Rakugo.set_variable("test_link", "https://some_domain.com")
	assert_parser("{a}<test_link>{/a}", "[url]https://some_domain.com[/url]")

	Rakugo.set_variable("path_to_img", "res://icon.png")
	assert_parser("{img=<path_to_img>}", "[img]res://icon.png[/img]")
