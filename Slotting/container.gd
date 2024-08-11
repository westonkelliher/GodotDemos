extends MarginContainer


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var a = preload("res://my_pan.tscn").instantiate()
		add_child(a)
		print("it is done")

