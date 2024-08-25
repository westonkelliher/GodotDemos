extends Node2D
class_name HealthBar

#### Constants ####
const START_WIDTH = 4.0
const END_WIDTH = 100.0


#### Members ####
var _fill := 0.0
var _shown_fill := 0.0

#### Builtins ####
func _process(delta: float) -> void:
	var move_amt: float = 0.005 + abs(_fill - _shown_fill)*10.0*delta
	_shown_fill = move_toward(_shown_fill, _fill, move_amt)
	if _fill == 0.0:
		_shown_fill = 0.0
	$Fill.size.x = lerp(START_WIDTH, END_WIDTH, _shown_fill)


#### Other ####
func set_progress(p: float) -> void:
	_fill = clamp(p, 0.0, 1.0)
