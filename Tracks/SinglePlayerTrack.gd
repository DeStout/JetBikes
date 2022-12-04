extends Track

#signal return_to_main




#func _preview_finished() -> void:


#func begin_countdown() -> void:
#	$Players.player.pause_menu.set_process_input(true)
#	$Players.player.HUD.visible = true


#func start_race() -> void:
#	$Players.player.HUD.set_race_notice()


#func end_race():
#	# Emit to Game
#	emit_signal("return_to_main")
