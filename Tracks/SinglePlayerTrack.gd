extends Track

signal return_to_main


func _process(delta) -> void:
	if $StartTimer.time_left:
		$Players.player.HUD.set_race_notice("%d" % ($StartTimer.time_left + 1), true)


func _setup_race() -> void:
	._setup_race()
	$Players.player.HUD.setup_minimap($Minimap.get_texture(), \
					$Minimap/MinimapCamera, $Players.players)
	$Players.player.pause_menu.connect("leave_race", self, "end_race")


func _preview_finished() -> void:
	$Players.player.set_current()
	$Players.player.has_cam_control = true
	._preview_finished()


func begin_countdown() -> void:
	$Players.player.pause_menu.set_process_input(true)
	$Players.player.HUD.visible = true
	.begin_countdown()


func start_race() -> void:
	.start_race()
	$Players.player.HUD.set_race_notice()


func end_race():
	.end_race()
	emit_signal("return_to_main")
