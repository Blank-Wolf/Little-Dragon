extends BaseState

var _jump: JumpComponent
var _movement: MovementComponent
var _controller: Controller


func _ready() -> void:
	_jump = owner.get_meta(&"JumpComponent")

	if owner.has_meta(&"MovementComponent"):
		_movement = owner.get_meta(&"MovementComponent")

	if owner.has_meta(&"Controller"):
		_controller = owner.get_meta(&"Controller")


func _enter(msg: Dictionary) -> void:
	if msg.has("was_on_floor") and msg.was_on_floor:
		_jump.start_coyote() # Let the owner jump for a brief momemt
		_jump.do_jump(1, true) # Consume a jump since we didn't jump earlier


func _physics_update(delta: float) -> void:
	if _movement != null and _controller != null:
		_movement.apply_acceleration(delta, _controller.direction.x)

	if not _jump.is_coyote_timing():
		_jump.apply_gravity(delta, _jump.GravityKind.FALL)
