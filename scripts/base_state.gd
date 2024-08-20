class_name BaseState
extends Node
## Base state node template for StateMachine. [br]
## This node only purpose is to serve as a base for new
## states behaviours.

@warning_ignore("unused_signal")
signal registered ## Called when the state has added to a StateMachine
@warning_ignore("unused_signal")
signal completed(next: String, msg: Dictionary)

var machine: StateMachine

func _enter(_msg: Dictionary) -> void:
	pass


func _exit() -> void:
	pass


func _update(_delta: float) -> void:
	pass


func _physics_update(_delta: float) -> void:
	pass
