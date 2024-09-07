extends Node2D

signal fish_enter()
signal fish_exit()

@export var container_height := 200.0 :
	set(val):
		container_height = val
		set_min_max()
		height = container_height / 2.0
	get:
		return container_height

@export var container_width := 100.0 :
	set(val):
		container_width = val
		set_min_max()
	get:
		return container_width
		
@export var target_height := 50.0:
	set(val):
		target_height = val
		#$Area/Shape.shape.size.y = target_height
		#$Sprite.scale.y = 0.39 * target_height / 50.0
		set_min_max()
	get:
		return target_height

# NOTE: y axis is turned upside down
const FACTOR = 0.6
@export var y_gravity := -220.0*FACTOR
@export var y_acceleration := 440.0*FACTOR
@export var y_impulse := 40.0*FACTOR
@export var x_base_acc := 50.0*FACTOR
@export var x_base_impulse := 8.0*FACTOR
@export var bottom_bounce := 0.6
@export var top_bounce := 0.2
@export var side_bounce := 0.35

var height := 0.0

var max_height := 0.0
var min_height := 0.0
var max_x := 0.0

var y_velocity := 0.0
var x_velocity := 0.0


func _ready() -> void:
	set_min_max()
	#$Area/Shape.shape.size.y = target_height
	#$Sprite.scale.y = 0.39 * target_height / 50.0
	height = container_height / 2.0
	pass

func set_min_max() -> void:
	min_height = target_height / 2.0
	max_height = container_height - target_height / 2.0
	max_x = container_width - target_height / 2.0

func _physics_process(delta: float) -> void:
	handle_input(delta)
	# apply acc
	y_velocity += y_gravity*delta
	# apply vel
	height += y_velocity*delta
	position.x += x_velocity*delta
	if height < min_height:
		handle_bottom_hit()
	elif height > max_height:
		handle_top_hit()
	if abs(position.x) > max_x:
		handle_side_hit()
	# NOTE: we flip y axis here
	position.y = - height
	# x damping
	x_velocity *= 1.0 - 0.9*delta
	if abs(x_velocity) < 4.0:
		x_velocity = 0.0

func handle_input(delta: float) -> void:
	var bias := get_x_bias()
	if Input.is_action_just_pressed("mouse"):
		y_velocity += y_impulse
		x_velocity += x_base_impulse*bias
	if Input.is_action_pressed("mouse"):
		y_velocity += y_acceleration*delta
		x_velocity += x_base_acc*bias*delta

func get_x_bias() -> int:
	var mouse_p := get_viewport().get_mouse_position()
	var full := Vector2(700, 900)
	var float_bias := (mouse_p.x - full.x * 0.5) / (full.x * 0.5)
	var int_bias := int(float_bias*4.65)
	if int_bias > 3:
		int_bias = 3
	if int_bias < -3:
		int_bias = -3
	return int_bias

func handle_bottom_hit() -> void:
	# bounce the velocity
	y_velocity *= -bottom_bounce
	# bounce the position (overwriting previous velocity application)
	var remaining_d := min_height - height
	height = min_height + remaining_d * bottom_bounce

func handle_top_hit() -> void:
	# bounce the velocity
	y_velocity *= -top_bounce
	# bounce the position (overwriting previous velocity application)
	var remaining_d := height - max_height
	height = max_height - remaining_d * top_bounce

func handle_side_hit() -> void:
	# bounce the velocity
	x_velocity *= -side_bounce
	# bounce the position (overwriting previous velocity application)
	var remaining_d: float = abs(position.x) - max_x
	if position.x > 0:
		position.x = max_x - remaining_d * side_bounce
	else:
		position.x = -max_x + remaining_d * side_bounce


func _on_area_area_entered(area: Area2D) -> void:
	fish_enter.emit()


func _on_area_area_exited(area: Area2D) -> void:
	fish_exit.emit()
