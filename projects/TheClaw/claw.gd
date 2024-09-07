extends Node3D

const MIN_VEL = 100.0

var bodies := []
var grabbed_bodies := {}

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("RB"):
		for body: Node3D in bodies:
			if body is Box:
				grabbed_bodies[body] = body.global_position - global_position
	if Input.is_action_just_released("RB"):
		grabbed_bodies = {}
	#
	for body: Box in grabbed_bodies:
		var target_pos: Vector3 = global_position + grabbed_bodies[body]
		#var to_target := target_pos - body.position
		#var vel := MIN_VEL + to_target.length()*10.0
		#if to_target.length() < vel*delta: # WARNING: bug here if delta gets out of whack
			## if the distance to the target is so small such that the velocity 
			## would cause it to overshoot the target next frame, only give enough 
			## speed to make it exactly hit the target next frame  
			#vel = MIN_VEL*delta
		#body.set_target_with_velocity(target_pos, vel)
		body.position = target_pos

func _on_area_3d_body_entered(body: Node3D) -> void:
	bodies.append(body)



func _on_area_3d_body_exited(body: Node3D) -> void:
	bodies.erase(body)
