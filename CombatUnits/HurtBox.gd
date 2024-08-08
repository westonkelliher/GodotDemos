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
		var attack := Attack.new()
		attack.hitbox = hitbox
		attack.hurtbox = self
		owner.get_hit(attack)



func get_mass_center() -> Vector2:
	return global_position
