extends Node2D

var current_cmd: Cmd = null

var last_vert_pos := Vector2(0,0)
var connecting := false

var cmd_queue: Array[Cmd] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_cmd = preload("res://cmd.tscn").instantiate()
	$Cmds.add_child(current_cmd)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		add_cmd_vertex(mouse_position(), Cmd.SubcType.Interact, connecting)
		connecting = true
	if Input.is_action_just_pressed("pickup"):
		add_cmd_vertex(mouse_position(), Cmd.SubcType.Pickup, connecting)
		connecting = true
	if Input.is_action_just_pressed("putdown"):
		add_cmd_vertex(mouse_position(), Cmd.SubcType.Putdown, connecting)
		connecting = true
	if Input.is_action_just_pressed("finalize"):
		if !connecting:
			return
		var hand := get_next_hand(current_cmd.get_start())
		if hand != null:
			hand.assigned_cmd = current_cmd
		else:
			cmd_queue.append(current_cmd)
		#
		current_cmd = preload("res://cmd.tscn").instantiate()
		$Cmds.add_child(current_cmd)
		connecting = false
		
	#
	if connecting:
		$TempLine.set_points(last_vert_pos, mouse_position())
	else:
		$TempLine.set_points(Vector2(-100, -100), Vector2(-100, -100))


func mouse_position() -> Vector2:
	return get_viewport().get_mouse_position()

func add_cmd_vertex(pos: Vector2, type: Cmd.SubcType, with_line: bool) -> void:
	# vertex
	var x := preload("res://cmd_vertex.tscn").instantiate()
	x.frame = type
	x.position = pos
	current_cmd.add_subcmd(type, pos)
	current_cmd.add_node(x)
	# line
	if with_line:
		var line := preload("res://my_line.tscn").instantiate()
		line.set_points(last_vert_pos, pos)
		current_cmd.add_node(line)
	last_vert_pos = pos


func get_next_hand(cmd_start: Vector2) -> Hand:
	if $Hand1.assigned_cmd == null and $Hand2.assigned_cmd == null:
		# return nearest
		var d1: float = $Hand1.position.distance_to(cmd_start)
		var d2: float = $Hand2.position.distance_to(cmd_start)
		if d1 < d2:
			return $Hand1
		else:
			return $Hand2
	if $Hand1.assigned_cmd == null:
		return $Hand1
	if $Hand2.assigned_cmd == null:
		return $Hand2
	return null


func _on_hand1_finished_cmd(cmd: Cmd) -> void:
	if cmd_queue.size() > 0:
		print(cmd_queue)
		$Hand1.assigned_cmd = cmd_queue[0]
		cmd_queue.remove_at(0)
	cmd.queue_free()

func _on_hand2_finished_cmd(cmd: Cmd) -> void:
	if cmd_queue.size() > 0:
		print(cmd_queue)
		$Hand2.assigned_cmd = cmd_queue[0]
		cmd_queue.remove_at(0)
	cmd.queue_free()
