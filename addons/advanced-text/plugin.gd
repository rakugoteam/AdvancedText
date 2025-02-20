@tool
extends EditorPlugin

const SingletonName := "AdvancedText"
const SingletonScript := "res://addons/advanced-text/AdvancedText.gd"
const HintPopupScene := "res://addons/advanced-text/HintPopup/hint_popup.tscn"

func _enter_tree():
	add_autoload_singleton(SingletonName, SingletonScript)
	add_autoload_singleton("HintPopup", HintPopupScene)

func _exit_tree():
	remove_autoload_singleton("HintPopup")
	remove_autoload_singleton(SingletonName)

