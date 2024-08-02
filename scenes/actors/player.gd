class_name Player
extends CharacterBody2D

# Ground states
enum {
	ST_IDLE,
	ST_WALK,
}

# Air states
enum {
	ST_FALL,
	ST_JUMP,
}

@export_group("Walk")
@export var max_speed := 300.0

@export_group("Jump")
@export var jump_height := 256.0
@export_range(0.001, 1.0) var ascent_time := 0.50
@export_range(0.001, 1.0) var descent_time := 0.40
@export var max_jumps := 2
@export var coyote_time := 0.08

@export_group("Dash")
@export var dash_ground := 600.0
@export var dash_air_side := 800.0
@export var dash_air_up := 700.0

var _dir := 0.0
var _ground_state := ST_IDLE
var _air_state := ST_FALL
var _is_paused := false # TODO: Use 'set_physics_process()/set_process()' instead

var _rem_jumps := max_jumps
var _is_jumping := false
var _cut_jump := false
var _was_on_floor := false

@onready var _jump_impulse := (jump_height * -2.0) / ascent_time
@onready var _jump_gravity := (jump_height * 2.0) / (descent_time ** 2)
@onready var _gravity := (jump_height * 2.0) / (ascent_time ** 2)

@onready var _coyote_timer: SceneTreeTimer

func _process(_delta: float) -> void:
	if _is_paused:
		return

	_dir = Input.get_axis("move_left", "move_right")

	if Input.is_action_just_pressed("move_jump"):
		_air_state = ST_JUMP
		_is_jumping = true

	if Input.is_action_just_released("move_jump"):
		_is_jumping = false
		_cut_jump = velocity.y < 0.0


func _physics_process(delta: float) -> void:
	if _is_paused:
		return

	_move_walk(delta)

	match _air_state:
		ST_FALL:
			_apply_gravity(delta)
		ST_JUMP:
			_move_jump(delta)

	move_and_slide()

	if is_on_floor():
		_air_state = ST_FALL
		_rem_jumps = max_jumps
		_was_on_floor = true
		_is_jumping = false
		_coyote_timer = null


func _move_walk(delta: float) -> void:
	if is_zero_approx(_dir):
		_ground_state = ST_IDLE
	else:
		_ground_state = ST_WALK

	match _ground_state:
		ST_IDLE:
			velocity.x = move_toward(velocity.x, 0.0, max_speed * delta)
		ST_WALK:
			# Fix player slipping behavior
			var accel := max_speed
			if signf(_dir) != signf(get_last_motion().x):
				accel *= 4.0

			velocity.x += accel * _dir * delta
			velocity.x = clamp(velocity.x, -max_speed, max_speed)


func _apply_gravity(delta: float) -> void:
	if _is_coyotetimer_running():
		return

	velocity.y += _gravity * delta

	# If the player was on the floor, is not jumping and can do the coyote time
	# have mercy and let it jump for a brief time
	if _was_on_floor and not is_on_floor():
		_coyote_timer = get_tree().create_timer(coyote_time, false, true)
		_was_on_floor = false
		velocity.y = 0.0 # Reset gravity to let the player jump


func _move_jump(delta: float) -> void:
	velocity.y += _jump_gravity * delta

	if _is_jumping:
		# Allow player jump mid-air if there are remaing jumps to use
		var has_jumps := _rem_jumps > 0 and _rem_jumps <= max_jumps
		if is_on_floor() or has_jumps or _is_coyotetimer_running():
			velocity.y = _jump_impulse
			_rem_jumps -= 1

		_is_jumping = false
		_coyote_timer = null # Destroy the timer, we don't need it anymore

	# If the player stop holding the Jump Button, let it fall from current height
	if _cut_jump:
		velocity.y /= 2
		_cut_jump = false


func _is_coyotetimer_running() -> bool:
	return _coyote_timer != null and _coyote_timer.time_left > 0.0
