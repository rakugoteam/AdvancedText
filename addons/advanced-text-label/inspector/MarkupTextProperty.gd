tool
extends EditorProperty

var text := "" setget _set_text, _get_text
var object

var MarkupTextEditor = preload("../MarkupTextEditor/MarkupTextEditor.tscn").instance();
var popup := WindowDialog.new()
var hbox := HBoxContainer.new()
var text_edit := TextEdit.new()
var button := Button.new()

func _ready():
  popup.window_title = "Markup Text Editor"
  popup.resizable = true
  popup.add_child(MarkupTextEditor)
  popup.connect("popup_hide", self, "on_popup_closed")
  add_child(popup)

  _set_text(object.markup_text)
  text_edit.size_flags_horizontal = SIZE_EXPAND_FILL

  button.text = "Edit"
  button.connect("pressed", self, "_on_button")

  hbox.add_child(text_edit)
  hbox.add_child(button)
  hbox.rect_min_size.y = 100
  add_child(hbox)

func _set_text(new_text: String):
  text_edit.text = new_text
  object.markup = new_text

func _get_text():
  return text_edit.text

func _on_button():
  MarkupTextEditor.text = _get_text()
  popup.popup_centered(Vector2(1024,600))

func on_popup_closed():
  _set_text(MarkupTextEditor.text)
