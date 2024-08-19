extends Node2D

@export var container_height := 200.0 :
	set(val):
		container_height = val
		$RodTarget.container_height = container_height
	get:
		return container_height






func _ready() -> void:
	$RodTarget.container_height = container_height
	$TopLine.position.y = -container_height
	$BottomLine.position.y = 0.0

