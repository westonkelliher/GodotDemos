class_name HitBox
extends Area2D


@export var damage := 0
@export var impact := 40000.0
@export var wielder: Guy = null
#var impulse

func _init() -> void:
	collision_layer = 2
	collision_mask = 0


func get_impulse(hurtbox: HurtBox) -> Vector2:
	return Vector2.ZERO

func get_mass_center() -> Vector2:
	return global_position
