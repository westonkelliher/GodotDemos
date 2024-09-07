extends RigidBody3D
class_name Box

var has_target := false
var target := Vector3.ZERO
var velocity_to_target := 0.0


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var toward_target := (target - position).normalized()
	state.linear_velocity = toward_target*velocity_to_target
	

func set_target_with_velocity(t: Vector3, v: float) -> void:
	target = t
	velocity_to_target = v
	has_target = true

func revoke_target() -> void:
	has_target = false
