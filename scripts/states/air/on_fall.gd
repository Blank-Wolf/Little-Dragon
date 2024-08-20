extends BaseState

@export_group("Components")
@export var movement: MovementComponent
@export var controller: PlayerController

var _consume_jumps := 0

@onready var body := movement.body


func _enter(msg: Dictionary) -> void:
	controller.connect("jump_pressed", _on_controller_jump_pressed)

	_consume_jumps = 0
	if msg.has("was_on_floor") and msg.was_on_floor:
		_consume_jumps += 1


func _exit() -> void:
	# Just for sanity-check, this shouldn't be necessary
	controller.disconnect("jump_pressed", _on_controller_jump_pressed)


func _update(_delta: float) -> void:
	if body.is_on_floor():
		completed.emit("Ground", {})


func _physics_update(delta: float) -> void:
	movement.apply_gravity(delta, movement.fall_gravity)


func _on_controller_jump_pressed() -> void:
	completed.emit("Jump", { "consume_jumps": _consume_jumps })
