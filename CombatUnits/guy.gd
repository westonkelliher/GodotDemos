extends RigidBody2D



func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_down"):
		$Sword.swing()


func get_hit(attack: Attack) -> void:
	$Animation.play("hit")
	self.apply_impulse(attack.get_impulse())
