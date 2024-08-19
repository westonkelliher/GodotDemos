extends Node2D

@export var container_height := 200.0 :
	set(val):
		container_height = val
		set_min_max()
	get:
		return container_height
		
@export var target_height := 40.0:
	set(val):
		target_height = val
		$Area/Shape.shape.size.y = target_height
		#$Sprite.scale.y = 0.39 * target_height / 50.0
		set_min_max()
	get:
		return target_height

@export var Y_ACC := 70.0
@export var MAX_SPEED := 100.0
@export var Y_IMPULSE := 8.0
# NOTE: y axis is turned upside down
var y_acc := 0.0
var y_wanted_speed := 0.0

var height := 0.0

var max_height := 0.0
var min_height := 0.0

var y_velocity := 0.0


func _ready() -> void:
	set_min_max()
	$Area/Shape.shape.size.y = target_height
	#$Sprite.scale.y = 0.39 * target_height / 50.0
	height = container_height / 2.0
	pass

func set_min_max() -> void:
	min_height = target_height / 2.0
	max_height = container_height - target_height / 2.0

func _physics_process(delta: float) -> void:
	# apply acc
	y_velocity = move_toward(y_velocity, y_wanted_speed, Y_ACC*delta)
	# apply vel
	height += y_velocity*delta
	if height < min_height:
		handle_bottom_hit()
	elif height > max_height:
		handle_top_hit()
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



func _on_swim_timer_timeout() -> void:
	randomize()
	y_wanted_speed = (randf()*2 - 1) * MAX_SPEED
	if y_wanted_speed > y_velocity:
		y_velocity += Y_IMPULSE
	else:
		y_velocity -= Y_IMPULSE
	randomize()
	$SwimTimer.start(randf()*1.2)
