class_name PlayerController
extends Node

@export var dash_direction_time: float = 0.1
@export var has_directional_dash := true

var direction: Vector2
var prev_direction: float
var dash_direction: Vector2

var _has_dashed: bool
var _has_jumped: bool
var _has_stopped_jump: bool


func _input(event: InputEvent) -> void:
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	direction = direction.sign() # This is to prevent non Integer directions
	if direction.x != 0.0:
		prev_direction = direction.x

	if event.is_action_pressed("action_dash"):
		dash_direction = Vector2(prev_direction, 0.0)

		if has_directional_dash and direction.y != 0.0:
			dash_direction = direction
		_has_dashed = true

	if event.is_action_released("action_dash"):
		_has_dashed = false

	if event.is_action_pressed("move_jump"):
		_has_jumped = true
		_has_stopped_jump = false
	elif event.is_action_released("move_jump"):
		_has_jumped = false
		_has_stopped_jump = true

	get_viewport().set_input_as_handled()


func was_jump_pressed() -> bool:
	var jump_pressed := _has_jumped
	_has_jumped = false
	return jump_pressed


func was_jump_released() -> bool:
	var jump_released := _has_stopped_jump
	_has_stopped_jump = false
	return jump_released


func has_dash_pressed() -> bool:
	var dash_pressed := _has_dashed
	_has_dashed = false
	return dash_pressed
