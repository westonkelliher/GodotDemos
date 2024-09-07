extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

const world_center = Vector3(0.0, -10.0, 0.0)

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta: float) -> void:
	# up direction
	up_direction = (position - world_center).normalized()
	

	
	velocity = velocity.move_toward(Vector3.ZERO, delta*2)
	# Add the gravity.
	if not is_on_floor():
		velocity -= up_direction * gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept"): # and is_on_floor():
		velocity += up_direction * JUMP_VELOCITY

	# righting (face upwards)
	if distance_to_floor() < 10.0:
		# Calculate direction from player to planet center
		var to_planet_center: Vector3 = (world_center - position).normalized()
		# Calculate forward direction based on input
		var forward: Vector3 = transform.basis[2]
		# Calculate right direction
		var right: Vector3 = forward.cross(to_planet_center).normalized()
		# Recalculate forward to ensure it's orthogonal
		forward = to_planet_center.cross(right).normalized()
		$TopSpot/Ray1.target_position = forward
		$TopSpot/Ray2.target_position = to_planet_center
		$TopSpot/Ray3.target_position = right
		# Create rotation basis
		var target_basis: Basis = Basis(right, -to_planet_center, forward).orthonormalized()
		# rotate the player to the target rotation
		var mult := pow(10.0 - distance_to_floor(), 1.5)/10.0
		var a = transform.basis[0].move_toward(target_basis[0], mult*delta)
		var b = transform.basis[1].move_toward(target_basis[1], mult*delta)
		var c = transform.basis[2].move_toward(target_basis[2], mult*delta)
		transform.basis = Basis(a, b, c).orthonormalized()
		
	# Get input direction
	var input_direction: Vector3 = Vector3.ZERO
	input_direction.x = Input.get_action_strength("turn_right") - Input.get_action_strength("turn_left")
	input_direction.z = Input.get_action_strength("down") - Input.get_action_strength("up")

	if input_direction != Vector3.ZERO:
		velocity += transform.basis * input_direction * SPEED * delta 

	if Input.is_action_pressed("left"):
		transform = transform.rotated_local(Vector3.UP, 1.5*delta)
	if Input.is_action_pressed("right"):
		transform = transform.rotated_local(Vector3.UP, -1.5*delta)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x += direction.x * SPEED * delta
		#velocity.z += direction.z * SPEED * delta

	move_and_slide()

func distance_to_floor() -> float:
	return world_center.distance_to(position) - 10.0

#func other():
	## Calculate direction from player to planet center
	#var to_planet_center: Vector3 = (world_center - position).normalized()
#
	## Get input direction
	#var input_direction: Vector3 = Vector3.ZERO
	#input_direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	#input_direction.z = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
#
	#if input_direction != Vector3.ZERO:
		## Calculate forward direction based on input
		#var forward: Vector3 = (input_direction).normalized() * transform.basis
		#
		## Calculate right direction
		#var right: Vector3 = forward.cross(to_planet_center).normalized()
		#
		## Recalculate forward to ensure it's orthogonal
		#forward = to_planet_center.cross(right).normalized()
#
		## Create rotation basis
		#var target_basis: Basis = Basis(forward, right, to_planet_center)
#
		## Smoothly rotate the player towards the target rotation
		#transform.basis = transform.basis.slerp(target_basis, SPEED * delta)
#
	## Move the player
	#var direction: Vector3 = forward * speed * delta
	#move_and_slide(direction, to_planet_center)
