extends Node3D


const IMAGE_COUNT := 16
const SPRITESHEET_COLUMNS := 8

var progress := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right"):
		holdon()
	#if progress < IMAGE_COUNT:
		#var angle := 2*PI*progress / float(IMAGE_COUNT)
		#$Subject.rotation.y = angle
		#$ImageSprite.save_to_png("img_"+str(int(angle*180/PI)))
		#progress += 1


func save_angled_images() -> void:
	for i in range(0, IMAGE_COUNT):
		var angle := 2*PI*i / 16.0
		$Subject.rotation.y = angle
		$ImageSprite.save_to_png("img_"+str(int(angle*180/PI)))


func holdon() -> void:
	var viewport: SubViewport = $subviewport
	var viewport_size := viewport.size
	var sprite_size := viewport_size
	print(viewport_size)
	var spritesheet_rows: int = ceil(float(IMAGE_COUNT) / SPRITESHEET_COLUMNS)
	var spritesheet_size := Vector2(sprite_size.x * SPRITESHEET_COLUMNS, sprite_size.y * spritesheet_rows)
	print(spritesheet_size)
	var spritesheet := Image.new()
	spritesheet = spritesheet.create(spritesheet_size.x, spritesheet_size.y, false, Image.FORMAT_RGB8)

	for i in range(IMAGE_COUNT):
		# Rotate the mesh
		var angle := 2*PI*i / 16.0
		$Subject.rotation.y = angle

		# Update the viewport
		await get_tree().process_frame

		# Capture the image from the viewport
		var texture := viewport.get_texture()
		var image := texture.get_image()
		print(image.get_format())
		var title := "img_"+str(int(angle*180/PI))
		image.save_png("res://renders/"+title+".png")

		# Calculate the position to place the image in the spritesheet
		var row := i / SPRITESHEET_COLUMNS
		var col := i % SPRITESHEET_COLUMNS
		var dest_rect := Rect2i(col * sprite_size.x, row * sprite_size.y, sprite_size.x, sprite_size.y)

		# Blit the captured image into the spritesheet
		spritesheet.blit_rect(image, Rect2i(Vector2(0, 0), sprite_size), dest_rect.position)
		print(image)
		print(Rect2i(Vector2(0, 0), sprite_size))
		print(dest_rect.position)

	# Save the spritesheet as a PNG
	var error := spritesheet.save_png("res://spritesheet.png")
	if error == OK:
		print("Spritesheet saved successfully.")
	else:
		print("Error saving spritesheet: ", error)
