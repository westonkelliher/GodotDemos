extends MarginContainer

var xx = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		xx = true
	if xx:
		xx = false
		remove_child($PanelC)
		var a = load("res://blizock.tscn").instantiate()
		#add_child(a)
		print("it is done")
		for c in a.get_children():
			print(c)
			for d in c.get_children():
				print(d)


func _on_button_pressed() -> void:
	var a = load("res://blizock.tscn").instantiate()
	$C/C.add_child(a)
	#$PanelC.queue_free()
	#remove_child($PanelC)
	print("press")
