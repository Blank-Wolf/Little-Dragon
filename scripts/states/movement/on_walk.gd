extends BaseState

var _controller: Controller
var _movement: MovementComponent


func _ready() -> void:
	_controller = owner.get_meta(&"Controller")
	_movement = owner.get_meta(&"MovementComponent")


func _exit() -> Dictionary:
	return {
		"was_on_floor": true, # The walk state is always on the floor
	}


func _physics_update(delta: float) -> void:
	_movement.apply_acceleration(delta, _controller.direction.x)
