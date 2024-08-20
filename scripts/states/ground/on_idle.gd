extends BaseState

@export var movement: MovementComponent
@export var controller: PlayerController

@onready var body := movement.body


func _update(_delta: float) -> void:
	if controller.direction != 0.0:
		completed.emit("Walk", {})


func _physics_update(delta: float) -> void:
	movement.apply_friction(delta, movement.ground_friction)
