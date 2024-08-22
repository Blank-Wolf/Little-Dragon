class_name StateMachine
extends Node
## A simple FSM(Finite State Machine) Node to change multiple states from an object

signal state_changed(next: String)

@export var enabled := true
@export var root: Node

var current_state := ""
var previous_state := ""

var _states: Dictionary
var _state: BaseState
var _next_state := ""


func _process(delta: float) -> void:
	# Check there is a pending state to change to
	if not _next_state.is_empty() and _next_state != current_state:
		if _states.has(_next_state):
			_set_state(_next_state)
		else:
			push_warning("State '%s' is not registered" % _next_state)
		_next_state = ""

	if _state != null and enabled:
		_state._update(delta);


func _physics_process(delta: float) -> void:
	if _state != null and enabled:
		_state._physics_update(delta)


## Setup internal states Dictionary with the states description.
## The each dictionary from [param states] must have the following keys: [br]
## [code]"name"[/code]: [String] [br]
## [code]"path"[/code]: [NodePath] [br]
## [code]"change_to"[/code]: [PackedStringArray]
func setup(states: Array[Dictionary], init: String) -> void:
	for desc: Dictionary in states:
		if not desc.has_all(["name", "path", "change_to"]):
			push_error("Invalid state provided at setup: %s" % desc)
			continue

		add_state(desc["name"], desc["path"], desc["change_to"])

	_set_state(init)


## Register a new state to the machine. [br]
## [param name]: Unique state key on the Dictionary. [br]
## [param path]: Path relative to the StateMachine node on the SceneTree. [br]
## [param change_to]: Array of strings containing the state names the state can
## transition to.
func add_state(state_name: String, path: NodePath, change_to: PackedStringArray) -> void:
	if _states.has(name):
		push_warning("StateMachine already has state named: %s" % name)
		return

	var state: BaseState = get_node_or_null(path)
	if state == null:
		push_error("Unable to get node: %s" % path)
		return

	state.owner = root if root != null else owner
	state.machine = self
	state._register()
	_states[state_name] = { "path": path, "change_to": change_to }


## Set next state to the machine transition to. [br]
## [param next]: State name to set as next to go
func set_next_state(next: String) -> void:
	# If the next state was registered, change to it
	var change_to: PackedStringArray = _states[current_state].change_to
	if change_to.has(next) and next in _states:
		_next_state = next
	else:
		push_warning("Current state cannot change to: %s" % next)


func _set_state(state: String) -> void:
	# The states can return some data to send to the next state
	var msg := {}
	if _state != null:
		msg = _state._exit()

	previous_state = current_state
	current_state = state

	_state = get_node(_states[state].path)
	_state._enter(msg)

	state_changed.emit(state)
