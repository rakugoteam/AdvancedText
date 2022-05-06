tool
extends Control

var editor : EditorInterface
var last_selected_node : Node

signal node_selected(node)

func _process(delta:float):
	if visible != true:
		return
	
	# there is no selected node changed signal
	# so I need to check if the selected node changed in _process()
	var selected_node = get_selected_node()
	if selected_node == last_selected_node:
		return
	
	last_selected_node = selected_node
	emit_signal("node_selected", selected_node)

func get_selected_node() -> Node:
	if editor == null:
		return null

	var s = editor.get_selection()
	var selected_nodes = s.get_selected_nodes()

	# print("selected_nodes ", selected_nodes.size())
	if selected_nodes.size() == 0:
		return null

	if last_selected_node != selected_nodes[0]:
		return selected_nodes[0]
	
	return null
