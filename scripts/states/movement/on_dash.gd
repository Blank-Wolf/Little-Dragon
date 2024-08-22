extends BaseState

@export var _controller: PlayerController
@export var _dash: DashComponent
@export var _jump: JumpComponent


func _ready() -> void:
	assert(_controller != null, "Controller Component isn't attached!")
	assert(_dash != null, "Dash Component isn't attached!")


func _enter(msg: Dictionary) -> void:
	var dir := _controller.dash_direction

	# We can't dash up if we are on the floor
	if msg.has("was_on_floor") and msg.was_on_floor:
		dir.y = 0.0

	# Consume all jumps if we are dashing up/down
	if dir.y != 0.0 and _jump != null:
		_jump.do_jump(_jump.max_jumps, true)

	_dash.do_dash(dir.normalized())


func _physics_update(delta: float) -> void:
	_dash.apply_stop_force(delta)

	if _jump != null:
		_jump.try_corner_correct(delta, false)
		_jump.try_corner_correct(delta, true)
