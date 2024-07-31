extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_down"):
		$ArmRight/Shoulder["angular_motor_x/enabled"] = true
		$ArmRight/Shoulder["angular_motor_x/target_velocity"] = 100
