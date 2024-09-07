extends Node3D


const CAM_SPRING := 0.06 # 94% per second
const CAM_SPRING_MULT := 2.0 # square the distance


func _process(delta: float) -> void:
	var cam_to_bird: Vector3 = $Bird.position - $CamPivot.position
	cam_to_bird *= pow(cam_to_bird.length(), CAM_SPRING_MULT-1)
	$CamPivot.global_position += cam_to_bird * (1 - pow(CAM_SPRING, delta))
	var a: Vector3 = $CamPivot.rotation
	$CamPivot.rotation = $Bird.rotation
	#
	$Label.text = str(float(int($Bird.velocity.length()*100))/100.0)
	if Input.is_action_just_pressed("cheat_up"):
		$Bird.position = Vector3(0, 300, 100)
		$CamPivot.position = Vector3(0, 300, 100)
