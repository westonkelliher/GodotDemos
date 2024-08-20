extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var MIN_GRAV_MULT := 0.16
var MAX_GRAV_MULT := 0.48

const MAX_WING_ANGLE := 0.3  
const MIN_WING_ANGLE := -0.8
const MAX_WING_SPEED := 4.0
const WING_ACC := 40.0
const LIFT_MULT := 3.0
const DIFT_MULT := 0.8

var wing_speed := 0.0
var wing_angle := 0.0

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("ui_accept") and wing_angle > MIN_WING_ANGLE:
		wing_speed = move_toward(wing_speed, -MAX_WING_SPEED, WING_ACC*delta)
	elif !Input.is_action_pressed("ui_accept") and wing_angle < MAX_WING_ANGLE:
		wing_speed = move_toward(wing_speed, MAX_WING_SPEED, WING_ACC*delta)
	#
	wing_angle += wing_speed*delta
	if wing_angle > MAX_WING_ANGLE:
		wing_angle = MAX_WING_ANGLE
		wing_speed = 0.0
	elif wing_angle < MIN_WING_ANGLE:
		wing_angle = MIN_WING_ANGLE
		wing_speed = 0.0
	#
	if wing_speed < 0:
		var lift: float = abs(wing_speed) * cos(wing_angle) * LIFT_MULT
		velocity.y += lift * delta
	elif wing_speed > 0:
		var dift: float = abs(wing_speed) * cos(wing_angle) * DIFT_MULT
		velocity.y -= dift * delta
	
	$Wings/LeftWing.set_flap_angle(wing_angle)
	$Wings/RightWing.set_flap_angle(wing_angle)
		
		
	# Add the gravity.
	if not is_on_floor():
		var grav_dif := MAX_GRAV_MULT - MIN_GRAV_MULT
		var grav_mult: float = MIN_GRAV_MULT + grav_dif*abs(sin(wing_angle))
		var grav := gravity*grav_mult
		velocity.y -= grav * delta
	
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
