@tool
extends StaticBody3D

@export var color := Color.WHITE :
	set(x):
		color = x
		$MeshInstance3D.mesh.material.albedo_color = x
	get:
		return color

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MeshInstance3D.mesh = $MeshInstance3D.mesh.duplicate()
	$MeshInstance3D.mesh.material = $MeshInstance3D.mesh.material.duplicate()
	$MeshInstance3D.mesh.material.albedo_color = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
