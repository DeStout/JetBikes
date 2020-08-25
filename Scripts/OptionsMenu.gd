extends ColorRect

func _update_main_sound_values(new_value):
	if new_value is float:
		$Main/Level.text = str(_convert_decibal_to_percent(new_value, $Main/Slider))
	elif new_value is String:
		if $Main/Level.text.is_valid_integer():
			if int($Main/Level.text) in range($Main/Slider.min_value, $Main/Slider.max_value):
				$Main/Slider.value = int($Main/Level.text)
				return
		$Main/Level.text = str($Main/Slider.value)

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
	Globals.sound_level = $Main/Slider.value
	Globals.music_level = $Music/Slider.value

func reset_settings():
	$Main/Slider.value = Globals.sound_level
	$Main/Level.text = str(_convert_decibal_to_percent(Globals.sound_level, $Main/Slider))
	$Music/Slider.value = Globals.music_level
	$Music/Level.text = str(_convert_decibal_to_percent(Globals.music_level, $Music/Slider))

func _convert_decibal_to_percent(new_value : float, slider : Slider) -> int:
	return int(((new_value + abs(slider.min_value)) / abs(slider.min_value)) * 100)
