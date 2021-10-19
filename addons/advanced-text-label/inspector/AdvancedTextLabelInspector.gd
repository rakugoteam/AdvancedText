tool
extends EditorInspectorPlugin

func can_handle(object:Object):
  return object is AdvancedTextLabel

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
