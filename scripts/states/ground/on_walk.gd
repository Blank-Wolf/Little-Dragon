extends BaseState

@export var movement: MovementComponent
@export var controller: PlayerController

@onready var body := movement.body


func _update(_delta: float) -> void:
	if controller.direction == 0.0:
		completed.emit("Idle", {})


func _physics_update(delta: float) -> void:
	var mult := 1.0
	if controller.direction != signf(body.get_last_motion().x):
		mult = 2.0 # Prevent player slipping behavior

	movement.apply_acceleration(delta, controller.direction, mult)
