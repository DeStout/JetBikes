extends Spatial

var path_nodes : Array
onready var minimap : Viewport = $Minimap
onready var minimap_camera : Camera = $Minimap/MinimapCamera

var race_on_going : bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Globals.game.single_player_manager.setup_minimap(minimap.get_texture(), minimap_camera, $Players.players)
	
	if Globals.SHOW_NPC_PATHFIND:
		for player in $Players.players:
			if player is NPC:
				add_child(player.draw_path)

func _setup_pathnodes():
	path_nodes = $Minimap/Navigation/PathNodes.get_children()
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
	race_on_going = true
	$Players.start_race()
		
func finish_race() -> void:
	if race_on_going:
		race_on_going = false
		$Players.finish_race()
