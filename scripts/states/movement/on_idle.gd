extends BaseState

@export var _movement: MovementComponent


func _ready() -> void:
	assert(_movement != null, "Movement Component isn't attached!")


func _exit() -> Dictionary:
	return {
		"was_on_floor": true, # The idle state is always on the floor
	}


func _physics_update(delta: float) -> void:
	_movement.apply_friction(delta)
