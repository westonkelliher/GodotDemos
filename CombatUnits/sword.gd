extends Node2D


func swing() -> void:
	$Animation.seek(0)
	$Animation.play("slash")

func can_swing() -> bool:
	return not $Animation.is_playing()


func set_wielder(guy: Guy) -> void:
	$Pivot/HitBox.wielder = guy
