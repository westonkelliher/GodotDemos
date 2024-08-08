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
		guy.set_size(2.0)
	guy.target = $Targetables/Guy
	guy.wants_target.connect(give_target)
	$Targetables.add_child(guy)

func give_target(guy: Guy) -> void:
	var nearest: Node2D = null
	var near_dist: float = 0.0
	for child in $Targetables.get_children():
		if child == guy:
			continue
		if child is Guy and child.team == guy.team:
			continue
		var child_dist := guy.global_position.distance_to(child.global_position)
		if nearest == null:
			nearest = child
			near_dist = child_dist
			continue
		if child_dist < near_dist:
			nearest = child
			near_dist = child_dist
	guy.target = nearest
	print("targ:::: " + str(guy.target))
