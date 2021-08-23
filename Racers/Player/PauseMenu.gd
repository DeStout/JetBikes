class_name PauseMenu
extends Control


signal leave_race

onready var sfx_slider : HSlider = $BG/Options/SFX/Slider
onready var sfx_level : LineEdit = $BG/Options/SFX/Level
onready var music_slider : HSlider = $BG/Options/Music/Slider
onready var music_level : LineEdit = $BG/Options/Music/Level


func _ready():
	sfx_slider.min_value = Globals.MIN_SFX_LEVEL
	sfx_slider.max_value = Globals.MAX_SFX_LEVEL
	music_slider.min_value = Globals.MIN_MUSIC_LEVEL
	music_slider.max_value = Globals.MAX_MUSIC_LEVEL


func _input(event) -> void:
	if event.is_action_pressed("Pause"):
		_toggle_pause()


func _toggle_pause():
	pass


func _open_options_menu() -> void:
	$BG/Main.visible = false
	$BG/Options.visible = true
	
	sfx_slider.value = Globals.sfx_level
	sfx_level.text = str(_convert_decibal_to_percent(Globals.sfx_level, sfx_slider))
	music_slider.value = Globals.music_level
	music_level.text = str(_convert_decibal_to_percent(Globals.music_level, music_slider))


func _close_options_menu() -> void:
	$BG/Main.visible = true
	$BG/Options.visible = false


func _update_sfx_sound_values(new_value):
	if new_value is float:
		sfx_level.text = str(_convert_decibal_to_percent(new_value, sfx_slider))
	elif new_value is String:
		if sfx_level.text.is_valid_integer():
			if int(sfx_level.text) in range(sfx_slider.min_value, sfx_slider.max_value):
				sfx_slider.value = int(sfx_level.text)
				return
		sfx_level.text = str(sfx_slider.value)


func _update_music_sound_values(new_value):
	if new_value is float:
		music_level.text = str(_convert_decibal_to_percent(new_value, music_slider))
	elif new_value is String:
		if music_level.text.is_valid_integer():
			if int(music_level.text) in range(music_slider.min_value, music_slider.max_value):
				music_slider.value = int(music_level.text)
				return
		music_level.text = str(music_slider.value)


func _apply_settings():
	Globals.sfx_level = sfx_slider.value
	Globals.music_level = music_slider.value


func _convert_decibal_to_percent(new_value : float, slider : Slider) -> int:
	return int(((new_value + abs(slider.min_value)) / abs(slider.min_value)) * 100)


func _quit_race():
	emit_signal("leave_race")
