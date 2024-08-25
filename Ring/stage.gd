extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in get_children():
		if c is Bit:
			c.pop.connect(_on_pop)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		handle_click(get_viewport().get_mouse_position())


func _on_pop(ring: Ring) -> void:
	add_child(ring)


func _on_spawn_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	pass
	
func handle_click(pos: Vector2) -> void:
	if is_point_in_a_bit(pos):
		print('abcdgoldifh')
		return
	var bit := preload("res://Bits/a_bit.tscn").instantiate()
	bit.pop.connect(_on_pop)
	bit.position = pos
	$Bits.add_child(bit)

func is_point_in_a_bit(p: Vector2) -> bool:
	for c in $Bits.get_children():
		var area: Area2D = c.get_node("Area")
		var shape: CircleShape2D = area.get_child(0).shape
		if p.distance_to(c.position) <= shape.radius:
			c.pop_bit()
			return true
	return false
