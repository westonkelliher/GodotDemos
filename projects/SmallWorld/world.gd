extends Node3D


var offset = Vector3(0, 6, 6)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#offset = position*10
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var player_up = ($Player.position - Vector3(0, -10, 0)).normalized()
	# calculate basis
	var good_basis = Basis($Player.basis[0], player_up, -player_up.cross($Player.basis[0]))
	var cam_targ = $Player.position + (good_basis * offset)
	$Camera3D.set_target(cam_targ)
	var cam_up = ($Camera3D.position - Vector3(0, -10, 0)).normalized()
	$Camera3D.set_up(cam_up)
	$Camera3D.set_muse($Player.position)
	
