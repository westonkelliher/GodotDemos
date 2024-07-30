extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in get_children():
		if c is Bit:
			c.pop.connect(_on_pop)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pop(ring: Ring) -> void:
	add_child(ring)


func _on_spawn_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not event is InputEventMouseButton:
		return
	if not (event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		return 
	if is_point_in_a_bit(event.position):
		return
	var bit := preload("res://Bits/a_bit.tscn").instantiate()
	bit.pop.connect(_on_pop)
	bit.position = event.position
	$Bits.add_child(bit)

func is_point_in_a_bit(p: Vector2) -> bool:
	for c in $Bits.get_children():
		var area: Area2D = c.get_node("Area")
		var shape: CircleShape2D = area.get_child(0).shape
		if p.distance_to(c.position) <= shape.radius:
			return true
	return false
