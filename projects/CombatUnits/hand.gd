extends Node2D

const BASE_AGGRESSION_V := Vector2(40.0, -32.0)
const BASE_AGGRESSION_R := 24.0

@export var held_item: Node2D:
	set(value):
		held_item = value
		$Pivot/Held.add_child(held_item)
		if held_item == null:
			$Pivot/HitBox.monitorable = true
			$Animation.speed_scale = 1.0
			$Aggression/Shape.shape.radius = BASE_AGGRESSION_R
			$Aggression/Shape.position = BASE_AGGRESSION_V
		else:
			$Pivot/HitBox.monitorable = false
			$Animation.speed_scale = 0.8
			var ag_mod: CollisionShape2D = held_item.get_aggression()
			var ag_circle: CircleShape2D = ag_mod.shape
			var new_circle := CircleShape2D.new()
			var rad_mod: float = ag_circle.radius * $Pivot/Held.scale.x
			var pos_mod: Vector2 = ag_mod.position.rotated($Pivot.rotation) * $Pivot/Held.scale.x
			new_circle.radius = BASE_AGGRESSION_R + rad_mod
			var new_vec := BASE_AGGRESSION_V + pos_mod
			$Aggression/Shape.shape = new_circle
			$Aggression/Shape.position = new_vec
	get:
		return held_item

var swing_rate := 1.0
var victims := []

func _ready() -> void:
	$Pivot/HitBox.wielder = owner

func swing() -> void:
	$Animation.seek(0)
	$Animation.play("swing")
	if held_item != null:
		held_item.swing()

func can_swing() -> bool:
	if held_item != null:
		if not held_item.can_swing():
			return false
	return not $Animation.is_playing()

func counter_size(s: float) -> void:
	$Pivot/Held.scale = Vector2.ONE * 1/s

func get_corpus() -> Guy:
	return owner

func has_victim() -> bool:
	return not victims.is_empty()

func wants_to_swing() -> bool:
	return has_victim() and can_swing()

func _on_aggression_body_entered(body: Node2D) -> void:
	if body is Guy:
		if body.team != get_corpus().team or body.team == Guy.Team.GRAY:
			victims.append(body)

func _on_aggression_body_exited(body: Node2D) -> void:
	victims.erase(body)
