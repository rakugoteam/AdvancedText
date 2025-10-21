class_name Utils
extends Object

## Is shortcut of:
## 	if !object.is_connected(signal_name, method):
##  	object.connect(signal_name, method)
static func connect_if_possible(
	object:Object, signal_name:StringName, method:Callable):
	if !object.is_connected(signal_name, method):
		object.connect(signal_name, method)

## Is shortcut of:
## 	if object.is_connected(signal_name, method):
##  	object.disconnect(signal_name, method)
static func disconnect_if_possible(
	object:Object, signal_name:StringName, method:Callable):
	if object.is_connected(signal_name, method):
		object.disconnect(signal_name, method)

## Is shortcut of:
## 	disconnect_if_possible(object, signal_name, old_method)
## 	connect_if_possible(object, signal_name, new_method)
static func change_signal(
	object:Object, signal_name:StringName,
	old_method:Callable, new_method:Callable):
	disconnect_if_possible(object, signal_name, old_method)
	connect_if_possible(object, signal_name, new_method)
