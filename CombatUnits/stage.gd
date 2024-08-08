extends Node2D


func _ready() -> void:
	#$Sword.set_team(Guy.Team.RED)
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		$Sword/Animation.play("slash")
	var mouse_loc := get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("spawn_1"):
		spawn_unit(Guy.Team.RED, mouse_loc)
	if Input.is_action_just_pressed("spawn_2"):
		spawn_unit(Guy.Team.BLUE, mouse_loc)

func spawn_unit(team: Guy.Team, loc: Vector2) -> void:
	var guy := preload("res://guy.tscn").instantiate()
	guy.position = loc
	guy.team = team
	if team == Guy.Team.BLUE:
		guy.set_size(3.0)
	guy.target = $Guy
	add_child(guy)
