extends Node

signal return_to_main



func _on_CancelButton_pressed():
	emit_signal("return_to_main")
