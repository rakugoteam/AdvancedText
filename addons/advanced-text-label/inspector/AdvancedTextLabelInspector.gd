tool
extends EditorInspectorPlugin

func can_handle(object:Object):
  return object is AdvancedTextLabel

func parse_property(object, type, path, hint, hint_text, usage):
  # hide vars that user shouldn't be able to change
  var hidden_vars = ["text", "bbcode_enabled", "bbcode_text"]
  if path in hidden_vars:
    return true
