extends Node2D
class_name Hand

signal finished_cmd(cmd: Cmd)

var assigned_cmd: Cmd = null
var target_index := 0

const SPEED := 200.0

func _process(delta: float) -> void:
	if assigned_cmd != null:
		var subc := assigned_cmd.get_subc(target_index)
		if subc == null:
			var temp := assigned_cmd
			assigned_cmd = null
			target_index = 0
			finished_cmd.emit(temp)
			return
		position = position.move_toward(subc.pos, SPEED*delta)
		if position == subc.pos:
			assigned_cmd.remove_subnodes(target_index)
			target_index += 1
