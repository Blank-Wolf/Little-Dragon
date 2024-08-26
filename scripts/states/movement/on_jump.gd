extends BaseState

var _jump: JumpComponent
var _movement: MovementComponent
var _controller: PlayerController


func _ready() -> void:
	_jump = owner.get_meta(&"JumpComponent")

	if owner.has_meta(&"MovementComponent"):
		_movement = owner.get_meta(&"MovementComponent")

	if owner.has_meta(&"Controller"):
		_controller = owner.get_meta(&"Controller")


func _enter(_msg: Dictionary) -> void:
	_jump.do_jump()


func _physics_update(delta: float) -> void:
	_jump.apply_gravity(delta, _jump.GravityKind.JUMP)
	_jump.try_corner_correct(delta, false)

	if _movement != null and _controller != null:
		_movement.apply_acceleration(delta, _controller.direction.x)

	# Cut the _jump if the controller isn't pressing "jump" anymore
	if _controller != null and _controller.was_jump_released():
		owner.velocity.y /= 2.0
