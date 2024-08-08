extends Node2D


func get_hit(damage: int, impulse: Vector2) -> void:
	$Animation.play("hit")
