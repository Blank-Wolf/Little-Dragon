extends BaseState

@export var coyote_time := 0.08
@export var jumpbuffer_time := 0.1

@export_group("Components")
@export var movement: MovementComponent
@export var controller: PlayerController

var _was_on_floor: bool

var _coyote_timer: SceneTreeTimer
var _jumpbuf_timer: SceneTreeTimer

@onready var body := movement.body


func _enter(_msg: Dictionary) -> void:
	controller.connect("jump_pressed", _on_controller_jump_pressed)

	# Seems like we failed to do a jump, so we buffer it to try later
	if machine.previous_state == "Jump" and not _is_timer_ticking(_jumpbuf_timer):
		_jumpbuf_timer = get_tree().create_timer(jumpbuffer_time)


func _exit() -> void:
	# Just for sanity-check, this shouldn't be necessary
	controller.disconnect("jump_pressed", _on_controller_jump_pressed)


func _update(_delta: float) -> void:
	if body.is_on_floor():
		_was_on_floor = true

		# The jump is buffered? Then attempt a jump
		if _is_timer_ticking(_jumpbuf_timer):
			completed.emit("Jump", { "was_on_floor": _was_on_floor })
	else:
		# If the player was on the floor, can do the coyote time
		# have mercy and let it jump for a brief time
		if _was_on_floor:
			_coyote_timer = get_tree().create_timer(coyote_time)
			_was_on_floor = false

		if not _is_timer_ticking(_coyote_timer):
			completed.emit("Fall", { "was_on_floor": true })


func _is_timer_ticking(timer: SceneTreeTimer) -> bool:
	return timer != null and timer.time_left > 0.0


func _on_controller_jump_pressed() -> void:
	if body.is_on_floor() or _is_timer_ticking(_coyote_timer):
		completed.emit("Jump", { "was_on_floor": true })
