extends Area2D

@export var container_height := 200.0 :
	set(val):
		container_height = val
		set_min_max()
	get:
		return container_height
		
@export var target_height := 40.0:
	set(val):
		target_height = val
		$Shape.shape.size.y = target_height
		$Sprite.scale.y = 0.39 * target_height / 50.0
		set_min_max()
	get:
		return target_height

# NOTE: y axis is turned upside down
@export var y_gravity := -180.0
@export var y_acceleration := 420.0
@export var y_impulse := 20.0
@export var bottom_bounce := 0.6
@export var top_bounce := 0.2

var height := 0.0

var max_height := 0.0
var min_height := 0.0

var y_velocity := 0.0


func _ready() -> void:
	set_min_max()
	$Shape.shape.size.y = target_height
	$Sprite.scale.y = 0.39 * target_height / 50.0
	height = container_height / 2.0
	pass

func set_min_max() -> void:
	min_height = target_height / 2.0
	max_height = container_height - target_height / 2.0

func _physics_process(delta: float) -> void:
	handle_input(delta)
	# apply acc
	y_velocity += y_gravity*delta
	# apply vel
	height += y_velocity*delta
	if height < min_height:
		handle_bottom_hit()
	elif height > max_height:
		handle_top_hit()
	# NOTE: we flip y axis here
	position.y = - height

func handle_input(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		y_velocity += y_impulse
	if Input.is_action_pressed("ui_up"):
		y_velocity += y_acceleration*delta

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
