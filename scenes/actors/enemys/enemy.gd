class_name Enemy
extends CharacterBody2D

@export var points: Array[Node2D]

@onready var _state_machine := $StateMachine
@onready var _controller := $EnemyController
@onready var _jump := $JumpComponent

var has_body_entered: bool = false

func _ready() -> void:
	_controller.points = points

	var states: Dictionary = {
		"Idle": StateData.new($StateMachine/OnIdle, {
				"Fall": _is_falling,
				"Walk": func(): return _controller.direction.x != 0.0,
		}),
		"Walk": StateData.new($StateMachine/OnWalk, {
			"Fall": _is_falling,
			"Idle": func(): return _controller.direction.x == 0.0,
		}),
		"Fall": StateData.new($StateMachine/OnFall, {
			"Idle": is_on_floor,
		}),
	}

	_state_machine.setup("Idle", states)


func _physics_process(_delta: float) -> void:
	move_and_slide()

	if is_on_floor():
		_jump.reset()
		_controller.patrol()


func _is_falling() -> bool:
	return not is_on_floor()


func _on_hitbox_body_entered(_body: Node2D) -> void:
	has_body_entered = true


func _on_hitbox_body_exited(_body: Node2D) -> void:
	has_body_entered = false
