extends Camera3D

const SPEED := 2.0

var target := Vector3.ZERO
var up := Vector3.UP
var muse := Vector3.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var sped = SPEED + 5.0 * position.distance_to(target)
	position = position.move_toward(target, sped*delta)
	look_at(muse, up)

func set_target(t: Vector3):
	target = t

func set_up(u: Vector3):
	up = u

func set_muse(m: Vector3):
	muse = m
