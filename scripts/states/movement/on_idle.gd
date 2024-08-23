extends BaseState

@export var _movement: MovementComponent

var _was_on_floor: bool


func _ready() -> void:
	assert(_movement != null, "Movement Component isn't attached!")


func _enter(_msg: Dictionary) -> void:
	_was_on_floor = false


func _exit() -> Dictionary:
	return {
		"was_on_floor": _was_on_floor,
	}


func _physics_update(delta: float) -> void:
	if owner.is_on_floor():
		_was_on_floor = true
	_movement.apply_friction(delta)
