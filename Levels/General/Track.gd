class_name Track
extends Spatial

onready var path_nodes : Array
onready var minimap : Viewport = $Minimap
onready var minimap_camera : Camera = $Minimap/MinimapCamera


func _ready() -> void:
	#	#	#	NPC path debug 	#	#	#	#	#
	if Globals.SHOW_NPC_PATHFIND:
		for player in $Players.players:
			if player is NPC:
				add_child(player.draw_path)
	#	#	#	#	#	#	#	#	#	#	#	#
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$Players.connect("race_finished", self, "finish_race")
	$Players.setup_players($Navigation, path_nodes)
	$Players.player.HUD.setup_minimap(minimap.get_texture(), minimap_camera, $Players.players)
	$Players.player.pause_menu.connect("end_race", self, "end_race")
	
	$MusicPlayer.play()


func _process(delta) -> void:
	if $StartTimer.time_left:
		$Players.player.HUD.set_race_notice("%d" % ($StartTimer.time_left + 1), true)


# Called by $Minimap/Naviation/PathNodes' ready signal
func setup_pathnodes():
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


func start_race() -> void:
	Globals.race_on_going = true
	$Players.player.HUD.set_race_notice()
	$Players.start_race()


func finish_race() -> void:
	Globals.race_on_going = false
	$EndTimer.start()


func end_race():
	$MusicPlayer.stop()
