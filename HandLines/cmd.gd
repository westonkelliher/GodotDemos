extends Node2D
class_name Cmd


var subcmds: Array[SubCmd] = []

enum SubcType {Move, Interact, Pickup, Putdown}

class SubCmd:
	var type: SubcType = SubcType.Move
	var pos: Vector2 = Vector2.ZERO
	var nodes: Array[Node] = []

func add_subcmd(type: SubcType, pos: Vector2) -> void:
	var subc := SubCmd.new()
	subc.type = type
	subc.pos = pos
	subcmds.append(subc)
	
func add_node(node: Node) -> void:
	subcmds[-1].nodes.append(node)
	add_child(node)

func remove_subnodes(i: int) -> void:
	for n in subcmds[i].nodes:
		n.queue_free()

func get_subc(index: int) -> SubCmd:
	if index >= subcmds.size():
		return null
	return subcmds[index]
	
func get_start() -> Vector2:
	return subcmds[0].pos
