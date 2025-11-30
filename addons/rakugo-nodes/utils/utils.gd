class_name Utils
extends Object

## Is shortcut of:
## [br]	if !signal_obj.is_connected(method):
## [br]		signal_obj.connect(method)
static func connect_if_possible(signal_obj: Signal, method: Callable):
	if !signal_obj.is_connected(method):
		signal_obj.connect(method)

## Is shortcut of:
## [br]	if signal_obj.is_connected(method):
## [br]		signal_obj.disconnect(method)
static func disconnect_if_possible(
	signal_obj: Signal, method: Callable):
	if signal_obj.is_connected(method):
		signal_obj.disconnect(method)

## Is shortcut of:
## [br]	disconnect_if_possible(signal_obj, old_method)
## [br]	connect_if_possible(signal_obj, new_method)
static func change_signal(
	signal_obj: Signal, old_method: Callable, new_method: Callable):
	disconnect_if_possible(signal_obj, old_method)
	connect_if_possible(signal_obj, new_method)

## Is shortcut of:
## [br]	if toggle: connect_if_possible(signal_obj, method)
## [br]	else: disconnect_if_possible(signal_obj, method)
static func toggle_connection_if_possible(
	signal_obj: Signal, method: Callable, toggle: bool):
	if toggle: connect_if_possible(signal_obj, method)
	else: disconnect_if_possible(signal_obj, method)

## Is shortcut of:
## [br] return variant if variant else default
static func get_var(variant, default):
	return variant if variant else default