class_name JumpComponent
extends Node

# Amount of pixels to test while try to correct corner
const _CORRECTION_AMOUNT := 8

enum GravityKind {
	FALL,
	JUMP,
}

@export_group("Data")
@export var jump_height := 256.0
@export var max_jumps: int = 2
@export_range(0.001, 1.0) var ascent_time := 0.5
@export_range(0.001, 1.0) var descent_time := 0.4

@export_group("Timers")
@export var coyote_time := 0.08
@export var jumpbuffer_time := 0.1

var _rem_jumps := max_jumps
var _coyote_timer: SceneTreeTimer
var _jumpbuf_timer: SceneTreeTimer

@onready var _jump_impulse := (jump_height * -2.0) / ascent_time
@onready var _jump_gravity := (jump_height * 2.0) / (ascent_time ** 2.0)
@onready var _fall_gravity := (jump_height * 2.0) / (descent_time ** 2.0)


func _ready() -> void:
	assert(owner is CharacterBody2D, "Component owner is not a CharacterBody2D")


func apply_gravity(delta: float, kind: GravityKind) -> void:
	var gravity: float
	match kind:
		GravityKind.FALL: gravity = _fall_gravity
		GravityKind.JUMP: gravity = _jump_gravity

	owner.velocity.y += gravity * delta


func do_jump(jumps_count: int = 1, dummy: bool = false) -> void:
	if not dummy:
		owner.velocity.y = _jump_impulse
	_rem_jumps -= jumps_count


func reset() -> void:
	_rem_jumps = max_jumps


func start_coyote() -> void:
	if is_coyote_timing():
		return # We are already in a coyote time state
	_coyote_timer = get_tree().create_timer(coyote_time)


func is_coyote_timing() -> bool:
	return _coyote_timer != null and _coyote_timer.time_left != 0.0


func buffer_jump() -> void:
	if is_buffered():
		return # Jump is already buffered
	_jumpbuf_timer = get_tree().create_timer(jumpbuffer_time)


func is_buffered() -> bool:
	return _jumpbuf_timer != null and _jumpbuf_timer.time_left != 0.0


func can_jump() -> bool:
	var has_jumps := _rem_jumps > 0 and _rem_jumps <= max_jumps
	return owner.is_on_floor() or is_coyote_timing() or has_jumps


func try_corner_correct(delta: float, horizontal: bool) -> void:
	var velocity := Vector2(0.0, owner.velocity.y * delta)
	if horizontal:
		velocity = Vector2(owner.velocity.x * delta, 0.0)

	var transform: Transform2D = owner.global_transform
	if not owner.test_move(transform, velocity):
		return # Seems like the next frames will not make the body collide

	for i in range(1, _CORRECTION_AMOUNT * 2 + 1):
		for j in [-1.0, 1.0]:
			var translation := Vector2(i * j / 2, 0.0)
			if horizontal:
				translation = Vector2(0.0, i * j / 2)

			# Try to find an empty spot to put the owner on
			if not owner.test_move(transform.translated(translation), velocity):
				owner.translate(translation)
				return
