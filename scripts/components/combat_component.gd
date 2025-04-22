class_name CombatComponent
extends Node

@export_group("Data")
@export var attack_damage: int = 0


func _enter_tree() -> void:
	owner.set_meta(&"CombatComponent", self)


func _ready() -> void:
	assert(owner is CharacterBody2D, "Component owner is not a CharacterBody2D")


func _process(_delta: float) -> void:
	# TODO: add cooldown to attack
	if can_attack():
		attack()


func attack() -> void:
	# TODO: decrease player/enemy life
	print("Attack!")


func can_attack() -> bool:
	return owner.has_hit_entered
