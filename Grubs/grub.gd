extends Node2D

const TAIL_DISTANCE = 120.0
const MAX_HAND_REACH := 65.0
const NUM_SEGMENTS := 40
const LOOSE_DRAG := 0.1
const GRAB_DRAG := 0.9
@export var SPEED := 120.0
var STRETCH_STRAIN := sqrt(SPEED/300.0)
var FLOP_INTERVAL := 160.0/SPEED

var _is_grab := false :
	set(val):
		_is_grab = val
		if val:
			$Tail/Hand/Shape.debug_color = Color(.7, .4, .2, .4)
		else:
			$Tail/Hand/Shape.debug_color = Color(.2, .4, .7, .4)
	get:
		return _is_grab

func _ready():
	if get_tree().get_root().get_child(0) == self:
		position = Vector2(400, 300)
	for i in range(NUM_SEGMENTS+1):
		var seg = preload("res://segment.tscn").instantiate()
		seg.set_q(float(i)/NUM_SEGMENTS, 1, $Tail)
		$Segments.add_child(seg)
	STRETCH_STRAIN = sqrt(SPEED/300.0)
	FLOP_INTERVAL = 160.0/SPEED
	$FlopTimer.wait_time = FLOP_INTERVAL

func _input(event):
	if event is InputEventMouseButton:
		_is_grab = Input.is_mouse_button_pressed(1)

func _process(delta):
	$D/Label.position = position - Vector2(15, 60)
	$D/Panel.position = position + get_control_position()
	for i in range(NUM_SEGMENTS+1):
		var seg = $Segments.get_child(i)
		#var seg = $Segments.get_child(NUM_SEGMENTS-i)
		var hand_pos = $Tail.position+$Tail/Hand.position
		var squinching = 2 - hand_pos.length()/TAIL_DISTANCE
		seg.set_q(float(i)/NUM_SEGMENTS, squinching, $Tail)
	if true:
		$FlopTimer.wait_time = FLOP_INTERVAL

func _physics_process(delta):
	var mouse_p = get_viewport().get_mouse_position()
	if _is_grab:
		var hand_p = $Tail/Hand.global_position
		var inverse_p = 2*hand_p - mouse_p
		move_hand_towards(inverse_p, delta)
	else:
		move_hand_towards(mouse_p, delta)
	

func move_hand_towards(target_point: Vector2, delta):
	var hand_p = $Tail/Hand.global_position
	var toward = (target_point - hand_p).normalized()
	var vel = toward * min(sqrt(hand_p.distance_to(target_point))*SPEED/10, SPEED)
	if _is_grab:
		vel *= 0.7
	var reach = $Tail/Hand.position.length()
	var remaining_reach = max_hand_reach() - reach
	var directional_stretch = toward.dot($Tail/Hand.position.normalized())
	if directional_stretch < 0:
		directional_stretch *= -.4
	var stretch = directional_stretch * reach/max_hand_reach()
	vel *= (1 - pow(stretch, STRETCH_STRAIN))
	$D/Label.text = str(int(stretch*100))
		
	#
	var pre_hand_pos = $Tail/Hand.position
	$Tail/Hand.position += vel*delta
	reactionary_movement(pre_hand_pos)

func reactionary_movement(pre_hand_pos: Vector2):
	var reach = $Tail/Hand.position.length()
	if reach > max_hand_reach():
		$Tail/Hand.position *= max_hand_reach()/reach
	#
	var hand_move = $Tail/Hand.position - pre_hand_pos
	if _is_grab:
		$Tail.position -= hand_move*GRAB_DRAG
	else:
		$Tail.position -= hand_move*LOOSE_DRAG
	#
	var pre_tail_pos = $Tail.position
	var tail_force = TAIL_DISTANCE - $Tail.position.length()
	$Tail.position *= 1 + tail_force/TAIL_DISTANCE
	var tail_move = $Tail.position - pre_tail_pos
	if _is_grab:
		position -= tail_move*GRAB_DRAG
	else:
		position -= tail_move*LOOSE_DRAG


func max_hand_reach():
	var theta = abs($Tail/Hand.position.angle_to($Tail.position))
	var dist_from_135 = pow(abs(PI*5.5/8 - theta), 3)*4
	var scaler = 0.5 + 1.8/(1+(dist_from_135)) + (PI-theta)*0.1
	return scaler*MAX_HAND_REACH
	
#
func get_control_position():
	var toward_tail = $Tail.position.normalized()
	var toward_hand = $Tail/Hand.position.normalized()
	var to_hand = $Tail/Hand.position
	var dot = toward_tail.dot(-toward_hand)
	var ret = $Tail.position
	if dot > 0:
		ret += dot*to_hand
	return ret


func _on_flop_timer_timeout():
	_is_grab = !_is_grab
