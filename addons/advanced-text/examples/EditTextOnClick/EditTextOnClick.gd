extends TabContainer

export(String, MULTILINE) var text := "[center][shake rate=5 level=10]**Clik to edit me**[/shake][/center]"
export (NodePath) onready var label = get_node(label)
export (NodePath) onready var save_button = get_node(save_button)
export (NodePath) onready var m_edit = get_node(m_edit)
export (NodePath) onready var button = get_node(button)

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
