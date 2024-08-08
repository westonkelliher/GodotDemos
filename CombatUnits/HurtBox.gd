class_name HurtBox
extends Area2D


func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(hitbox: HitBox) -> void:
	print("hey")
	if hitbox == null:
		return
	if owner.has_method("get_hit"):
		owner.get_hit(hitbox.damage, hitbox.get_impulse(self))
