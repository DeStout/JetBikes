class_name Track
extends Spatial

signal return_to_main

onready var path_nodes : Array


func _ready() -> void:
	if !Globals.is_multiplayer:
		$Players.set_script(preload("res://Tracks/SinglePlayerPlayersTracker.gd"))
	else:
		$Players.set_script(preload("res://Tracks/MultiplayerPlayersTracker.gd"))

	_setup_race()

	if !Globals.is_multiplayer:
		$Players.player.HUD.setup_minimap($Minimap.get_texture(), \
						$Minimap/MinimapCamera, $Players.players)
		$Players.player.pause_menu.connect("leave_race", self, "end_race")
	else:
		$Players.master_player.HUD.setup_minimap($Minimap.get_texture(), \
						$Minimap/MinimapCamera, $Players.players)
		$Players.master_player.pause_menu.connect("leave_race", self, "end_race")

		Network.connect("start_timer_start", self, "begin_countdown")


func _process(delta) -> void:
	if $StartTimer.time_left:
		if !Globals.is_multiplayer:
			$Players.player.HUD.set_race_notice("%d" % ($StartTimer.time_left + 1), true)
		else:
			$Players.master_player.HUD.set_race_notice("%d" % ($StartTimer.time_left + 1), true)


func _setup_race() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	$Players.connect("race_finished", self, "finish_race")
	$Players.setup_players($TrackPath, path_nodes)

#	AudioServer.set_bus_mute(Globals.master_bus, true)
	AudioServer.set_bus_mute(Globals.master_bus, false)
	$MusicPlayer.play()


# Called by $PathNodes' ready signal
func setup_pathnodes() -> void:
	path_nodes = $PathNodes.get_children()

	if path_nodes.size() > 0:
		var path_nodes_array = []
		var i : int = 0
		var j : int = 1
		while i + j <= path_nodes.size():
			var temp_array = []
			while i + j <= path_nodes.size() - 1:
				if path_nodes[i].serial != path_nodes[i + j].serial:
					break;
				j += 1
			if j > 1:
				for k in range(j):
					temp_array.append(path_nodes[k+i])
				path_nodes_array.append(temp_array)
			else:
				path_nodes_array.append(path_nodes[i])
			i += j
			j = 1
		path_nodes = path_nodes_array


func _preview_finished():
	if !Globals.is_multiplayer:
		$Players.player.set_current()
		$Players.player.has_cam_control = true
		begin_countdown()
	else:
		$Players.master_player.set_current()
		$Players.master_player.has_cam_control = true
		Network.track_ready()


func begin_countdown() -> void:
	$StartTimer.start()
	if !Globals.is_multiplayer:
		$Players.player.HUD.visible = true
	else:
		$Players.master_player.HUD.visible = true


func start_race() -> void:
	Globals.race_on_going = true
	if !Globals.is_multiplayer:
		$Players.player.HUD.set_race_notice()
	else:
		$Players.master_player.HUD.set_race_notice()
	$Players.start_race()

# Multiplayer function
func remove_dead_peer(dead_peer_ID : int) -> void:
	$Players.remove_dead_peer(dead_peer_ID)


func finish_race() -> void:
	Globals.race_on_going = false
	$EndTimer.start()


func end_race() -> void:
	$MusicPlayer.stop()
	emit_signal("return_to_main")
