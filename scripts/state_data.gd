class_name StateData
extends Resource

var state: BaseState
var transitions: Dictionary


## Initialize StateData values. [br]
## The [param state_node] parameter is the node which this data refers to.
## The [ṕaram state_transitions] parameter is a [Dictionary] which the key
## is the State Name to transition to, and the value is a [Callable] function
## which returns [code]true[/code] if the state can transition to it.
## Notes: The order of the value in the [param state_transitions] also denotes
## the priority of the transition.
func _init(state_node: BaseState, state_transitions: Dictionary) -> void:
	assert(state_node != null, "State Path is invalid!")
	state = state_node

	for transition: String in state_transitions.keys():
		var condition = state_transitions[transition]
		if condition is not Callable or not condition.is_valid():
			push_warning("Condition %s is not valid" % transition)
			continue

		transitions[transition] = condition


## Check each [param transition] condition and transition to it if the
## condition evaluates to [code]true[/code].
func check_next_state() -> String:
	var next := ""

	for key in transitions.keys():
		var condition: Callable = transitions[key]
		if condition.call():
			next = key
			break

	return next
