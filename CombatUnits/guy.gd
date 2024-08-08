class_name Guy
extends RigidBody2D

#
enum Team {GRAY, RED, BLUE}
static var TeamColors := {
	Team.GRAY: Color(.8, .8, .8),
	Team.RED: Color(.9, .4, .35),
	Team.BLUE: Color(.35, .4, .9),
}

#
@export var is_controlled := false
@export var team := Team.RED :
	set(value):
		team = value
		if $Clothing != null:
			$Clothing.modulate = TeamColors[team]
	get:
		return team

#
const MAX_SPEED := 220.0
const ACC := 600.0
const ANGULAR_SPEED := 5.0
# damping
const RESTING_DAMP := 5.0 # applied while getting to max speed
const RUN_DAMP := 1.0 # applied while getting to max speed
const SPRINT_DAMP := 5.0 # applied when at max speed
const HIT_DAMP := 5.0 # applied on a timer after hit


var target_rotation := 0.0
var target: Node2D = null :
	set(value):
		target = value
		has_target = true
	get:
		return target
var target_position := Vector2.ZERO
var has_target := false


func _ready() -> void:
	$Hand.held_item = preload("res://sword.tscn").instantiate()
	$Hand.held_item.set_wielder(self)
	team = team
	linear_damp = RESTING_DAMP


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
		if $Hand.can_swing():
			$Hand.swing()
	if Input.is_action_just_pressed("swing_left"):
		#$Hand.position += Vector2(10.0, -10.0)
		if $LeftHand.can_swing():
			$LeftHand.swing()
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
		if linear_velocity.dot(toward) < MAX_SPEED:
			# TODO: counteract damping force
			self.apply_force(move_vec.normalized()*ACC*mass)
	if move_vec.length() == 0:
		linear_damp = RESTING_DAMP
	else:
		if linear_velocity.length() > MAX_SPEED:
			linear_damp = SPRINT_DAMP
		else:
			linear_damp = RUN_DAMP


func handle_intention() -> void:
	linear_damp = RESTING_DAMP
	if not has_target:
		return
	target_position = target.position
	var toward := (target_position - global_position).normalized()
	target_rotation = toward.angle()
	self.apply_force(toward*ACC*mass)
	#
	if linear_velocity.length() > MAX_SPEED:
		linear_damp = SPRINT_DAMP
	else:
		linear_damp = RUN_DAMP
	#

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
	$HitStunTimer.start()
	

func in_hitstun() -> bool:
	return $HitStunTimer.time_left > 0


func _on_hit_stun_timer_timeout() -> void:
	print("stun over")

func get_corpus() -> Guy:
	return self
