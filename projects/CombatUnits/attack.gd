class_name Attack
extends Node


var hitbox: HitBox = null
var hurtbox: HurtBox = null
var wielder_damage := 1
var effects := {}


func get_impulse() -> Vector2:
	var hit_center := hitbox.get_mass_center()
	var hurt_center := hurtbox.get_mass_center()
	var toward := (hurt_center - hit_center).normalized()
	return toward*hitbox.impact

func get_damage() -> int:
	return wielder_damage + hitbox.damage
