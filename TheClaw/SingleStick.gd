extends Node3D


const MAX_ANGLE_FROM_STICK := 30.0
const MAX_ANGLE_FROM_TRIG := 40.0
const MAX_ANGULAR_SPEED := 8.0

const REMEMBER_THRESHOLD := 0.1

var remembered_stick_vec := Vector2.RIGHT
var arm_vector := Vector3.UP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var arm_l := Input.get_action_raw_strength("LS_left")
	var arm_r := Input.get_action_raw_strength("LS_right")
	var arm_u := Input.get_action_raw_strength("LS_up")
	var arm_d := Input.get_action_raw_strength("LS_down")
	var lt0 := Input.get_action_raw_strength("LT0")
	var lt1 := Input.get_action_raw_strength("LT1")
	#
	var ltrig := (1.0 - lt0 + lt1)/2.0
	if lt0 == 0 && lt1 == 0:
		ltrig = 0
	var arm_totals := pow((0.01 + arm_l + arm_r + arm_u + arm_d), .9)
	var raw_x := arm_r - arm_l
	var raw_y := arm_u - arm_d
	var raw_diff: float = abs(abs(raw_x) - abs(raw_y))
	var arm_x := raw_x / (1 + pow(1 - raw_diff, 1.5)*0.3)
	var arm_y := raw_y / (1 + pow(1 - raw_diff, 1.5)*0.3)
	# stick angle and intensity
	var stick_vec := Vector2(arm_x, arm_y)
	if stick_vec.length() > 0.85:
		stick_vec = stick_vec.normalized()*0.85
	stick_vec /= 0.85
	if stick_vec.length() > REMEMBER_THRESHOLD:
		var lerp_amnt := 1 - pow(0.000001, delta)
		remembered_stick_vec = remembered_stick_vec.lerp(stick_vec.normalized(), lerp_amnt)
	var stick_angle := stick_vec.angle()
	print(stick_vec)
	print(stick_angle)
	var stick_intensity := stick_vec.length()
	var stick_axis := Vector3.RIGHT.rotated(Vector3.UP, stick_angle - PI/2)
	var proj_2d := Vector2.RIGHT.rotated(stick_angle)
	$D/Projection.target_position = Vector3(proj_2d.x, 0.0, -proj_2d.y)
	# trig angle and intensity
	var trig_angle: float = remembered_stick_vec.angle()
	var trig_intensity := ltrig
	var trig_axis := Vector3.RIGHT.rotated(Vector3.UP, trig_angle - PI/2)
	#
	var stick_rot := -stick_intensity * MAX_ANGLE_FROM_STICK * PI/180
	var trig_rot := -trig_intensity * MAX_ANGLE_FROM_TRIG * PI/180
	var target_vec := Vector3.UP.rotated(stick_axis, stick_rot)
	target_vec = target_vec.rotated(trig_axis, trig_rot)
	$D/Target.target_position = target_vec*2
	# 
	move_toward_target(target_vec, delta)
	$D/Stick.target_position = arm_vector*2
	var full_rot := -Vector3.UP.angle_to(arm_vector)
	var full_axis := arm_vector.cross(Vector3.UP).normalized()
	#
	var top_basis := Vector3.UP.rotated(full_axis, full_rot)
	var forward_basis := Vector3.BACK.rotated(full_axis, full_rot)
	var right_basis := top_basis.cross(forward_basis).normalized()
	$BaseArm.basis = Basis(right_basis, top_basis, forward_basis).orthonormalized()
	###
	#var floor_projection = Vector2(arm_x, arm_y)
	#if floor_projection.length() > REMEMBER_THRESHOLD:
		#remembered_direction = floor_projection.normalized()
	#if floor_projection.length() > 0.85:
		#floor_projection = floor_projection.normalized()*0.85
	#floor_projection /= 0.85
	##
	#var projection_3d = Vector3(floor_projection.x, 0.0, floor_projection.y)
	#$D/Projection.target_position = projection_3d
	## a^2 + b^2 = c^2  |  a^2 = 1 - b^2  |  a = sqrt(1 - b^2)
	#var vert_len = sqrt(1 - floor_projection.length()*0.85)
	#var vec_from_stick = Vector3(floor_projection.x, vert_len, floor_projection.y)
	#$D/Normal.target_position = full_3d
	##
	#var rot_axis = full_3d.cross(Vector3.UP).normalized()
	#var angle_from_stick = floor_projection.length() * MAX_ANGLE_FROM_STICK
	#var angle_from_trig = ltrig * MAX_ANGLE_FROM_TRIG
	#var rot_angle = -(angle_from_stick + angle_from_trig)*PI/180.0
	#var top_basis = Vector3(0.01, 0.99, 0.01).rotated(rot_axis, rot_angle)
	#var forward_basis = Vector3.BACK.rotated(rot_axis, rot_angle)
	#var right_basis = top_basis.cross(forward_basis)
	#$BaseArm.basis = Basis(right_basis, top_basis, forward_basis).orthonormalized()
	
func move_toward_target(target: Vector3, delta: float) -> void:
	var angle := MAX_ANGULAR_SPEED*delta
	print(angle)
	if arm_vector.angle_to(target) < angle:
		print("yo")
		arm_vector = target
		return
	var axis := arm_vector.cross(target).normalized()
	arm_vector = arm_vector.rotated(axis, angle)
