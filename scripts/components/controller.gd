class_name Controller
extends Node

var direction: Vector2


func _enter_tree() -> void:
	owner.set_meta(&"Controller", self)