class_name EnemyController
extends Controller

var points: Array[Node2D]


var prev_direction: float


func _enter_tree() -> void:
	owner.set_meta(&"Controller", self)

func _ready() -> void:
	if points.size() != 0:
		print("point 1: ", points[0].position)

	
# here I altern the direction
