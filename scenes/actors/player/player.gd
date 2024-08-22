class_name Player
extends CharacterBody2D

@onready var _state_machine := $StateMachine

@onready var _controller := $PlayerController
@onready var _jump := $JumpComponent
@onready var _dash := $DashComponent


func _ready() -> void:
	var states: Array[Dictionary] = [
		{
			"name": "Idle",
			"path": "OnIdle",
			"change_to": [ "Dash", "Fall", "Jump", "Walk" ]
		},
		{
			"name": "Walk",
			"path": "OnWalk",
			"change_to": [ "Dash", "Fall", "Idle", "Jump" ]
		},
		{
			"name": "Fall",
			"path": "OnFall",
			"change_to": [ "Dash", "Idle", "Jump"]
		},
		{
			"name": "Jump",
			"path": "OnJump",
			"change_to": [ "Dash", "Fall" ]
		},
		{
			"name": "Dash",
			"path": "OnDash",
			"change_to": [ "Idle" ],
		},
	]

	_state_machine.setup(states, "Idle")


func _physics_process(_delta: float) -> void:
	_handle_statemachine()

	move_and_slide()

	if is_on_floor():
		_jump.reset()
		_dash.reset()


func _handle_statemachine() -> void:
	var next_state := ""

	match _state_machine.current_state:
		"Idle":
			if not is_on_floor():
				next_state = "Fall"
			elif _can_try_jump():
				next_state = "Jump"
			elif _can_try_dash():
				next_state = "Dash"
			elif _controller.direction.x != 0.0:
				next_state = "Walk"
		"Walk":
			if not is_on_floor():
				next_state = "Fall"
			elif _can_try_jump():
				next_state = "Jump"
			elif _can_try_dash():
				next_state = "Dash"
			elif _controller.direction.x == 0.0:
				next_state = "Idle"
		"Fall":
			if is_on_floor():
				next_state = "Idle"
			elif _can_try_jump():
				next_state = "Jump"
			elif _can_try_dash():
				next_state = "Dash"
		"Jump":
			if velocity.y >= 0.0:
				next_state = "Fall"
			elif _can_try_dash():
				next_state = "Dash"
		"Dash":
			if velocity == Vector2.ZERO:
				next_state = "Idle"

	if not next_state.is_empty():
		_state_machine.set_next_state(next_state)


func _can_try_jump() -> bool:
	var is_jumping: bool = _controller.was_jump_pressed()
	if is_jumping and not _jump.can_jump():
		_jump.buffer_jump() # We can't jump, so buffer it to try later
		return false

	return is_jumping or _jump.is_buffered()


func _can_try_dash() -> bool:
	var is_dashing: bool = _controller.has_dash_pressed()
	if is_dashing and _controller.dash_direction == Vector2.ZERO:
		return false

	return is_dashing and _dash.can_dash()
