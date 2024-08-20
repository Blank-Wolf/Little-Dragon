class_name Player
extends CharacterBody2D

# Player movement states
enum {
	ST_IDLE,
	ST_WALK,
	ST_FALL,
	ST_JUMP,
	ST_DASH,
}

# Amount of pixels to test while try to correct corner
const _CORRECTION_AMOUNT := 8

@export_group("Ground")
@export var max_speed := 300.0
@export_range(0.001, 1.0) var accel_time := 0.6
@export_range(0.001, 1.0) var decel_time := 0.75
@export var dash_distance := 192.0
@export_range(0.001, 1.0) var dash_end_time := 0.4
@export var max_dashs := 2
@export var dash_cooldown_time := 1.5

@export_group("Air")
@export var jump_height := 256.0
@export_range(0.001, 1.0) var ascent_time := 0.5
@export_range(0.001, 1.0) var descent_time := 0.4
@export var max_jumps := 2
@export var coyote_time := 0.08
@export var jumpbuffer_time := 0.1

var _ground_state := ST_IDLE
var _air_state := ST_FALL
var _is_paused := false # TODO: Use 'set_physics_process()/set_process()' instead

var _dir := 0.0
var _prev_dir := _dir

var _is_dashing := false
var _rem_dashs := max_dashs
var _dash_delay_timer: SceneTreeTimer

var _rem_jumps := max_jumps
var _is_jumping := false
var _cut_jump := false
var _was_on_floor := false
var _coyote_timer: SceneTreeTimer
var _jumpbuf_timer: SceneTreeTimer

@onready var _acceleration := (max_speed * 2.0) / (accel_time ** 2.0)
@onready var _friction := (max_speed * 2.0) / (decel_time ** 2.0)

@onready var _dash_impulse := (dash_distance * 2.0) / dash_end_time
@onready var _dash_friction := (dash_distance * 2.0) / (dash_end_time ** 2.0)

@onready var _jump_impulse := (jump_height * -2.0) / ascent_time
@onready var _jump_gravity := (jump_height * 2.0) / (descent_time ** 2.0)
@onready var _fall_gravity := (jump_height * 2.0) / (ascent_time ** 2.0)

func _ready() -> void:
	var ground_states: Array[Dictionary] = [
		{
			"name": "Idle",
			"path": "OnIdle",
			"change_to": [ "Fall", "Jump", "Walk" ]
		},
		{
			"name": "Walk",
			"path": "OnWalk",
			"change_to": [ "Idle", "Fall", "Jump" ]
		},
	]

	var air_states: Array[Dictionary] = [
		{
			"name": "Ground",
			"path": "OnGround",
			"change_to": [ "Fall", "Jump" ]
		},
		{
			"name": "Fall",
			"path": "OnFall",
			"change_to": [ "Ground", "Jump"]
		},
		{
			"name": "Jump",
			"path": "OnJump",
			"change_to": [ "Fall", "Ground" ]
		},
	]

	$GroundStates.setup(ground_states, "Idle")
	$AirStates.setup(air_states, "Ground")


func _physics_process(_delta: float) -> void:
	if _is_paused:
		return

	move_and_slide()


func _handle_ground_state(delta: float) -> void:
	match _ground_state:
		ST_IDLE:
			_apply_friction(_friction, delta)

			if _is_dashing:
				_ground_state = ST_DASH
			elif _dir != 0.0:
				_ground_state = ST_WALK
		ST_WALK:
			# Fix player slipping behavior
			var accel := _acceleration
			if _dir != signf(get_last_motion().x):
				accel *= 2.0

			velocity.x += accel * _dir * delta
			velocity.x = clamp(velocity.x, -max_speed, max_speed)

			if _is_dashing:
				_ground_state = ST_DASH
			elif _dir == 0.0:
				_ground_state = ST_IDLE
		ST_DASH:
			if _is_dashing:
				_do_dash()
				_is_dashing = false

			_apply_friction(_dash_friction, delta)
			_try_corner_correct(delta, true) # Try to not let the player clash onto a wall

			if velocity.x == 0.0:
				_dash_delay_timer = null
				if _dir != 0.0:
					_ground_state = ST_WALK
				else:
					_ground_state = ST_IDLE


func _apply_friction(friction: float, delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, friction * delta)


func _handle_air_state(delta: float) -> void:
	match _air_state:
		ST_IDLE:
			if is_on_floor():
				_rem_dashs = max_dashs
				_rem_jumps = max_jumps
				_was_on_floor = true
			else:
				# If the player was on the floor, is not jumping and can do the coyote time
				# have mercy and let it jump for a brief time
				if _was_on_floor:
					_coyote_timer = get_tree().create_timer(coyote_time)
					_was_on_floor = false

				if _is_dashing:
					_air_state = ST_DASH
				elif not _is_timer_running(_coyote_timer):
					_air_state = ST_FALL

			if (is_on_floor() or _is_timer_running(_coyote_timer)) \
			and (_is_jumping or _is_timer_running(_jumpbuf_timer)):
					_air_state = ST_JUMP
		ST_FALL:
			_apply_gravity(_fall_gravity, delta)
			_coyote_timer = null

			if _is_jumping:
				_air_state = ST_JUMP
			elif is_on_floor():
				_air_state = ST_IDLE
			elif _is_dashing:
				_air_state = ST_DASH
		ST_JUMP:
			_apply_gravity(_jump_gravity, delta)
			if _is_jumping or _is_timer_running(_jumpbuf_timer):
				_do_jump()
				_is_jumping = false
				_coyote_timer = null

			# If the player stop holding the Jump Button, let it fall from current height
			if _cut_jump:
				velocity.y /= 2
				_cut_jump = false

			_try_corner_correct(delta, false) # Try to not let the player bump the head

			if _is_dashing:
				_air_state = ST_DASH
			elif velocity.y > 0.0:
				_air_state = ST_FALL
		ST_DASH:
			if velocity.x != 0.0:
				velocity.y = 0.0 # We must not fall while dashing
			else:
				_dash_delay_timer = null
				_air_state = ST_FALL


func _apply_gravity(gravity: float, delta: float) -> void:
	velocity.y += gravity * delta


func _do_jump() -> void:
	# Only allow player to jump if is on floor, or it has jumps left
	# or the coyote is timing
	var has_jumps := _rem_jumps > 0 and _rem_jumps <= max_jumps
	if is_on_floor() or has_jumps or _is_timer_running(_coyote_timer):
		velocity.y = _jump_impulse
		_rem_jumps -= 1
		_jumpbuf_timer = null
	elif not _is_timer_running(_jumpbuf_timer):
		_jumpbuf_timer = get_tree().create_timer(jumpbuffer_time)


func _do_dash() -> void:
	var has_dashs := _rem_dashs > 0 and _rem_jumps <= max_dashs
	if has_dashs and not _is_timer_running(_dash_delay_timer):
		velocity.x = _dash_impulse * _prev_dir
		_rem_dashs -= 1
		_dash_delay_timer = get_tree().create_timer(dash_cooldown_time)


func _try_corner_correct(delta: float, horizontal: bool) -> void:
	var relative_vel := Vector2(0.0, velocity.y * delta)
	if horizontal:
		relative_vel = Vector2(velocity.x * delta, 0.0)

	if not test_move(global_transform, relative_vel):
		return # Seems like the next frames will not make the playr collide

	for i in range(1, _CORRECTION_AMOUNT * 2 + 1):
		for j in [-1.0, 1.0]:
			# If 'horizontal' is true, the correction is done on the Horizontal Axis
			var translation := Vector2(i * j / 2, 0.0)
			if horizontal:
				translation = Vector2(0.0, i * j / 2)

			# Try to find an empty spot to put the player on
			if not test_move(global_transform.translated(translation), relative_vel):
				translate(translation)
				return


func _is_timer_running(timer: SceneTreeTimer) -> bool:
	return timer != null and not is_zero_approx(timer.time_left)
