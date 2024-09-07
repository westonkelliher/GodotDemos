extends Control


func _process(delta: float) -> void:
	var arrow_offset := Vector2.UP * 20.0
	$Arrow.global_position = get_viewport().get_mouse_position() + arrow_offset
	handle_input()


func handle_input() -> void:
	var bias := get_x_bias()
	$Arrow.frame = bias + 3
	if Input.is_action_just_pressed("mouse"):
		$Arrow.visible = true
	if Input.is_action_just_released("mouse"):
		$Arrow.visible = false

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


func _on_rod_bounds_win() -> void:
	$Label.visible = true
