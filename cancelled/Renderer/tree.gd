extends Node3D


func set_animation(progress: float) -> void:
	var full_length: float = $AnimationPlayer.current_animation_length
	$AnimationPlayer.play("ArmatureAction")
	$AnimationPlayer.seek(progress*full_length, true)
