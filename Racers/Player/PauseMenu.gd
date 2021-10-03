class_name PauseMenu
extends Control


signal leave_race

onready var sfx_slider : HSlider = $BG/Options/SFX/Slider
onready var sfx_level : LineEdit = $BG/Options/SFX/Level
onready var music_slider : HSlider = $BG/Options/Music/Slider
onready var music_level : LineEdit = $BG/Options/Music/Level


func _ready():
	set_process_input(false)
	
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
	$BG/Controls.visible = false
	
	sfx_slider.value = Globals.sfx_level
	sfx_level.text = str(_convert_decibal_to_percent(Globals.sfx_level, sfx_slider))
	music_slider.value = Globals.music_level
	music_level.text = str(_convert_decibal_to_percent(Globals.music_level, music_slider))


func _open_controls_menu() -> void:
	$BG/Main.visible = false
	$BG/Options.visible = false
	$BG/Controls.visible = true


func _close_menus() -> void:
	$BG/Main.visible = true
	$BG/Options.visible = false
	$BG/Controls.visible = false


func _update_sfx_sound_values(new_value):
	if new_value is float:
		sfx_level.text = str(_convert_decibal_to_percent(new_value, sfx_slider))
	elif new_value is String:
		if sfx_level.text.is_valid_integer():
			if int(sfx_level.text) in range(0, 101):
				sfx_slider.value = _convert_percent_to_decibal(int(sfx_level.text), sfx_slider)
				return
		sfx_level.text = str(_convert_decibal_to_percent(sfx_slider.value, sfx_slider))


func _update_music_sound_values(new_value):
	if new_value is float:
		music_level.text = str(_convert_decibal_to_percent(new_value, music_slider))
	elif new_value is String:
		if music_level.text.is_valid_integer():
			if int(music_level.text) in range(0, 101):
				music_slider.value = _convert_percent_to_decibal(int(music_level.text), music_slider)
				return
		music_level.text = str(_convert_decibal_to_percent(music_slider.value, music_slider))


func _apply_settings():
	Globals.sfx_level = sfx_slider.value
	Globals.music_level = music_slider.value


func _convert_decibal_to_percent(decibal : float, slider : Slider) -> int:
	return int(((slider.min_value - decibal) / (slider.min_value - slider.max_value)) * 100)


func _convert_percent_to_decibal(new_percent : int, slider : Slider) -> float:
	return -new_percent * (slider.min_value - slider.max_value) / 100 + slider.min_value
	
