extends ColorRect

func _ready():
	$SFX/Slider.min_value = Globals.MIN_SFX_LEVEL
	$SFX/Slider.max_value = Globals.MAX_SFX_LEVEL
	$Music/Slider.min_value = Globals.MIN_MUSIC_LEVEL
	$Music/Slider.max_value = Globals.MAX_MUSIC_LEVEL

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
#	print("Options : " + str($SFX/Slider.value))
#	print("Options : " + str($Music/Slider.value))

func reset_settings():
	$SFX/Slider.value = Globals.sfx_level
	$SFX/Level.text = str(_convert_decibal_to_percent(Globals.sfx_level, $SFX/Slider))
	$Music/Slider.value = Globals.music_level
	$Music/Level.text = str(_convert_decibal_to_percent(Globals.music_level, $Music/Slider))

func _convert_decibal_to_percent(new_value : float, slider : Slider) -> int:
	return int(((new_value + abs(slider.min_value)) / abs(slider.min_value)) * 100)
