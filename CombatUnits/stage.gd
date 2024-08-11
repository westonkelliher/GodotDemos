extends Node2D

var targetables := []

var do_give_weapon := false

func _ready() -> void:
	#$Sword.set_team(Guy.Team.RED)
	targetables.append($Guy)
	$Guy.give_sword()
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_select"):
		$Sword/Animation.play("slash")
	var mouse_loc := get_viewport().get_mouse_position()
	if Input.is_action_just_pressed("spawn_1"):
		spawn_unit(Guy.Team.RED, mouse_loc, 0.7)
	if Input.is_action_just_pressed("spawn_2"):
		spawn_unit(Guy.Team.BLUE, mouse_loc, 2.0)
	if Input.is_action_just_pressed("spawn_3"):
		spawn_unit(Guy.Team.GREEN, mouse_loc, 1.0)

func spawn_unit(team: Guy.Team, loc: Vector2, size: float) -> void:
	var guy := preload("res://guy.tscn").instantiate()
	guy.position = loc
	guy.team = team
	guy.set_size(size)
	guy.wants_target.connect(give_target)
	guy.death.connect(handle_death)
	add_child(guy)
	if do_give_weapon:
		guy.give_sword()
	do_give_weapon = !do_give_weapon
	targetables.append(guy)

func give_target(guy: Guy) -> void:
	var nearest: Node2D = null
	var near_dist: float = 0.0
	print(targetables)
	for child: Node2D in targetables:
		if child == guy:
			continue
		if child is Guy and child.team == guy.team:
			continue
		print("---	")
		print(guy.global_position)
		print(child.global_position)
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

func handle_death(guy: Guy) -> void:
	targetables.erase(guy)
	guy.queue_free()
