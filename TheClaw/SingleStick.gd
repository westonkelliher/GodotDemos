extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var arm_l = Input.get_action_raw_strength("LS_left")
	var arm_r = Input.get_action_raw_strength("LS_right")
	var arm_u = Input.get_action_raw_strength("LS_up")
	var arm_d = Input.get_action_raw_strength("LS_down")
	var arm_totals = pow((0.01 + arm_l + arm_r + arm_u + arm_d), .9)
	var raw_x = arm_r - arm_l
	var raw_y = arm_d - arm_u
	var raw_diff = abs(abs(raw_x) - abs(raw_y))
	var arm_x = raw_x / (1 + pow(1 - raw_diff, 1.5)*0.3)
	var arm_y = raw_y / (1 + pow(1 - raw_diff, 1.5)*0.3)
	var floor_projection = Vector2(arm_x, arm_y)
	#
	$D/Projection.target_position = Vector3(arm_x, 0.0, arm_y)
	
