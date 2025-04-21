class_name Enemy
extends CharacterBody2D

@onready var _state_machine := $StateMachine

@onready var _controller := $EnemyController
@onready var _jump := $JumpComponent


func _is_falling() -> bool:
	return not is_on_floor()