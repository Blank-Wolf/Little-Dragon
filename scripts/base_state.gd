class_name BaseState
extends Node
## Base state node template for StateMachine
##
## This node only purpose is to serve as an base for new
## states behaviours.


signal registered ## Called when the state has added to a StateMachine
signal completed(next: String, msg: Dictionary)


func _enter(_msg: Dictionary) -> void:
	pass


func _exit() -> void:
	pass


func _update(_delta: float) -> void:
	pass


func _physics_update(_delta: float) -> void:
	pass
