@tool
## This is singleton is used to keep references and common variables
## for AdvancedText in one place and not duplicate them.
## Mainly used to simplify the handling of supported addons/plugins.
## @tutorial: https://rakugoteam.github.io/advanced-text-docs/3.0.1/AdvancedText/
extends Node

## Reference to root
## Its a getter that returns [code]get_node("/root/")[/code]
var root: Node:
	get: return get_tree().root

## Reference to Rakugo singleton
## Its a getter that returns Rakugo singelton if it exist
var rakugo: Node:
	get:
		if Engine.is_editor_hint(): return null
		if !rakugo:
			rakugo = get_singleton("Rakugo")
		return rakugo

## Reference to IconsFonts singleton
## Its a getter that returns IconsFonts singelton if it exist
var icons_fonts: Node:
	get:
		if !icons_fonts:
			icons_fonts = get_singleton("IconsFonts")
		return icons_fonts

## Func used get singletons from other addons.
## Build-in Engine.get_singleton() works only for C++ modules,
## So we need to make this walkaround.
func get_singleton(singleton: String) -> Node:
	if root.has_node(singleton):
		return root.get_node(singleton)
	return null