tool
extends EditorInspectorPlugin

func can_handle(object:Object):
  var type := object.get_class()
  var is_type_right := type == "RichTextLabel"
  
  var right_vars := ["markup_text", "markup"]
  var vars := []

  for v in object.get_property_list():
    vars.append(v.name)
  
  for v in right_vars:
    if !(v in vars):
      is_type_right = false

  return is_type_right

func parse_property(object, type, path, hint, hint_text, usage):
  var hidden_vars = [
    "text",
    "bbcode_enabled",
    "bbcode_text"
  ]

  if path in hidden_vars:
    return true

  var property_editor := EditorProperty.new()
  var expand := property_editor.SIZE_EXPAND
  var fill := property_editor.SIZE_FILL
  var expand_fill := property_editor.SIZE_EXPAND_FILL
  
  match path:
    "markup_text":
     
      return true
    
  return false
