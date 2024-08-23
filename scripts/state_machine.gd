class_name StateMachine
extends Node
## A simple FSM(Finite State Machine) Node to change multiple states from an object

signal state_changed(next: String)

@export var enabled := true
@export var root: Node

var _registered: Dictionary
var _state: BaseState
var _data: StateData

var current_state := ""
var previous_state := ""


func _process(delta: float) -> void:
	if _data == null or _state == null or not enabled:
		return # There's nothing to execute, try on next frame

	# Check if there is a pending state to transition
	var next_state := _data.check_next_state()
	if not next_state.is_empty() and next_state != current_state:
		if _registered.has(next_state):
			set_state(next_state)
		else:
			push_warning("State '%s' is not registered" % next_state)

	_state._update(delta);


func _physics_process(delta: float) -> void:
	if _state != null and enabled:
		_state._physics_update(delta)


## Register states using provided name and data.
## The [param initial] parameter is the state's name of the state the machine
## must init on. The [param states] parameter is a [Dictionary] where the key
## is the name of the state can transition to, and the value is a [StateData]
## resource.
func setup(initial: String, states: Dictionary) -> void:
	for state_name in states.keys():
		var data = states[state_name]
		if not data is StateData or data == null:
			push_error("Invalid state provided at setup: %s" % state_name)
			continue

		add_state(state_name, data)

	set_state(initial)


## Register a new state to the machine. [br]
## [param state_name]: Unique state name. [br]
## [param data]: A [StateData] resource which has the data describing the
## state Node and transitions
func add_state(state_name: String, data: StateData) -> void:
	assert(data != null, "State Data is invalid!")

	if _registered.has(name):
		push_warning("StateMachine already has state named: %s" % name)
		return

	var state := data.state
	state.owner = root if root != null else owner
	state.machine = self
	state._register()
	_registered[state_name] = data


## Set next state to the machine transition to. [br]
## [param state_name]: State name to set as current.
func set_state(state_name: String) -> void:
	# The states can return some data to send to the next state
	var msg := {}
	if _state != null:
		msg = _state._exit()

	previous_state = current_state
	current_state = state_name

	_data = _registered[state_name]
	_state = _data.state
	_state._enter(msg)

	state_changed.emit(state_name)
