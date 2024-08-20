extends Node3D

var t := 0.0

func _process(delta: float) -> void:
	pass
	#t += delta
	#set_flap_angle(cos(t*10)*0.7-0.2)

func set_flap_angle(angle: float) -> void:
	$F1.rotation.z = angle
	$F1/F2.rotation.z = angle*0.8 - 0.6
