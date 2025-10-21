@tool
extends GutTest
class_name TextParserTest

var parser : TextParser

func setup_parser():
	if !parser:
		parser = TextParser.new()

func assert_parser(test_string:String, expected:String, text:=""):
	var result : String = parser.parse(test_string)
	assert_eq(result, expected, text)

