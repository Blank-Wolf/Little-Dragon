class_name BaseState
extends Node
## Base state node template for StateMachine. [br]
## This node only purpose is to serve as a base for new
## states behaviours.

var machine: StateMachine


func _register() -> void:
	pass


func _enter(_msg: Dictionary) -> void:
	pass


func _exit() -> Dictionary:
	return {}


func _update(_delta: float) -> void:
	pass


func _physics_update(_delta: float) -> void:
	pass
