extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# lift and drag
const LIFT_MULT := 9.0
const DIFT_MULT := 1.0
const FLAT_DRAG :=  5.0 # meters / second
const DIVE_DRAG :=  0.02 # added to flat and flapped
const DRAFT_LEVEL := 100.0

# torso tilt
const MAX_TORSO_TILT_SPEED := 1.5 # as fraction not in radians
const TORSO_TILT_ACC := 0.7
const TORSO_DETILT_ACC := 2.2
const TORSO_TILT_START := -PI/4.0
const TORSO_TILT_END := -PI/2.0
var torso_tilt_speed := 0.0
var torso_tilt := 0.0 # min 0.0 max 1.0

# flap
# : negative number means downward position
const MAX_FLAP_ANGLE := 0.2  
const MIN_FLAP_ANGLE := -0.8
const MAX_FLAP_SPEED := 5.0
const FLAP_ACC := 70.0
var flap_speed := 0.0
var flap_angle := 0.0

# wing pitch
const MAX_WING_PITCH := 0.9
const MIN_WING_PITCH := -0.4
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

# yaw (from wing roll)
const YAW_ACC := 2.1
const STATIC_YAW_DAMPING := 0.1
const ACTIVE_YAW_DAMPING := 0.6
var yaw_speed := 0.0

# body roll
const BODY_ROLL_RATE := 3.0
const STATIC_BODY_ROLL_DAMPING := 0.1
const ACTIVE_BODY_ROLL_DAMPING := 0.6
var body_roll_speed := 0.0  # added to rotation.z

# tip pitch
# : set by click drag y-distance
# : proportional to body pitch speed
const MAX_TIP_PITCH := 0.7
const MIN_TIP_PITCH := -0.7
const MAX_TIP_PITCH_DIST := 400.0
const TIP_PITCH_RATE := 0.05
var tip_pitch := 0.0

# wing yaw
const MAX_WING_YAW := 0.2
const MAX_WING_YAW_DIST := 800.0
const WING_YAW_RATE := 0.05
var wing_yaw := 0.0


# mouse drags
var drag_start := Vector2.ZERO # relative to center of screens
var is_dragging := false
var mouse_yaw_speed := 0.0

# foil lift
const FOIL_LIFT_MULT := 0.2

#### Builtins ####
func _process(delta: float) -> void:
	$D/Vecs.global_position = global_position + Vector3.UP

func _physics_process(delta: float) -> void:
	handle_torso_tilt(delta)
	handle_flap(delta)
	handle_wing_pitch(delta)
	handle_wing_roll(delta)
	handle_mouse_drags(delta)
	#
	# flapping
	var flap_normal := Vector3.UP.rotated(Vector3.RIGHT, wing_pitch)
	#lift_normal = lift_normal.rotated(Vector3.FORWARD, wing_roll*0.5)
	flap_normal = basis * flap_normal
	if flap_speed < 0:
		var flap_lift: float = abs(flap_speed) * cos(flap_angle) * LIFT_MULT
		velocity += flap_normal * flap_lift * delta
		#
	elif flap_speed > 0:
		var dift: float = abs(flap_speed) * cos(flap_angle) * DIFT_MULT
		velocity -= flap_normal * dift * delta
	#
	# yawing
	if flap_speed < 0:
		yaw_speed += flap_speed * wing_roll * YAW_ACC * delta
	rotation.y += yaw_speed * delta
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		yaw_speed *= pow(ACTIVE_YAW_DAMPING, delta)
	else:
		yaw_speed *= pow(STATIC_YAW_DAMPING, delta)
	#
	# speed rolling
	if velocity.length() > 1.0:
		var speed_roll_intensity := (basis * Vector3.FORWARD).dot(velocity)*0.2
		speed_roll_intensity *= 0.02 + 0.98*torso_tilt
		body_roll_speed += -wing_roll * speed_roll_intensity * delta
		var max_rs := pow(velocity.length(), 0.5) * 0.5
		body_roll_speed = max(-max_rs, min(max_rs, body_roll_speed))
		print(body_roll_speed)
		rotation.z += body_roll_speed * delta
		# damp it
		if !Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
			body_roll_speed *= pow(0.2, delta)
	#
	# pitching
	var paxis := basis * Vector3.RIGHT 
	rotate(paxis, tip_pitch * TIP_PITCH_RATE)
	# yawing
	var yaxis := basis * Vector3.DOWN
	rotate(yaxis, wing_yaw * WING_YAW_RATE)
	velocity = velocity.rotated(yaxis, wing_yaw * WING_YAW_RATE)
	#
	# airfoil lift
	var lift_normal := basis * Vector3.UP
	var beak_normal := basis * Vector3.FORWARD
	var lift_mult: float = velocity.dot(beak_normal) * FOIL_LIFT_MULT * torso_tilt * abs(cos(flap_angle))
	velocity -= velocity.normalized() * lift_mult * delta * 0.4 # 0.52 means we get 0.6 of added energy
	if flap_speed < 0.1:
		velocity += lift_normal * lift_mult * delta
	#
	# gravity and velocity drag
	if is_on_floor():
		# TODO: proper drag
		velocity *= pow(0.1, delta)
		# return rotations
		rotation.x = move_toward(rotation.x, 0, 1.0*delta)
		rotation.z = move_toward(rotation.z, 0, 1.5*delta)
		torso_tilt = move_toward(torso_tilt, 0, 1.5*delta)
		torso_tilt_speed = 0.0
	else:
		handle_air_drag(delta)
		handle_forward_turning(delta)
		# Add the gravity.
		velocity.y -= gravity * delta
	#
	# debug
	$D/Vecs/WingNormal.target_position = lift_normal*0.5
	$D/Vecs/ForSpeed.target_position = velocity.project(Vector3.FORWARD)
	#

	move_and_slide()


#### Wing Helpers ####
# wing flap
func handle_torso_tilt(delta: float) -> void:
	var forward := basis * Vector3.FORWARD
	var tilt_acc := TORSO_TILT_ACC 
	if velocity.length() > 0.1:
		tilt_acc += 0.1* velocity.dot(forward) / pow(velocity.length(), 0.5)
	if flap_angle == MIN_FLAP_ANGLE:
		# deploy torso
		torso_tilt_speed = move_toward(torso_tilt_speed, -MAX_TORSO_TILT_SPEED, 
			TORSO_DETILT_ACC*delta)
	if flap_speed < 0.1:
		# not flapping - so lift up torso
		torso_tilt_speed = move_toward(torso_tilt_speed, MAX_TORSO_TILT_SPEED, 
			tilt_acc*delta)
	else:
		# flapping - so deploy torso (unless forward flapping)
		torso_tilt_speed = move_toward(torso_tilt_speed, -MAX_TORSO_TILT_SPEED, 
			TORSO_DETILT_ACC*delta)
	torso_tilt += torso_tilt_speed*delta 
	if torso_tilt > 1.0:
		torso_tilt = 1.0
		torso_tilt_speed = 0.0
	elif torso_tilt < 0.0:
		torso_tilt = 0.0
		torso_tilt_speed = 0.0
	$Body.rotation.x = torso_tilt * TORSO_TILT_END + (1.0 - torso_tilt) * (
		TORSO_TILT_START)

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
		#var balancing_roll := wrap_angle(rotation.z) / PI * MAX_WING_ROLL
		#wing_roll = move_toward(wing_roll, balancing_roll, WING_ROLL_SPEED*delta)
		wing_roll = move_toward(wing_roll, 0, WING_ROLL_SPEED*delta)
	#
	$Wings/RightWing.set_roll(wing_roll)
	$Wings/LeftWing.set_roll(-wing_roll)

# mouse drags
func handle_mouse_drags(delta: float) -> void:
	if Input.is_action_just_pressed("clickdown"):
		drag_start = get_relative_mouse_pos()
	is_dragging = Input.is_action_pressed("clickdown")
	var drag_vec := Vector2.ZERO
	if is_dragging:
		drag_vec = get_relative_mouse_pos() - drag_start
	#
	# pitch
	tip_pitch = -drag_vec.y / MAX_TIP_PITCH_DIST * torso_tilt
	tip_pitch = max(MIN_TIP_PITCH, min(MAX_TIP_PITCH, tip_pitch))
	#
	$Wings/LeftWing.set_tip_pitch(tip_pitch)
	$Wings/RightWing.set_tip_pitch(tip_pitch)
	#
	# yaw
	wing_yaw = drag_vec.x / MAX_WING_YAW_DIST * torso_tilt
	wing_yaw = max(-MAX_WING_YAW, min(MAX_WING_YAW, wing_yaw))
	#
	$Wings/LeftWing.set_yaw(wing_yaw)
	$Wings/RightWing.set_yaw(-wing_yaw)


func handle_air_drag(delta: float) -> void:
	# calculate terminal vel for this vel normal
	var wing_forward := basis * Vector3.FORWARD.rotated(Vector3.RIGHT, wing_pitch)
	var straightness: float = pow(abs(wing_forward.dot(velocity.normalized())), 2.0)
	var flappedness: float = abs(flap_angle) / abs(MIN_FLAP_ANGLE)
	# calculate drag
	var wing_up := basis * Vector3.UP.rotated(Vector3.RIGHT, wing_pitch)
	var drag_normal := -velocity.normalized()
	var drag_mult: float = DIVE_DRAG
	drag_mult += drag_normal.dot(wing_up)*FLAT_DRAG
	drag_mult *= 0.2 + 0.8*torso_tilt
	drag_mult *= 1.0/(1.0+flap_speed)
	velocity += wing_up * velocity.length() * drag_mult * delta
	#
	#$D/Vecs/Drag.target_position = drag_normal
	#$D/Vecs/WingUp.target_position = wing_up
	#$D/Vecs/DragReflect.target_position = draft_normal

func handle_forward_turning(delta: float) -> void:
	# yaw (only if we're facing down)
	var turn_intensity := 1.0 - 5.0/(5.0 + velocity.length())
	turn_intensity *= torso_tilt
	var forward := basis * Vector3.FORWARD
	var total_a := forward.angle_to(velocity)
	if total_a < 0.01:
		return
	var axis := forward.cross(velocity).normalized()
	var amount := total_a * (1.0 - pow(0.6, delta)) * turn_intensity
	if forward.y < 0:
		rotate(axis, amount)
	# roll
	if !Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		var roll_intensity: float = abs(cos(rotation.z)) * 0.5
		rotation.z *= (1.0 - roll_intensity*delta)
	# pitch (when torso down)
	var pitch_restore_mult := (1.0 - torso_tilt) * 0.2
	rotation.x = move_toward(rotation.x, 0, pitch_restore_mult*delta)


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


func turn_toward_vector(fraction: float, start: Vector3, target: Vector3) -> Vector3:
	var total_a := start.angle_to(target)
	if total_a < 0.01:
		return start
	var axis := start.cross(target).normalized()
	var amount := total_a * fraction
	return start.rotated(axis, tip_pitch * TIP_PITCH_RATE)
