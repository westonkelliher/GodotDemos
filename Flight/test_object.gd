extends CharacterBody3D


func _physics_process(delta: float) -> void:
	velocity.y = 0.5
	move_and_slide()
