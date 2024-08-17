class_name StateMachine
extends Node

signal state_changed(next: String)

@export var root: Node = owner

var current_state := ""
var previous_state := ""

var _states: Dictionary
var _state: BaseState
var _next_state := ""
var _msg: Dictionary

## Setup internal states Dictionary with the states description
##
## Set each state Name, NodePath and Transitions:
## "name": Unique state key on the Dictionary
## "path": Path relative to the StateMachine node on the SceneTree
## "change_to": Array of strings containing the state names
## 	the state can transition to
func setup(states: Array[Dictionary], init: String) -> void:
	for desc in states:
		if not desc.has_all(["name", "path", "change_to"]):
			push_error("Invalid state provided at setup: %s" % desc)
			continue

		add_state(desc["name"], desc["path"], desc["transitions"])

	_set_state(init)


func add_state(state_name: String, path: NodePath, change_to: PackedStringArray) -> void:
	if _states.has(name):
		push_warning("StateMachine already has state named: %s" % name)
		return

	var state: BaseState = get_node_or_null(path)
	if state == null:
		push_error("Unable to get node: %s" % path)
		return

	state.owner = root
	state.emit("registered")
	_states[state_name] = { "path": path, "change_to": change_to }


func _set_state(state: String) -> void:
	if state not in _states:
		push_warning("State '%s' is not registered" % state)
		return # Cannot change to an invalid state

	if _state != null:
		_state._exits()
		previous_state = current_state

	current_state = state
	_state = get_node(_states[state].path)
	_state._enter(_msg)
	_state.connect("completed", _on_state_completed, CONNECT_ONE_SHOT)

	state_changed.emit(state)


func _on_state_completed(next: String, msg: Dictionary) -> void:
	if not _next_state.is_empty() or next == current_state:
		return

	# If the next state was registered, transition to it, if not,
	# go to the previous state.
	var change_to: PackedStringArray = _states[_state].change_to
	if change_to.has(next):
		_next_state = next
	elif not previous_state.is_empty():
		_next_state = previous_state
	else:
		push_error("Failed to set change current state to: %s" % next)
		return

	_msg = msg.duplicate()
