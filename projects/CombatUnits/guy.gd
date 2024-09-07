class_name Guy
extends RigidBody2D

#
enum Team {GRAY, RED, BLUE, GREEN}
static var TeamColors := {
	Team.GRAY: Color(.6, .6, .6),
	Team.RED: Color(.7, .5, .45),
	Team.BLUE: Color(.45, .5, .7),
	Team.GREEN: Color(.45, .7, .45)
}

#
signal wants_target(guy: Guy)
signal death(guy: Guy)

#
@export var is_controlled := false
@export var team := Team.RED :
	set(value):
		team = value
		if $Clothing != null:
			$Clothing.modulate = TeamColors[team]
	get:
		return team
@export var size := 1.0 :
	set(value):
		size = value
		set_size(value)
	get:
		return size
#
const MAX_SPEED := 220.0
var top_speed := MAX_SPEED
const ACC := 600.0
var acc := ACC
const ANGULAR_SPEED := 4.0
# damping
const RESTING_DAMP := 5.0 # applied while getting to max speed
const RUN_DAMP := 1.0 # applied while getting to max speed
const SPRINT_DAMP := 5.0 # applied when at max speed
const HIT_DAMP := 5.0 # applied on a timer after hit
const COMFORTABLE_DISTANCE := 40.0

var target_rotation := 0.0
var target: Node2D = null :
	set(value):
		target = value
		if target != null:
			has_target = true
			if target is Guy:
				target.death.connect(on_target_died)
		else:
			has_target = false
	get:
		return target
var target_position := Vector2.ZERO
var has_target := false
var can_attack := true

@export var MAX_HEALTH := 10
var health: float :
	set(value):
		health = value
		var bar: HealthBar = $D/HealthBar
		bar.set_progress(health/MAX_HEALTH)
		bar.visible = health != MAX_HEALTH
		#
		if health <= 0:
			death.emit(self)
	get:
		return health


func _ready() -> void:
	team = team
	linear_damp = RESTING_DAMP
	health = MAX_HEALTH

func give_sword() -> void:
	$Body/Hand.held_item = preload("res://sword.tscn").instantiate()
	$Body/Hand.held_item.set_wielder(self)

func _process(delta: float) -> void:
	$Clothing.global_position = $Body/HatSpot.global_position
	$D/HealthBar.global_position = global_position + Vector2(0, 50)*$Body.scale.x
	$D/HealthBar.scale = $Body.scale

func _physics_process(delta: float) -> void:
	if is_controlled:
		handle_input()
	else:
		handle_intention()
	# damping
	if in_hitstun():
		linear_damp += HIT_DAMP
	#
	if is_controlled:
		var mouse_pos := get_viewport().get_mouse_position()
		target_rotation = (mouse_pos - global_position).angle()
	rotate_towards(target_rotation, ANGULAR_SPEED*delta)
	

func handle_input() -> void:
	if Input.is_action_just_pressed("swing_right"):
		#$Hand.position += Vector2(10.0, -10.0)
		if $Body/Hand.can_swing():
			$Body/Hand.swing()
	if Input.is_action_just_pressed("swing_left"):
		#$Hand.position += Vector2(10.0, -10.0)
		if $Body/LeftHand.can_swing():
			$Body/LeftHand.swing()
	if Input.is_action_pressed("run"):
		top_speed = MAX_SPEED*2.0
		acc = ACC*5.0
	else:
		top_speed = MAX_SPEED
		acc = ACC
	# movement
	var move_vec := Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1.0
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1.0
	if Input.is_action_pressed("move_up"):
		move_vec.y -= 1.0
	if Input.is_action_pressed("move_down"):
		move_vec.y += 1.0
	if move_vec.length() > 0:
		var toward := move_vec.normalized()
		if linear_velocity.dot(toward) < top_speed:
			# TODO: counteract damping force
			self.apply_force(move_vec.normalized()*acc*mass)
	if move_vec.length() == 0:
		linear_damp = RESTING_DAMP
	else:
		if linear_velocity.length() > top_speed:
			linear_damp = SPRINT_DAMP
		else:
			linear_damp = RUN_DAMP


func handle_intention() -> void:
	linear_damp = RESTING_DAMP
	if not has_target:
		return
	var toward := (target.global_position - global_position).normalized()
	target_rotation = toward.angle()
	var full_distance: float = get_radius() + COMFORTABLE_DISTANCE * $Body.scale.x
	if target.has_method("get_radius"):
		full_distance += target.get_radius()
	target_position = target.global_position - toward*full_distance
	var to_targ_position := (target_position - global_position)
	var mover := to_targ_position.normalized()
	if to_targ_position.length() < 50.0:
		mover *= to_targ_position.length()/50.0
	$Marker2D.global_position = target_position
	self.apply_force(mover*ACC*mass)
	#
	if linear_velocity.length() > MAX_SPEED:
		linear_damp = SPRINT_DAMP
	elif to_targ_position.length() < 50.0:
		linear_damp = RESTING_DAMP
	else:
		linear_damp = RUN_DAMP
	#
	handle_aggression()

func handle_aggression() -> void:
	if not can_attack:
		return
	if $Body/LeftHand.wants_to_swing():
		$Body/LeftHand.swing()
		$AttackTimer.start()
		can_attack = false
		return
	if $Body/Hand.wants_to_swing():
		$Body/Hand.swing()
		$AttackTimer.start()
		can_attack = false
		return
	

func rotate_towards(target_angle: float, amount: float) -> void:
	var angle_to := target_angle - rotation
	if angle_to > PI:
		angle_to -= 2*PI
	if angle_to < -PI:
		angle_to += 2*PI
	if angle_to == 0:
		return
	var lerp_amount: float = min(1.0, amount/abs(angle_to))
	rotation = lerp_angle(rotation, target_angle, lerp_amount)


func get_hit(attack: Attack) -> void:
	$Animation.play("hit")
	self.apply_impulse(attack.get_impulse())
	health -= attack.get_damage()
	$HitStunTimer.start()
	modulate = Color(1.0, 0.8, 0.9)

func set_size(s: float) -> void:
	$Body.scale = Vector2.ONE * s
	$Shape.scale = Vector2.ONE * s
	$Body/Hand.counter_size(s)
	$Body/LeftHand.counter_size(s)
	mass = 50.0 * pow(s, 1.5)
	$Clothing.scale = 0.2 * Vector2.ONE * pow(s, 0.5)

func in_hitstun() -> bool:
	return $HitStunTimer.time_left > 0


func _on_hit_stun_timer_timeout() -> void:
	print("stun over")
	modulate = Color.WHITE

func get_corpus() -> Guy:
	return self

func get_radius() -> float:
	return $Shape.shape.radius * $Body.scale.x


func _on_attack_timer_timeout() -> void:
	can_attack = true


func _on_retarget_timer_timeout() -> void:
	wants_target.emit(self)
	$RetargetTimer.start(0.5+randf()*10.0)

func on_target_died(target: Node2D) -> void:
	target = null
	has_target = false
	wants_target.emit(self)
