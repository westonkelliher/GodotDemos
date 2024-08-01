extends Node3D


const MAX_ANGLE_FROM_STICK = 40.0
const MAX_ANGLE_FROM_TRIG = 40.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var arm_l = Input.get_action_raw_strength("LS_left")
	var arm_r = Input.get_action_raw_strength("LS_right")
	var arm_u = Input.get_action_raw_strength("LS_up")
	var arm_d = Input.get_action_raw_strength("LS_down")
	var lt0 = Input.get_action_raw_strength("LT0")
	var lt1 = Input.get_action_raw_strength("LT1")
	var ltrig = (1.0 - lt0 + lt1)/2.0
	if lt0 == 0 && lt1 == 0:
		ltrig = 0
	print(Vector2(lt0, lt1))
	print(ltrig)
	var arm_totals = pow((0.01 + arm_l + arm_r + arm_u + arm_d), .9)
	var raw_x = arm_r - arm_l
	var raw_y = arm_d - arm_u
	var raw_diff = abs(abs(raw_x) - abs(raw_y))
	var arm_x = raw_x / (1 + pow(1 - raw_diff, 1.5)*0.3)
	var arm_y = raw_y / (1 + pow(1 - raw_diff, 1.5)*0.3)
	var floor_projection = Vector2(arm_x, arm_y)
	if floor_projection.length() > 0.85:
		floor_projection = floor_projection.normalized()*0.85
	floor_projection /= 0.85
	#
	var projection_3d = Vector3(floor_projection.x, 0.0, floor_projection.y)
	$D/Projection.target_position = projection_3d
	# a^2 + b^2 = c^2  |  a^2 = 1 - b^2  |  a = sqrt(1 - b^2)
	var vert_len = sqrt(1 - floor_projection.length()*0.85)
	var full_3d = Vector3(floor_projection.x, vert_len, floor_projection.y)
	$D/Normal.target_position = full_3d
	#
	var rot_axis = full_3d.cross(Vector3.UP)
	var angle_from_stick = floor_projection.length() * MAX_ANGLE_FROM_STICK
	var angle_from_trig = ltrig * MAX_ANGLE_FROM_TRIG
	var rot_angle = -(angle_from_stick + angle_from_trig)*PI/180.0
	print(str(rot_angle) + " -")
	print(rot_axis)
	var top_basis = Vector3(0.01, 0.99, 0.01).rotated(rot_axis.normalized(), rot_angle)
	print(top_basis)
	var forward_basis = Vector3.BACK.rotated(rot_axis, rot_angle)
	var right_basis = top_basis.cross(forward_basis)
	$BaseArm.basis = Basis(right_basis, top_basis, forward_basis).orthonormalized()
	print($BaseArm.basis)
	
