extends Node2D


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

@export var target_height := 20.0:
	set(val):
		target_height = val
		#$Area/Shape.shape.size.y = target_height
		#$Sprite.scale.y = 0.39 * target_height / 50.0
		set_min_max()
	get:
		return target_height

@export var Y_ACC := 70.0
@export var X_ACC := 20.0
@export var Y_MAX_SPEED := 120.0
@export var X_MAX_SPEED := 40.0
@export var Y_IMPULSE := 7.0
@export var X_IMPULSE := 2.5
# NOTE: y axis is turned upside down
var y_acc := 0.0
var x_acc := 0.0
var y_wanted_speed := 0.0
var x_wanted_speed := 0.0

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
	# apply acc
	y_velocity = move_toward(y_velocity, y_wanted_speed, Y_ACC*delta)
	x_velocity = move_toward(x_velocity, x_wanted_speed, X_ACC*delta)
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


func handle_bottom_hit() -> void:
	y_velocity = 0.0
	height = min_height
	if randf() < 0.04:
		y_wanted_speed *= -1

func handle_top_hit() -> void:
	y_velocity = 0.0
	height = max_height
	if randf() < 0.04:
		y_wanted_speed *= -1

func handle_side_hit() -> void:
	x_velocity = 0.0
	if position.x > 0:
		position.x = max_x
	else:
		position.x = -max_x
	if randf() < 0.04:
		x_wanted_speed *= -1


func _on_swim_timer_timeout() -> void:
	randomize()
	y_wanted_speed = (randf()*2 - 1) * Y_MAX_SPEED
	randomize()
	x_wanted_speed = (randf()*2 - 1) * X_MAX_SPEED
	if y_wanted_speed > y_velocity:
		y_velocity += Y_IMPULSE
	else:
		y_velocity -= Y_IMPULSE
	if x_wanted_speed > x_velocity:
		x_velocity += X_IMPULSE
	else:
		x_velocity -= X_IMPULSE
	randomize()
	$SwimTimer.start(randf()*2.0)
