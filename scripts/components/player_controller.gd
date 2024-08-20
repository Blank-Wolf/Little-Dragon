class_name PlayerController
extends Node

signal jump_pressed
signal jump_released
signal dash_pressed

var direction: float
var prev_direction: float


func _input(event: InputEvent) -> void:
	direction = Input.get_axis("move_left", "move_right")
	direction = signf(direction) # This is to prevent non Integer directions
	if direction != 0.0:
		prev_direction = direction

	if event.is_action_pressed("action_dash"):
		dash_pressed.emit()

	if event.is_action_pressed("move_jump"):
		jump_pressed.emit()
	elif event.is_action_released("move_jump"):
		jump_released.emit()

	get_viewport().set_input_as_handled()
