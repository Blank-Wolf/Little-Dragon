class_name EnemyController
extends Controller

# Points the enemy will patrol between
var points: Array[Node2D]

var _curr_target = 0
var _target: Node2D


func _enter_tree() -> void:
	owner.set_meta(&"Controller", self)


func _ready() -> void:
	if points.size() != 0:
		print("point 1: ", points[0].position)


func patrol() -> void:
	if points.size() != 0:
		if _target == null:
			_target = points[0]
		
		if abs(_target.position.x - owner.position.x) <= 2.0:
			_curr_target = (_curr_target + 1) % points.size()
			_target = points[_curr_target]
					
		direction.x = sign(_target.position.x - owner.position.x)
