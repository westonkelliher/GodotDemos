extends Node




func add_task_line() -> void:
	var line := Line2D.new()
	line.width = 5
	line.default_color = Color.DARK_SLATE_GRAY
	line.add_point(Vector2(100, 100))
	line.add_point(Vector2(200, 200))
	add_child(line)
	var curve := Curve2D.new()
	curve.add_point(Vector2(300, 100), Vector2(10, 10), Vector2(100, 100))
	curve.add_point(Vector2(150, 50), Vector2(120, 150), Vector2(180, 150)) 
	#curve.add_point(Vector2(340, 200))
	var line2 := Line2D.new()
	var point_count := 20  # Number of points to sample along the curve
	for p in curve.get_baked_points():
		line2.add_point(p)
	line2.width = 3
	line2.default_color = Color(0.8, 0.2, 0.2)
	add_child(line2)
