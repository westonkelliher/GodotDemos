extends Node2D
class_name Bit

signal pop(ring: Ring)

@export var nomer := "Bit"
@export var ring_func := "effect_none"

var states := {}


func _physics_process(delta: float) -> void:
	## visible effects ##
	# mana
	if "mana" in states:
		states["mana"] *= pow(0.85, delta)
		states["mana"] -= 1.0
		if states["mana"] <= 0.0:
			states.erase("mana")
			$Sprite.self_modulate = Color(.9,.9,.9)
		else:
			var c: float = states["mana"]/(80.0 + states["mana"])
			$Sprite.self_modulate = Color(.82 + .3*c, .85 + .3*c, 1 + .9*c)
	else:
		$Sprite.self_modulate = Color(.9,.9,.9)
	# earth
	scale = Vector2.ONE
	if "earth" in states:
		scale = Vector2.ONE * states["earth"]
	# nature
	if "nature" in states:
		states["nature"] -= delta
		if states["nature"] <= 0.0:
			states.erase("nature")
		else:
			scale *= Vector2(1.1, 0.9)
	else:
		scale *= Vector2(1.0, 1.0)
	## transmutation ##
	if nomer == "A":
		if "mana" in states and states["mana"] > 110.0:
			transmute("B")
	elif nomer == "B":
		if "nature" in states and "mana" in states and states["mana"] > 80.0:
			transmute("C")


func transmute(t: String) -> void:
	states.erase("mana")
	if t == "A":
		nomer = "A"
		ring_func = "effect_A"
		$Sprite.texture = preload("res://images/circle.png")
		$Sprite.modulate = Color(0.2, 0.7, 1.0)
	elif t == "B":
		nomer = "B"
		ring_func = "effect_B"
		$Sprite.texture = preload("res://images/square.png")
		$Sprite.modulate = Color(0.4, 1.0, 0.5)
	elif t == "C":
		nomer = "C"
		ring_func = "effect_C"
		$Sprite.texture = preload("res://images/triangle.png")
		$Sprite.modulate = Color(1.0, 0.7, 0.4)

func pop_bit() -> void:
	var ring := preload("res://ring.tscn").instantiate()
	ring.global_position = global_position
	ring.effect = ring_func
	ring.scale = Vector2.ONE*scale.y
	$Area.monitoring = false
	pop.emit(ring)
	$Timer.start()


func _on_area_2d_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pop_bit()


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_area_entered(area: Area2D) -> void:
	var ring := area.get_parent()
	if not ring is Ring:
		return
	ring.call(ring.effect, self)
	print("did " + ring.effect + " on " + nomer)


func _on_area_area_exited(area: Area2D) -> void:
	print("exit "+nomer)
