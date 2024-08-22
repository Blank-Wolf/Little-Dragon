class_name DashComponent
extends Node

@export_group("Data")
@export var dash_distance := 192.0
@export_range(0.001, 1.0) var dash_stop_time := 0.4
@export var max_dashs := 2

var _rem_dashs := max_dashs

@onready var _dash_impulse := (dash_distance * 2.0) / dash_stop_time
@onready var _dash_stopper := (dash_distance * 2.0) / (dash_stop_time ** 2.0)

func _ready() -> void:
	if owner is not CharacterBody2D:
		push_error("Jump component owner is not a CharacterBody2D")


func reset() -> void:
	_rem_dashs = max_dashs


func do_dash(dir: Vector2) -> void:
	owner.velocity = _dash_impulse * dir
	_rem_dashs -= 1


func can_dash() -> bool:
	return _rem_dashs > 0 and _rem_dashs <= max_dashs


func apply_stop_force(delta: float) -> void:
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, _dash_stopper * delta)
