extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BaseArm/ForeArm/Claw.position.y = $BaseArm/ForeArm/Arm/End.position.y + 0.1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var L_l := Input.get_action_raw_strength("LS_left")
	var L_r := Input.get_action_raw_strength("LS_right")
	var L_u := Input.get_action_raw_strength("LS_up")
	var L_d := Input.get_action_raw_strength("LS_down")
	var L_t0 := Input.get_action_raw_strength("LT0")
	var L_t1 := Input.get_action_raw_strength("LT1")
	#
	var R_l := Input.get_action_raw_strength("RS_left")
	var R_r := Input.get_action_raw_strength("RS_right")
	var R_u := Input.get_action_raw_strength("RS_up")
	var R_d := Input.get_action_raw_strength("RS_down")
	var R_t0 := Input.get_action_raw_strength("RT0")
	var R_t1 := Input.get_action_raw_strength("RT1")
	#
	var L_stick := correct_and_convert_stick(L_l, L_r, L_u, L_d)
	var L_trig :=  Input.get_action_raw_strength("LT0") #correct_and_convert_trigger(L_t0, L_t1)
	var R_stick := correct_and_convert_stick(R_l, R_r, R_u, R_d)
	var R_trig :=  Input.get_action_raw_strength("RT0") #correct_and_convert_trigger(R_t0, R_t1)
	#
	$BaseArm.handle_input(L_stick, L_trig, delta)
	$BaseArm/ForeArm.handle_input(R_stick, R_trig, delta)
	#
	#
	#$ForeArm.basis = $BaseArm/Arm.basis



func correct_and_convert_stick(stick_l: float, stick_r: float, stick_u: float, stick_d: float) -> Vector2:
	var stick_totals := pow((0.01 + stick_l + stick_r + stick_u + stick_d), .9)
	var raw_x := stick_r - stick_l
	var raw_y := stick_u - stick_d
	var raw_diff: float = abs(abs(raw_x) - abs(raw_y))
	var final_x := raw_x / (1 + pow(1 - raw_diff, 1.5)*0.3)
	var final_y := raw_y / (1 + pow(1 - raw_diff, 1.5)*0.3)
	return Vector2(final_x, final_y)

func correct_and_convert_trigger(lt0: float, lt1: float) -> float:
	var trig := (1.0 - lt0 + lt1)/2.0
	if lt0 == 0 && lt1 == 0:
		trig = 0
	return trig
