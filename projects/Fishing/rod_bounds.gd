extends Node2D

signal win()

@export var container_height := 200.0 :
	set(val):
		container_height = val
		$RodTarget.container_height = container_height
		$FishTarget.container_height = container_height
		$ProgressBar.full_width = container_height
	get:
		return container_height

@export var container_width := 100.0 :
	set(val):
		container_width = val
		$RodTarget.container_width = container_width
		$FishTarget.container_width = container_width
	get:
		return container_width

const P_PLUS := 0.24
const P_MINUS := 0.11

var progress := 0.0
var delta_p := 0.0


func _ready() -> void:
	$RodTarget.container_height = container_height
	$TopLine.position.y = -container_height
	$BottomLine.position.y = 0.0
	$LeftLine.position.x = -container_width
	$RightLine.position.x = container_width
	$LeftLine.position.y = -container_height / 2.0
	$RightLine.position.y = -container_height / 2.0

func _process(delta: float) -> void:
	progress += delta_p*delta
	if progress < 0.0:
		progress = 0.0
	if progress > 1.0:
		progress = 1.0
	$ProgressBar.set_progress(progress)


func _on_progress_bar_complete() -> void:
	win.emit()


func _on_rod_target_fish_enter() -> void:
	delta_p = P_PLUS


func _on_rod_target_fish_exit() -> void:
	delta_p = -P_MINUS
