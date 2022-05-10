tool
extends VSplitContainer

onready var previews := {
	"right" : $HSplit/PreviewRight,
	"bottom" : $PreviewBottom
}

var current_preview : AdvancedTextLabel
var current_preview_setting := "none"

func _ready():
	set_preview("none")
	set_preview(ProjectSettings.get_setting("addons/advanced_text/MarkupEdit/preview_enabled"))
	TextEditorHelper.connect("preview_toggled", self, "_on_preview_toggled")
	TextEditorHelper.connect("selected_preview", self, "set_preview")
	TextEditorHelper.connect("selected_markup", self, "_on_selected_markup")
	TextEditorHelper.connect("selected_file", self, "_on_file_selected")
	TextEditorHelper.connect("update_preview", self, "_on_preview_update")

func _on_preview_toggled(toggle : bool):
	if toggle:
		set_preview("current")
		return
	
	set_preview("none")

func set_preview(preview_setting : String):
	if current_preview:
		current_preview.hide()
	
	if not (preview_setting in ["current", "none"]):
		current_preview_setting = preview_setting

	match preview_setting:
		"right", "bottom" :
			current_preview = previews[preview_setting]

		"current" :
			current_preview = previews[current_preview_setting]

		"none": 
			previews.right.hide()
			previews.bottom.hide()
			return

	current_preview.show()

func _on_markup_selected(markup : String):
	current_preview.markup = markup

func _on_file_selected(f_data:Dictionary):
	current_preview.markup_text = f_data["text"]

func _on_preview_update(f_data:Dictionary):
	current_preview.markup_text = f_data["text"]
