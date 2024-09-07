@tool
extends Node2D
class_name Bip


enum Type {Ball, Patty, Cake, Knife}

@export var type := Type.Ball :
	set(val):
		type = val
		if val == Type.Ball:
			$Sprite.frame = 0
		elif val == Type.Patty:
			$Sprite.frame = 1
		elif val == Type.Cake:
			$Sprite.frame = 2
		elif val == Type.Knife:
			$Sprite.frame = 3
	get:
		return type


func _ready() -> void:
	$Area.owner = self
