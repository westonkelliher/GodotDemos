extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_appender_activated() -> void:
	var new_slot = load("res://slot.tscn").instantiate()
	$HBoxContainer.add_child(new_slot)
	$HBoxContainer.move_child(new_slot, -2)
