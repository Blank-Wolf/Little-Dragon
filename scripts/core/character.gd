class_name Character
extends CharacterBody2D

var has_hit_entered: bool = false
var has_hurt_entered: bool = false
var collision_body: Node2D


func _is_falling() -> bool:
	return not is_on_floor()


func _on_hit_box_body_entered(body: Node2D) -> void:
	print("hit entered")
	collision_body = body
	has_hit_entered = true


func _on_hit_box_body_exited(_body: Node2D) -> void:
	collision_body = null
	has_hit_entered = false


func _on_hurt_box_body_entered(body: Node2D) -> void:
	print("hurt entered")
	collision_body = body
	has_hurt_entered = true


func _on_hurt_box_body_exited(_body: Node2D) -> void:
	collision_body = null
	has_hurt_entered = false