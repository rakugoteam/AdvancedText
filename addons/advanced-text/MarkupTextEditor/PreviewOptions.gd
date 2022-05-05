tool
extends HBoxContainer

onready var preview_toggle = $PreviewToggle
onready var preview_switch = $PreviewSwitch

var previews := {
	"right": 0,
	"bottom": 1
}

func _ready():
	preview_toggle.connect("toggled", self, "_on_preview_toggled")
	preview_toggle.icon = get_icon("RichTextEffect", "EditorIcons")

	preview_switch.connect("item_selected", self, "_on_preview_changed")
	preview_switch.set_item_icon(0, get_icon("ControlAlignRightWide", "EditorIcons"))
	preview_switch.set_item_icon(1, get_icon("ControlAlignBottomWide", "EditorIcons"))
	
	var preview_setting = ProjectSettings.get_setting("addons/advanced_text/MarkupEdit/preview_enabled")
	_on_preview_toggled(preview_setting != "none")
	if preview_setting != "none":
		preview_switch.selected = previews[preview_setting]

func _on_preview_toggled(toggle:bool):
	EditorHelper.emit_signal("preview_toggled", toggle)	
	preview_switch.disabled = not toggle
	if !toggle:
		ProjectSettings.set_setting("addons/advanced_text/MarkupEdit/preview_enabled", "none")

func _on_preview_changed(mode):
	var txt_mode = preview_switch.get_item_text(mode).to_lower()
	EditorHelper.emit_signal("selected_preview", txt_mode)
	ProjectSettings.set_setting("addons/advanced_text/MarkupEdit/preview_enabled", txt_mode)
	





