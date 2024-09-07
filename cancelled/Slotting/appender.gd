extends Control

signal activated()


func _on_button_pressed() -> void:
	activated.emit()
	print("press")


func _on_button_button_down() -> void:
	print("btn down")
