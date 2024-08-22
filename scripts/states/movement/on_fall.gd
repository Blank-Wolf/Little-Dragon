extends BaseState

@export var _controller: PlayerController
@export var _movement: MovementComponent
@export var _jump: JumpComponent


func _ready() -> void:
	assert(_jump != null, "Jump component isn't attached!")


func _enter(msg: Dictionary) -> void:
	if msg.has("was_on_floor") and msg.was_on_floor:
		_jump.start_coyote() # Let the owner jump for a brief momemt
		_jump.do_jump(1, true) # Sometimes, we start falling but not from a jump


func _physics_update(delta: float) -> void:
	if _movement != null and _controller != null:
		_movement.apply_acceleration(delta, _controller.direction.x)

	if not _jump.is_coyote_timing():
		_jump.apply_gravity(delta, _jump.GravityKind.FALL)
