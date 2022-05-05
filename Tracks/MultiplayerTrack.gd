extends Track

signal return_to_lobby


func _ready():
	$Players.master_player.HUD.setup_minimap($Minimap.get_texture(), \
		$Minimap/MinimapCamera, $Players.players)


func setup_race() -> void:
	.setup_race()
	$Players.master_player.HUD.setup_minimap($Minimap.get_texture(), \
		$Minimap/MinimapCamera, $Players.players)

	Network.connect("start_timer_start", self, "begin_countdown")
#	Network.track_ready()


func _process(delta) -> void:
	if $StartTimer.time_left:
		$Players.master_player.HUD.set_race_notice("%d" % ($StartTimer.time_left + 1), true)


func remove_dead_peer(dead_peer_ID : int) -> void:
	$Players.remove_dead_peer(dead_peer_ID)


func _preview_finished() -> void:
	$Players.master_player.set_current()
	$Players.master_player.has_cam_control = true


func begin_countdown():
#	$Players.master_player.pause_menu.set_process_input(true)
	$Players.master_player.HUD.visible = true
	.begin_countdown()


func start_race() -> void:
	.start_race()
	$Players.master_player.HUD.set_race_notice()


func end_race():
	.end_race()
	# Signal to MultiplayerManager
	emit_signal("return_to_lobby")
