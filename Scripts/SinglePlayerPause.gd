extends Control

onready var main_slider : HSlider = $BG/Options/Main/Slider
onready var main_level : LineEdit = $BG/Options/Main/Level
onready var music_slider : HSlider = $BG/Options/Music/Slider
onready var music_level : LineEdit = $BG/Options/Music/Level

func _input(event) -> void:
	if event.is_action_pressed("Pause"):
		if Globals.game.single_player_manager.current_track != null:
			_toggle_pause()

func _open_options_menu() -> void:
	$BG/Main.visible = false
	$BG/Options.visible = true
	
	main_slider.value = Globals.sound_level
	main_level.text = str(_convert_decibal_to_percent(Globals.sound_level, main_slider))
	music_slider.value = Globals.music_level
	music_level.text = str(_convert_decibal_to_percent(Globals.music_level, music_slider))
	
func _close_options_menu() -> void:
	$BG/Main.visible = true
	$BG/Options.visible = false

func _toggle_pause():
	if get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_close_options_menu()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = !get_tree().paused
	visible = !visible

func _update_main_sound_values(new_value):
	if new_value is float:
		main_level.text = str(_convert_decibal_to_percent(new_value, main_slider))
	elif new_value is String:
		if main_level.text.is_valid_integer():
			if int(main_level.text) in range(main_slider.min_value, main_slider.max_value):
				main_slider.value = int(main_level.text)
				return
		main_level.text = str(main_slider.value)

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
	Globals.sound_level = main_slider.value
	Globals.music_level = music_slider.value

func _convert_decibal_to_percent(new_value : float, slider : Slider) -> int:
	return int(((new_value + abs(slider.min_value)) / abs(slider.min_value)) * 100)

func _quit_race():
	get_tree().paused = false
	Globals.game.single_player_manager.end_race()
