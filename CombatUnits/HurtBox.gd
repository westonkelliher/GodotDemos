class_name HurtBox
extends Area2D

@export var corpus: Guy = null

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if owner.has_method("get_corpus"):
		corpus = owner.get_corpus()
		print("ds "+str(corpus))
	else:
		print("owner: "+str(owner))

func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox == null:
		print("null hitbox")
		return
	if hitbox.wielder != null:
		print(hitbox.wielder)
		if hitbox.wielder == corpus:
			print("self hit")
			#don't hit yourself
			return
		if corpus != null and hitbox.wielder.team == corpus.team:
			print("friendly fire")
			# no friendly fire
			return
	else:
		print("no wielder hit")
	if owner.has_method("get_hit"):
		var attack := Attack.new()
		attack.hitbox = hitbox
		attack.hurtbox = self
		owner.get_hit(attack)



func get_mass_center() -> Vector2:
	return global_position
