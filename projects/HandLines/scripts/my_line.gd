extends Node2D

# Points for the start and end of the line
var start_point: Vector2
var end_point: Vector2
var line_color: Color = Color(0.1, 0.15, .3, 0.5)
var line_width: float = 6.0
#var current_cmd: Cmd = null

# Initialize the node with the start and end points
#func _init(start_point: Vector2, end_point: Vector2, line_color: Color = Color(1, 0, 0), line_width: float = 2.0) -> void:
	#self.start_point = start_point
	#self.end_point = end_point
	#self.line_color = line_color
	#self.line_width = line_width

# Custom drawing function
func _draw() -> void:
	draw_line(start_point, end_point, line_color, line_width, true)

# Update the line and redraw
func set_points(new_start: Vector2, new_end: Vector2) -> void:
	start_point = new_start
	end_point = new_end
	queue_redraw()
