extends Sprite2D


func save_to_png(title: String) -> void:
	if texture:
		var image := texture.get_image()
		# Lock the image for reading
		#image.lock()
		var error := image.save_png("res://renders/"+title+".png")
		if error == OK:
			print("Image saved successfully.")
		else:
			print("Error saving image: ", error)
		#image.unlock()
	else:
		print("No texture found in Sprite2D")
