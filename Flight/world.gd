extends Node3D


const CAM_SPRING := 0.1 # 90% per second
const CAM_SPRING_MULT := 2.0 # square the distance


func _process(delta: float) -> void:
	var cam_to_bird: Vector3 = $Bird.position - $CamPivot.position
	cam_to_bird *= pow(cam_to_bird.length(), CAM_SPRING_MULT-1)
	$CamPivot.global_position += cam_to_bird * (1 - pow(CAM_SPRING, delta))
