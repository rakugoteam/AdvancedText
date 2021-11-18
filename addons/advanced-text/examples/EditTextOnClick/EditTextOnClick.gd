extends TabContainer

export(String, MULTILINE) var text := "[center][shake rate=5 level=10]**Clik to edit me**[/shake][/center]"
onready var label := $AdvancedTextButton/AdvancedTextLabel
onready var save_button := $MarkupEdit/Button
onready var m_edit := $MarkupEdit
onready var button := $AdvancedTextButton

func _ready():
	label.markup_text = text
	m_edit.text = text
	button.connect("pressed", self, "_on_button_pressed")
	save_button.connect("pressed", self, "_on_save_button_pressed")

func _on_button_pressed():
	current_tab = 1

func _on_save_button_pressed():
	label.markup_text = m_edit.text
	current_tab = 0

func _process(delta):
	if m_edit.visible:
		if Input.is_key_pressed(KEY_ESCAPE):
			current_tab = 0
