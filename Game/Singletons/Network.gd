extends Node

signal connected_to_host
signal update_lobby
signal setup_track
signal start_timer_start
signal remove_disconnected_racer
signal finish_race
signal end_race

const MAX_CONNECTIONS : int = 12
const _DEFAULT_PORT : int = 34500
const _DEFAULT_IP : String = "127.0.0.1"
var _ip_address : String = _DEFAULT_IP

var upnp : UPNP = UPNP.new()

var race_finished := false

#var test_track_ : PackedScene = load("res://Tracks/TestTrack/TestTrack.tscn")
#var test_terrain_ : PackedScene = load("res://Tracks/TestTerrain/TestTerrain.tscn")
#var level_dict : Dictionary = {
#	"test_track" : test_track_,
#	"test_terrain" : test_terrain_
#	}
#var level_dict_keys : Array = level_dict.keys()
#
#var multiplayer_level : int = Globals.DEFAULT_LEVEL
#var multiplayer_lap_amount : int = Globals.DEFAULT_LAP_NUMBER
#var multiplayer_npc_amount : int = 0
#var max_npc_num : int = 11

class PlayerData:

	var network_ID : int = 0
	var player_name : String = ""
	var placeholder_name : String = ""
	var color : Color = Color(0.184314, 0.788235, 1)
	var is_ready : bool = false
	var is_in_race : bool = false
	var preview_finished : bool = false
	var global_trans : Transform = Transform(Basis(Vector3.ZERO))
	var engine_rot : Vector3 = Vector3.ZERO
	var placement : int = 0

	func data_to_dict() -> Dictionary:
		var temp_dict = {}

		temp_dict.network_ID = network_ID
		temp_dict.player_name = player_name
		temp_dict.placeholder_name = placeholder_name
		temp_dict.color = color
		temp_dict.is_ready = is_ready
		temp_dict.is_in_race = is_in_race
		temp_dict.preview_finished = preview_finished
		temp_dict.global_trans = global_trans
		temp_dict.engine_rot = engine_rot
		temp_dict.placement = placement

		return temp_dict
#
	func dict_to_data(new_player_data : Dictionary) -> void:
		network_ID = new_player_data.network_ID
		player_name = new_player_data.player_name
		placeholder_name = new_player_data.placeholder_name
		color = new_player_data.color
		is_ready = new_player_data.is_ready
		is_in_race = new_player_data.is_in_race
		preview_finished = new_player_data.preview_finished
		global_trans = new_player_data.global_trans
		engine_rot = new_player_data.engine_rot
		placement = new_player_data.placement

var player_list : Dictionary = {}
var self_data : PlayerData = PlayerData.new()


func _ready():
	var upnp_result := upnp.discover()
	print("Network UPNP Result: ", str(upnp_result))


#
# Race Methods
#
remotesync func setup_online_multiplayer_race() -> void:
	if get_tree().get_rpc_sender_id() == 0:
#		get_tree().network_peer.refuse_new_connections = true
		rpc("setup_online_multiplayer_race")
	else:
		for player in player_list:
			if player_list[player].player_name == "":
				player_list[player].player_name = player_list[player].placeholder_name

		# Signal to MultiplayerManager
		emit_signal("setup_track")


remotesync func is_in_race(is_in_race : bool) -> void:
	if get_tree().get_rpc_sender_id() == 0:
		self_data.is_in_race = is_in_race
		rpc("is_in_race", is_in_race)
	else:
		player_list[get_tree().get_rpc_sender_id()].is_in_race = is_in_race

		if get_tree().is_network_server():
			if is_in_race == false:
				if get_tree().get_rpc_sender_id() == self_data.network_ID:
					rpc("end_race")
					return
				rpc("remove_disconnected_racer", get_tree().get_rpc_sender_id())


remotesync func remove_disconnected_racer(racer_id : int) -> void:
	# Signal to MultiplayerPlayersTracker (remove_lame_racer)
	emit_signal("remove_disconnected_racer", racer_id)


remotesync func preview_finished() -> void:
	if get_tree().get_rpc_sender_id() == 0:
		self_data.preview_finished = true
		rpc("preview_finished")
	else:
		player_list[get_tree().get_rpc_sender_id()].preview_finished = true
		if get_tree().is_network_server():
			print("Player " + player_list[get_tree().get_rpc_sender_id()].player_name + " is ready")
			var all_players_ready = true

			for player in player_list:
				print(player_list[player].player_name, ": ", player_list[player].is_in_race, ", ", player_list[player].preview_finished)
				if !player_list[player].is_in_race:
					continue
				elif !player_list[player].preview_finished:
					all_players_ready = false
					break
			if all_players_ready:
				rpc("start_race")


remotesync func start_race() -> void:
	# Signal to current Track
	emit_signal("start_timer_start")


remotesync func player_finished() -> void:
	if get_tree().get_rpc_sender_id() == 0:
		rpc("player_finished")
	else:
		if !race_finished:
			race_finished = true
			# Signal to MultiplayerPlayersTracker (finish_race)
			emit_signal("finish_race", player_list[get_tree().get_rpc_sender_id()].player_name)


remotesync func end_race() -> void:
	if !get_tree().is_network_server():
		# Signals to MultiplayerManager (return_to_lobby)
		emit_signal("end_race")


remotesync func reset_racer() -> void:
	if get_tree().get_rpc_sender_id() == 0:
		self_data.is_in_race = false
		self_data.preview_finished = false
		rpc("reset_racer")
	else:
		print("Player reset: ", player_list[get_tree().get_rpc_sender_id()].player_name)
		player_list[get_tree().get_rpc_sender_id()].is_in_race = false
		player_list[get_tree().get_rpc_sender_id()].preview_finished = false


#
# Lobby Methods
#
func set_IP_address(new_ip_address : String = _DEFAULT_IP) -> void:
	_ip_address = new_ip_address


func init_host() -> int:
	var port_result = upnp.add_port_mapping(_DEFAULT_PORT)
	print("Network Port Code: ", str(port_result))

	var peer = NetworkedMultiplayerENet.new()
	var connection = peer.create_server(_DEFAULT_PORT, MAX_CONNECTIONS)
	if connection == OK:
#		peer.set_bind_ip(_ip_address)
		get_tree().set_network_peer(peer)

		self_data.placeholder_name = "Host"
		self_data.network_ID = 1
		self_data.is_ready = true
		player_list[1] = self_data

		print("IP Address: " + _ip_address)

	print("Server Connection Code: " + str(connection))
	return connection


func init_client() -> int:
	var peer = NetworkedMultiplayerENet.new()
	var connection = peer.create_client(_ip_address, _DEFAULT_PORT)
	if connection == OK:
		get_tree().set_network_peer(peer)
		self_data.network_ID = get_tree().get_network_unique_id()

	print("Client Connection Code: " + str(connection))
	return connection


func add_peer(new_peer_ID : int) -> void:
	var new_peer_data : PlayerData = PlayerData.new()
	new_peer_data.network_ID = new_peer_ID
	new_peer_data.placeholder_name = "Player" + str(player_list.size()+1)
	player_list[new_peer_ID] = new_peer_data

	Globals.max_NPC_number -= 1

	emit_signal("update_lobby", "Peer Added")


func give_new_peer_player_data(new_peer_ID : int) -> void:
	var temp_list = {}
	for player in player_list:
		temp_list[player] = player_list[player].data_to_dict()
	rpc_id(new_peer_ID, "fill_player_list", temp_list)
	rpc_id(new_peer_ID, "update_race_info", Globals.multiplayer_level, \
		Globals.multiplayer_laps_number, Globals.multiplayer_NPC_number)


remote func fill_player_list(new_player_list):
	for player in new_player_list:
		var player_data = PlayerData.new()
		player_data.dict_to_data(new_player_list[player])
		player_list[player] = player_data

		if player == get_tree().get_network_unique_id():
			self_data = player_data

	emit_signal("connected_to_host")
	emit_signal("update_lobby", "New Peer Player List")


remotesync func update_player_info(new_player_name : String, new_player_color : Color) -> void:
	if get_tree().get_rpc_sender_id() == 0:
		self_data.player_name = new_player_name
		self_data.color = new_player_color
		player_list[self_data.network_ID].player_name = new_player_name
		player_list[self_data.network_ID].color = new_player_color
		rpc("update_player_info", new_player_name, new_player_color)
	else:
		player_list[get_tree().get_rpc_sender_id()].player_name = new_player_name
		player_list[get_tree().get_rpc_sender_id()].color = new_player_color

		emit_signal("update_lobby", "Player Info")


remotesync func update_player_ready(player_ready : bool) -> void:
	print(get_tree().get_rpc_sender_id())
	if get_tree().get_rpc_sender_id() == 0:
		print("Player ready: ", str(player_ready))
		self_data.is_ready = player_ready
		player_list[get_tree().get_network_unique_id()].is_ready = player_ready
		rpc("update_player_ready", player_ready)
	else:
		player_list[get_tree().get_rpc_sender_id()].is_ready = player_ready

		emit_signal("update_lobby", "Player Ready")


remotesync func update_race_info(new_level_select : int, new_laps_number : int, new_npc_number : int) -> void:
	if get_tree().get_rpc_sender_id() == 0:
		rpc("update_race_info", new_level_select, new_laps_number, new_npc_number)
	else:
		Globals.multiplayer_level = new_level_select
		Globals.multiplayer_laps_number = new_laps_number
		Globals.multiplayer_NPC_number = new_npc_number

		emit_signal("update_lobby", "Race Info")


func remove_dead_peer(dead_peer_ID : int) -> void:
	player_list.erase(dead_peer_ID)
	update_placeholder_names()

	Globals.max_NPC_number += 1

	emit_signal("update_lobby", "Peer Removed")


func update_placeholder_names() -> void:
	var player_num = 2
	for player in player_list:
		if player != 1:
			player_list[player].placeholder_name = "Player" + str(player_num)
			player_num += 1


func close_network_connection() -> void:
	_clear_network_peer()
	_reset_network()


func _clear_network_peer() -> void:
	if get_tree().network_peer != null:
		get_tree().network_peer.close_connection()
		get_tree().set_network_peer(null)


func _reset_network() -> void:
	player_list = {}
	self_data = PlayerData.new()
	_ip_address = _DEFAULT_IP
