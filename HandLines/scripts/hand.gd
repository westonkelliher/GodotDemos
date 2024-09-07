extends Node2D
class_name Hand

enum State {
	Move, StartMove, 
	StartPickup, StartPutdown, 
	StartInteract, Interacting,
	EndAction, FailAction}


signal finished_cmd(cmd: Cmd)

var assigned_cmd: Cmd = null
var target_index := 0
var is_executing := false
var state := State.Move

var held_object: Bip = null

var hovered_objects: Array[Bip] = []

var interact_object: Bip = null

const SPEED := 130.0

func _process(delta: float) -> void:
	# no command
	if assigned_cmd == null:
		return
	var subc := assigned_cmd.get_subc(target_index)
	# just finished command
	if subc == null:
		var temp := assigned_cmd
		assigned_cmd = null
		target_index = 0
		finished_cmd.emit(temp)
		return
	# moving through command
	if state == State.Move:
		position = position.move_toward(subc.pos, SPEED*delta)
		if held_object != null:
			held_object.global_position = $Sprite/HoldSpot.global_position
	# interacting
	if state == State.Interacting and held_object != null:
		held_object.global_position = $Sprite/HoldSpot.global_position
	# reached subcommand
	if state == State.Move and position == subc.pos:
		assigned_cmd.remove_subnodes(target_index)
		execute_subc(subc)
		target_index += 1


func execute_subc(subc: Cmd.SubCmd) -> void:
	if subc.type == Cmd.SubcType.Pickup:
		state_transition(State.StartPickup, 0.2)
	elif subc.type == Cmd.SubcType.Putdown:
		state_transition(State.StartPutdown, 0.2)
	elif subc.type == Cmd.SubcType.Interact:
		state_transition(State.StartInteract, 0.2)
	pass


func state_transition(new: State, time: float) -> void:
	if new == State.FailAction:
		modulate = Color(15.0, 0.8, 0.8)
	state = new
	$Timer.wait_time = time
	$Timer.start()

func _on_timer_timeout() -> void:
	if state == State.StartPickup:
		if hovered_objects.size() > 0 and held_object == null:
			pickup(hovered_objects[0])
			$Sprite.frame = 1
			state_transition(State.EndAction, 0.2)
		else:
			state_transition(State.FailAction, 0.5)
	elif state == State.StartPutdown:
		if held_object != null:
			putdown()
			$Sprite.frame = 0
			state_transition(State.EndAction, 0.2)
		else:
			state_transition(State.FailAction, 0.5)
	elif state == State.StartInteract:
		print("A")
		if hovered_objects.size() == 0:
			state_transition(State.FailAction, 0.5)
		elif held_object == null:
			if hovered_objects[0].type == Bip.Type.Ball:
				$Animation.play("interacrt")
				interact_object = hovered_objects[0]
				state_transition(State.Interacting, 2.0)
			else:
				state_transition(State.FailAction, 0.5)
		else:
			print("B")
			print(str(held_object.type) + " " + str(hovered_objects[0].type))
			if held_object.type == Bip.Type.Knife and hovered_objects[0].type == Bip.Type.Patty:
				$Animation.play("interacrt")
				print("C")
				interact_object = hovered_objects[0]
				state_transition(State.Interacting, 2.0)
			else:
				state_transition(State.FailAction, 0.5)
	elif state == State.Interacting:
		if interact_object.type == Bip.Type.Ball:
			interact_object.type = Bip.Type.Patty
		elif interact_object.type == Bip.Type.Patty:
			interact_object.type = Bip.Type.Cake
		else:
			print("interact on non-interactable")
		state_transition(State.EndAction, 0.2)
	elif state == State.EndAction:
		state = State.Move
	elif state == State.FailAction:
		modulate = Color(1.0, 1.0, 1.0)
		state = State.Move


func pickup(obj: Bip) -> void:
	held_object = hovered_objects[0]
	hovered_objects.erase(held_object)
	held_object.get_node("Area").monitorable = false
	held_object.position = position
	held_object.z_index += 1

func putdown() -> void:
	hovered_objects.append(held_object)
	held_object.get_node("Area").monitorable = true
	held_object.z_index -= 1
	held_object = null


func _on_area_area_entered(area: Area2D) -> void:
	print("enter")
	hovered_objects.append(area.owner)

func _on_area_area_exited(area: Area2D) -> void:
	print("exit")
	hovered_objects.erase(area.owner)
