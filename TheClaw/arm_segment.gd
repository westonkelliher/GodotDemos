extends Node3D


@export var MAX_ANGLE_FROM_STICK := 30.0
@export var MAX_ANGLE_FROM_TRIG := 40.0
@export var LENGTH := 1.8 :
	set(value):
		LENGTH = value
		$Arm/Shape.shape = $Arm/Shape.shape.duplicate()
		$Arm/Shape.shape.height = LENGTH+0.2
		$Arm/Shape.position.y = LENGTH/2.0
		$Arm/Mesh.mesh = $Arm/Mesh.mesh.duplicate()
		$Arm/Mesh.mesh.height = LENGTH+0.2
		$Arm/Mesh.position.y = LENGTH/2.0
		$Arm/End.position.y = LENGTH
	get:
		return LENGTH


const MAX_ANGULAR_SPEED := 6.0
const MIN_ANGULAR_SPEED := 1.0

const REMEMBER_THRESHOLD := 0.1



var remembered_stick_vec := Vector2.RIGHT
var arm_vector := Vector3.UP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func handle_input(stick_position: Vector2, trig_level: float, delta: float) -> void:
	# stick angle and intensity
	var stick_vec := stick_position
	if stick_vec.length() > 0.85:
		stick_vec = stick_vec.normalized()*0.85
	stick_vec /= 0.85
	if stick_vec.length() > REMEMBER_THRESHOLD:
		var lerp_amnt := 1 - pow(0.000001, delta)
		remembered_stick_vec = remembered_stick_vec.lerp(stick_vec.normalized(), lerp_amnt)
	var stick_angle := stick_vec.angle()
	var stick_intensity := stick_vec.length()
	var stick_axis := Vector3.RIGHT.rotated(Vector3.UP, stick_angle - PI/2)
	var proj_2d := Vector2.RIGHT.rotated(stick_angle)
	# trig angle and intensity
	var trig_angle: float = remembered_stick_vec.angle()
	var trig_intensity := trig_level
	var trig_axis := Vector3.RIGHT.rotated(Vector3.UP, trig_angle - PI/2)
	#
	var stick_rot := -stick_intensity * MAX_ANGLE_FROM_STICK * PI/180
	var trig_rot := -trig_intensity * MAX_ANGLE_FROM_TRIG * PI/180
	var target_vec := Vector3.UP.rotated(stick_axis, stick_rot)
	target_vec = target_vec.rotated(trig_axis, trig_rot)
	# 
	move_toward_target(target_vec, delta)
	var full_rot := -Vector3.UP.angle_to(arm_vector)
	var full_axis := arm_vector.cross(Vector3.UP).normalized()
	#
	var top_basis := Vector3.UP.rotated(full_axis, full_rot)
	var forward_basis := Vector3.BACK.rotated(full_axis, full_rot)
	var right_basis := top_basis.cross(forward_basis).normalized()
	basis = Basis(right_basis, top_basis, forward_basis).orthonormalized()
	###

func move_toward_target(target: Vector3, delta: float) -> void:
	var angular_speed := MIN_ANGULAR_SPEED + 40.0*pow(arm_vector.angle_to(target), 3)
	if angular_speed > MAX_ANGULAR_SPEED:
		angular_speed = MAX_ANGULAR_SPEED
	if arm_vector.angle_to(target) < angular_speed*delta:
		arm_vector = target
		return
	var axis := arm_vector.cross(target).normalized()
	arm_vector = arm_vector.rotated(axis, angular_speed*delta)
