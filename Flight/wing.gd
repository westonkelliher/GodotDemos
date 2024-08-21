extends Node3D

var t := 0.0

var flap_angle := 0.0
var pitch := 0.0
var roll := 0.0
var tip_pitch := 0.0

func _process(delta: float) -> void:
	pass
	#t += delta
	#set_flap_angle(cos(t*10)*0.7-0.2)

func set_flap_angle(angle: float) -> void:
	flap_angle = angle
	position_wing()

func set_pitch(angle: float) -> void:
	pitch = angle
	position_wing()

func set_roll(angle: float) -> void:
	roll = angle
	position_wing()

func set_tip_pitch(angle: float) -> void:
	tip_pitch = angle
	position_wing()

#
func position_wing() -> void:
	$F1.rotation.z = flap_angle
	$F1/F2.rotation.z = roll + flap_angle*0.8 - 0.6
	$F1.rotation.x = pitch
	$F1/F2.rotation.x = pitch*0.2 + tip_pitch
