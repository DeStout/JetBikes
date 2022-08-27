extends Control

var current_focus : Control = null


func _ready():
	set_process_input(false)

	$SFX/Slider.min_value = Globals.MIN_SFX_LEVEL
	$SFX/Slider.max_value = Globals.MAX_SFX_LEVEL
	$Music/Slider.min_value = Globals.MIN_MUSIC_LEVEL
	$Music/Slider.max_value = Globals.MAX_MUSIC_LEVEL


func _hide_show() -> void:
	set_process_input(visible)
	yield(get_tree(), "idle_frame")

	if Input.get_connected_joypads().size():
		if current_focus == null:
			current_focus = $Buttons/ApplyButton
		current_focus.grab_focus()
		yield(get_tree(), "idle_frame")


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton:
			if Input.is_action_just_pressed("ui_accept"):
				if current_focus is Button:
					current_focus.emit_signal("pressed")
			elif event.is_action_pressed("ui_cancel"):
				$Buttons/BackButton.emit_signal("pressed")


func _update_sfx_sound_values(new_value):
	if new_value is float:
		$SFX/Level.text = str(_convert_decibal_to_percent(new_value, $SFX/Slider))
	elif new_value is String:
		if $SFX/Level.text.is_valid_integer():
			if int($SFX/Level.text) in range($SFX/Slider.min_value, $SFX/Slider.max_value):
				$SFX/Slider.value = int($SFX/Level.text)
				return
		$SFX/Level.text = str($SFX/Slider.value)


func _update_music_sound_values(new_value):
	if new_value is float:
		$Music/Level.text = str(_convert_decibal_to_percent(new_value, $Music/Slider))
	elif new_value is String:
		if $Music/Level.text.is_valid_integer():
			if int($Music/Level.text) in range($Music/Slider.min_value, $Music/Slider.max_value):
				$Music/Slider.value = int($Music/Level.text)
				return
		$Music/Level.text = str($Music/Slider.value)


func _apply_settings():
	Globals.sfx_level = $SFX/Slider.value
	Globals.music_level = $Music/Slider.value


func reset_settings():
	$SFX/Slider.value = Globals.sfx_level
	$SFX/Level.text = str(_convert_decibal_to_percent(Globals.sfx_level, $SFX/Slider))
	$Music/Slider.value = Globals.music_level
	$Music/Level.text = str(_convert_decibal_to_percent(Globals.music_level, $Music/Slider))


func _convert_decibal_to_percent(new_value : float, slider : Slider) -> int:
	return int(((new_value + abs(slider.min_value)) / abs(slider.min_value)) * 100)
