extends BaseState

@export var max_jumps: int = 2

@export_group("Components")
@export var movement: MovementComponent
@export var controller: PlayerController

var _rem_jumps := max_jumps

@onready var body := movement.body


func _enter(msg: Dictionary) -> void:
	controller.connect("jump_released", _on_controller_jump_released)

	# Sometimes, we started falling but not from a jump
	if msg.has("consume_jumps"):
		_rem_jumps -= msg.consume_jumps

	if msg.has("was_on_floor") and msg.was_on_floor:
		_rem_jumps = max_jumps

	if _can_jump():
		movement.do_jump()
		_rem_jumps -= 1
	else:
		# We failed to do a jump, so go to the state ground state
		completed.emit("Ground", {})


func _exit() -> void:
	# Just for sanity-check, this shouldn't be necessary
	controller.disconnect("jump_released", _on_controller_jump_released)


func _update(_delta: float) -> void:
	if body.velocity.y >= 0.0:
		completed.emit("Fall", {})


func _physics_update(delta: float) -> void:
	movement.apply_gravity(delta, movement.jump_gravity)
	movement.try_corner_correct(delta, false)


func _can_jump() -> bool:
	var has_jumps := _rem_jumps > 0 and _rem_jumps <= max_jumps
	return body.is_on_floor() or has_jumps


func _on_controller_jump_released() -> void:
	# Cut the jump if the player isn't pressing "jump" and we're still jumping
	if body.velocity.y < 0.0:
		body.velocity.y /= 2.0
