extends Node2D


@export var held_item: Node2D:
	set(value):
		held_item = value
		$Pivot/Held.add_child(held_item)
		if held_item == null:
			$Pivot/HitBox.monitorable = true
			$Animation.speed_scale = 1.0
		else:
			$Pivot/HitBox.monitorable = false
			$Animation.speed_scale = 0.8
	get:
		return held_item


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

func get_corpus() -> Guy:
	return owner
