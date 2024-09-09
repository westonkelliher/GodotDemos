extends Node3D


var ttime := 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ttime += delta
	$Mesh.position.y = cos(ttime*4.0)*0.2
	$Mesh.rotation.y += 0.6 * delta


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.TOTAL_JUMPS += 1
		queue_free()
