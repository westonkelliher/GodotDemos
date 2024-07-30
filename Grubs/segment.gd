extends Sprite2D


func set_q(q: float, squinch: float, tail: Node):
	var a = get_control_position(tail)
	var b = tail.position + tail.get_node("Hand").position
	position = q_position(q, a, b)
	scale = Vector2.ONE*q_size(q, squinch)
	modulate = q_color(q)


# animation helpers
func q_position(q: float, a: Vector2, b: Vector2):
	var qq = pow(sin(q*PI/2), 1.2)
	var c1 = a*qq
	var c2 = a*(1-qq) + b*qq
	return c1*(1-qq) + c2*qq

func q_size(q, s):
	#return 1 - q*.9
	var ss = 1 + sin(0.3+q*(PI-0.6))*(pow(s, 0.7)-1)
	return pow(1-q*.9, 1.2)*ss

func q_color(q):
	var h = 0.2 + q*0.2
	var d_from_90 = pow(1/(1+abs(q-.8)*5), 2)
	var alpha = pow(.7-q*.6, 2)+.13 + d_from_90*0.3
	return Color(h*1.2, h*0.9 + 0.05 + d_from_90*0.05, h*0.7 + 0.1, alpha).lerp(Color(0,0,0,0), 0.1)

func get_control_position(tail: Node):
	var toward_tail = tail.position.normalized()
	var to_hand = tail.get_node("Hand").position
	var toward_hand = to_hand.normalized()
	var dot = toward_tail.dot(-toward_hand)
	var ret = tail.position
	var reflected_to_hand = to_hand.rotated(to_hand.angle_to(-toward_tail))
	if dot > 0:
		ret += dot*reflected_to_hand
	return ret
