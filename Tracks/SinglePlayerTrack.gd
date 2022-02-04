extends Track

signal return_to_main


func _process(delta) -> void:
	if $StartTimer.time_left:
		$ViewportContainer/Viewport/Players.player.HUD.set_race_notice("%d" % ($StartTimer.time_left + 1), true)


func _setup_race() -> void:
	._setup_race()
	$ViewportContainer/Viewport/Players.player.HUD.setup_minimap($ViewportContainer/Viewport/Minimap.get_texture(), \
					$ViewportContainer/Viewport/Minimap/MinimapCamera, $ViewportContainer/Viewport/Players.players)
	$ViewportContainer/Viewport/Players.player.pause_menu.connect("leave_race", self, "end_race")


func _preview_finished() -> void:
	._preview_finished()
	$ViewportContainer/Viewport/Players.player.set_current()
	$ViewportContainer/Viewport/Players.player.has_cam_control = true


func begin_countdown() -> void:
	.begin_countdown()

	$ViewportContainer/Viewport/Players.player.pause_menu.set_process_input(true)
	$ViewportContainer/Viewport/Players.player.HUD.visible = true


func start_race() -> void:
	.start_race()
	$ViewportContainer/Viewport/Players.player.HUD.set_race_notice()


func end_race():
	.end_race()
	emit_signal("return_to_main")
