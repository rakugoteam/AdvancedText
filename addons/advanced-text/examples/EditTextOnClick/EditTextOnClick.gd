extends TabContainer

var text := "[center][shake rate=5 level=10]**Clik to edit me**[/shake][/center]"
onready var label := $AdvancedTextButton/AdvancedTextLabel

func _ready():
	label.markup_text = text
	$MarkupEdit.text = text
	$AdvancedTextButton.connect("pressed", self, "set", ["current_tab", 1])

func _process(delta):
	if current_tab == 1:
		if Input.is_key_pressed(KEY_ENTER):
			text = $MarkupEdit.text
			label.markup_text = text
			current_tab = 0
			
		if Input.is_key_pressed(KEY_ESCAPE):
			current_tab = 0
