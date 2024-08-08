extends Node2D


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		$Sword/Animation.play("slash")
