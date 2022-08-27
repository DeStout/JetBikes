extends Control

var current_focus : Control = null


func _ready():
	set_process_input(false)


func _hide_show() -> void:
	set_process_input(visible)
	yield(get_tree(), "idle_frame")

	if Input.get_connected_joypads().size():
		if current_focus == null:
			current_focus = $BackButton
		current_focus.grab_focus()
		yield(get_tree(), "idle_frame")


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
			if Input.is_action_just_pressed("ui_accept"):
				if current_focus is Button:
					current_focus.emit_signal("pressed")
			elif event.is_action_pressed("ui_cancel"):
				$BackButton.emit_signal("pressed")
