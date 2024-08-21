extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var MIN_GRAV_MULT := 0.10 # flat wings parallel with the ground
var GRAV_FROM_FLAPPED := 0.20 # additional gravity when wings are fully flapped
var MAX_GRAV_MULT := 0.30

# lift
const LIFT_MULT := 3.0
const DIFT_MULT := 0.8

# torso tilt
const MAX_TORSO_TILT_SPEED := 1.0 # as fraction not in radians
const TORSO_TILT_ACC := 0.5
const TORSO_DETILT_ACC := 2.0
const TORSO_TILT_START := -PI/4.0
const TORSO_TILT_END := -PI/2.0
var torso_tilt_speed := 0.0
var torso_tilt := 0.0 # min 0.0 max 1.0

# flap
# : negative number means downward position
const MAX_FLAP_ANGLE := 0.2  
const MIN_FLAP_ANGLE := -0.8
const MAX_FLAP_SPEED := 4.0
const FLAP_ACC := 40.0
var flap_speed := 0.0
var flap_angle := 0.0

# wing pitch
const MAX_WING_PITCH := 0.6
const MIN_WING_PITCH := -0.6
const MAX_WING_PITCH_SPEED := 6.0
const WING_PITCH_ACC := 18.0
var wing_pitch := 0.0
var wing_pitch_speed := 0.0

# wing roll
# : affects roll speed of the bird as a whole
# : proportional to body roll acceleration
const MAX_WING_ROLL := 0.3
const MIN_WING_ROLL := -0.3
const WING_ROLL_SPEED := 2.0
var wing_roll := 0.0

# body roll
var BODY_ROLL_RATE := 3.0
var STATIC_BODY_ROLL_DAMPING := 0.1
var ACTIVE_BODY_ROLL_DAMPING := 0.6
var body_roll_speed := 0.0  # added to rotation.z

# tip pitch
# : set by click drag y-distance
# : proportional to body pitch speed
var MAX_TIP_PITCH := 0.7
var MIN_TIP_PITCH := -0.7
var MAX_TIP_PITCH_DIST := 200.0
var TIP_PITCH_RATE := 0.05
var tip_pitch := 0.0

# mouse drags
var drag_start := Vector2.ZERO # relative to center of screens
var is_dragging := false

#### Builtins ####
func _process(delta: float) -> void:
	$D/Vecs.global_position = global_position

func _physics_process(delta: float) -> void:
	handle_torso_tilt(delta)
	handle_flap(delta)
	handle_wing_pitch(delta)
	handle_wing_roll(delta)
	handle_mouse_drags(delta)
	#
	# flapping
	var lift_normal := Vector3.UP.rotated(Vector3.RIGHT, wing_pitch)
	lift_normal = lift_normal.rotated(Vector3.FORWARD, -wing_roll)
	lift_normal = basis * lift_normal
	if flap_speed < 0:
		var lift: float = abs(flap_speed) * cos(flap_angle) * LIFT_MULT
		velocity += lift_normal * lift * delta
		#
	elif flap_speed > 0:
		var dift: float = abs(flap_speed) * cos(flap_angle) * DIFT_MULT
		velocity -= lift_normal * dift * delta
	#
	# rolling
	if flap_speed < 0:
		body_roll_speed += flap_speed * wing_roll * BODY_ROLL_RATE * delta
	rotation.z += (1 - sin(flap_angle))*body_roll_speed * delta
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		body_roll_speed *= pow(ACTIVE_BODY_ROLL_DAMPING, delta)
	else:
		body_roll_speed *= pow(STATIC_BODY_ROLL_DAMPING, delta)
	#
	# pitching
	rotation.x += tip_pitch * TIP_PITCH_RATE
	#
	# gravity and velocity damping
	if is_on_floor():
		# TODO: proper drag
		velocity *= pow(0.1, delta)
		# return rotations
		rotation.z = move_toward(rotation.z, 0, 1.5*delta)
		torso_tilt = move_toward(torso_tilt, 0, 1.5*delta)
		torso_tilt_speed = 0.0
	else:
		velocity *= pow(0.95, delta)
		# Add the gravity.
		var grav_dif := MAX_GRAV_MULT - MIN_GRAV_MULT
		var grav_mult: float = MIN_GRAV_MULT + grav_dif*abs(sin(flap_angle))
		var grav := gravity*grav_mult
		velocity.y -= grav * delta
	#
	# debug
	$D/Vecs/WingNormal.target_position = lift_normal*0.5
	$D/Vecs/ForSpeed.target_position = velocity.project(Vector3.FORWARD)
	

	move_and_slide()


#### Wing Helpers ####
# wing flap
func handle_torso_tilt(delta: float) -> void:
	if flap_speed < 0.1:
		# not flapping - so lift up torso
		torso_tilt_speed = move_toward(torso_tilt_speed, MAX_TORSO_TILT_SPEED, TORSO_TILT_ACC*delta)
	else:
		# flapping - so deploy torso
		torso_tilt_speed = move_toward(torso_tilt_speed, -MAX_TORSO_TILT_SPEED, TORSO_DETILT_ACC*delta)
	torso_tilt += torso_tilt_speed*delta 
	if torso_tilt > 1.0:
		torso_tilt = 1.0
		torso_tilt_speed = 0.0
	elif torso_tilt < 0.0:
		torso_tilt = 0.0
		torso_tilt_speed = 0.0
	$Body.rotation.x = torso_tilt * TORSO_TILT_END + (1.0 - torso_tilt) * TORSO_TILT_START

# wing flap
func handle_flap(delta: float) -> void:
	if Input.is_action_pressed("flap") and flap_angle > MIN_FLAP_ANGLE:
		flap_speed = move_toward(flap_speed, -MAX_FLAP_SPEED, FLAP_ACC*delta)
	elif !Input.is_action_pressed("flap") and flap_angle < MAX_FLAP_ANGLE:
		flap_speed = move_toward(flap_speed, MAX_FLAP_SPEED, FLAP_ACC*delta)

	flap_angle += flap_speed*delta
	if flap_angle > MAX_FLAP_ANGLE:
		flap_angle = MAX_FLAP_ANGLE
		flap_speed = 0.0
	elif flap_angle < MIN_FLAP_ANGLE:
		flap_angle = MIN_FLAP_ANGLE
		flap_speed = 0.0
	#
	$Wings/LeftWing.set_flap_angle(flap_angle)
	$Wings/RightWing.set_flap_angle(flap_angle)

# wing pitch
func handle_wing_pitch(delta: float) -> void:
	if Input.is_action_pressed("forward"):
		wing_pitch_speed = move_toward(wing_pitch_speed, -MAX_WING_PITCH_SPEED, WING_PITCH_ACC*delta)
	elif Input.is_action_pressed("backward"):
		wing_pitch_speed = move_toward(wing_pitch_speed, MAX_WING_PITCH_SPEED, WING_PITCH_ACC*delta)
	else:
		wing_pitch_speed = move_toward(wing_pitch_speed, 0, WING_PITCH_ACC*delta)
		wing_pitch = move_toward(wing_pitch, 0, MAX_WING_PITCH_SPEED*0.2*delta)
	#
	wing_pitch += wing_pitch_speed*delta
	if wing_pitch > MAX_WING_PITCH:
		wing_pitch = MAX_WING_PITCH
		wing_pitch_speed = 0.0
	elif wing_pitch < MIN_WING_PITCH:
		wing_pitch = MIN_WING_PITCH
		wing_pitch_speed = 0.0
	#
	$Wings/LeftWing.set_pitch(wing_pitch)
	$Wings/RightWing.set_pitch(wing_pitch)

# wing roll
func handle_wing_roll(delta: float) -> void:
	if Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		# left
		wing_roll = move_toward(wing_roll, -MAX_WING_ROLL, WING_ROLL_SPEED*delta)
	elif Input.is_action_pressed("right") and !Input.is_action_pressed("left"):
		# right
		wing_roll = move_toward(wing_roll, MAX_WING_ROLL, WING_ROLL_SPEED*delta)
	elif Input.is_action_pressed("left") and Input.is_action_pressed("right"):
		# both held
		wing_roll = move_toward(wing_roll, 0, WING_ROLL_SPEED*delta)
	else:
		# neither held
		var balancing_roll := wrap_angle(rotation.z) / PI * MAX_WING_ROLL
		wing_roll = move_toward(wing_roll, balancing_roll, WING_ROLL_SPEED*delta)
	#
	$Wings/RightWing.set_roll(wing_roll)
	$Wings/LeftWing.set_roll(-wing_roll)

# mouse drags
func handle_mouse_drags(delta: float) -> void:
	# calculate drag vector
	if Input.is_action_just_pressed("clickdown"):
		drag_start = get_relative_mouse_pos()
	is_dragging = Input.is_action_pressed("clickdown")
	var drag_vec := Vector2.ZERO
	if is_dragging:
		drag_vec = get_relative_mouse_pos() - drag_start
	#
	tip_pitch = -drag_vec.y / MAX_TIP_PITCH_DIST
	tip_pitch = max(MIN_TIP_PITCH, min(MAX_TIP_PITCH, tip_pitch))
	
	#
	$Wings/LeftWing.set_tip_pitch(tip_pitch)
	$Wings/RightWing.set_tip_pitch(tip_pitch)


#### Utility ####
func get_relative_mouse_pos() -> Vector2:
	var screen_center := get_viewport().get_visible_rect().size / 2.0
	var mouse_p := get_viewport().get_mouse_position() - screen_center
	return mouse_p

# takes in any angle and returns an equivalent angle between -PI and PI
func wrap_angle(angle: float) -> float:
	while angle > PI:
		angle -= 2*PI
	while angle < -PI:
		angle += 2*PI
	return angle
