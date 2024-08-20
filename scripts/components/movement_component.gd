class_name MovementComponent
extends Node

# Amount of pixels to test while try to correct corner
const _CORRECTION_AMOUNT := 8

@export var body: CharacterBody2D

@export_group("Horizontal")
@export var max_speed := 300.0
@export_range(0.001, 1.0) var accel_time := 0.6
@export_range(0.001, 1.0) var decel_time := 0.75
@export var dash_distance := 192.0
@export_range(0.001, 1.0) var dash_end_time := 0.4

@export_group("Vertical")
@export var jump_height := 256.0
@export_range(0.001, 1.0) var ascent_time := 0.5
@export_range(0.001, 1.0) var descent_time := 0.4

@onready var ground_friction := (max_speed * 2.0) / (decel_time ** 2.0)
@onready var dash_friction := (dash_distance * 2.0) / (dash_end_time ** 2.0)
@onready var jump_gravity := (jump_height * 2.0) / (descent_time ** 2.0)
@onready var fall_gravity := (jump_height * 2.0) / (ascent_time ** 2.0)

@onready var _acceleration := (max_speed * 2.0) / (accel_time ** 2.0)
@onready var _dash_impulse := (dash_distance * 2.0) / dash_end_time
@onready var _jump_impulse := (jump_height * -2.0) / ascent_time


func apply_acceleration(delta: float, dir: float, multiplier: float) -> void:
	var accel := _acceleration * multiplier
	body.velocity.x += accel * dir * delta
	body.velocity.x = clamp(body.velocity.x, -max_speed, max_speed)


func apply_friction(delta: float, friction: float) -> void:
	body.velocity.x = move_toward(body.velocity.x, 0.0, friction * delta)


func apply_gravity(delta:float, gravity: float) -> void:
	body.velocity.y += gravity * delta


func do_jump() -> void:
	body.velocity.y = _jump_impulse


func do_dash(dir: Vector2):
	body.velocity = _dash_impulse * dir


func try_corner_correct(delta: float, horizontal: bool) -> void:
	var relative_vel := Vector2(0.0, body.velocity.y * delta)
	if horizontal:
		relative_vel = Vector2(body.velocity.x * delta, 0.0)

	var transform := body.global_transform
	if not body.test_move(transform, relative_vel):
		return # Seems like the next frames will not make the body collide

	for i in range(1, _CORRECTION_AMOUNT * 2 + 1):
		for j in [-1.0, 1.0]:
			# If 'horizontal' is true, the correction is done on the Horizontal Axis
			var translation := Vector2(i * j / 2, 0.0)
			if horizontal:
				translation = Vector2(0.0, i * j / 2)

			# Try to find an empty spot to put the body on
			if not body.test_move(transform.translated(translation), relative_vel):
				body.translate(translation)
				return
