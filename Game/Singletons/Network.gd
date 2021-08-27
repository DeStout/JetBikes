extends Node

signal connected_to_host
signal update_lobby
signal setup_track
signal start_timer_start
signal finish_race

const MAX_CONNECTIONS : int = 12
const _DEFAULT_PORT : int = 34500
const _DEFAULT_IP : String = "127.0.0.1"
var _ip_address : String = _DEFAULT_IP

var upnp : UPNP = UPNP.new()

var test_track_ : PackedScene = load("res://Tracks/TestTrack/MultiplayerTestTrack.tscn")
var test_terrain_ : PackedScene = load("res://Tracks/TestTerrain/MultiplayerTestTerrain.tscn")
var level_dict : Dictionary = {
	"test_track" : test_track_,
	"test_terrain" : test_terrain_
	}
var level_dict_keys : Array = level_dict.keys()

var multiplayer_level : int = Globals.DEFAULT_LEVEL
var multiplayer_lap_amount : int = Globals.DEFAULT_LAP_NUMBER
var multiplayer_npc_amount : int = 0
var max_npc_num : int = 11

class PlayerData:

	var network_ID : int = 0
	var player_name : String = ""
	var placeholder_name : String = ""
	var color : Color = Color(0.184314, 0.788235, 1)
	var is_ready : bool = false
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
		temp_dict.global_trans = global_trans
		temp_dict.engine_rot = engine_rot
		temp_dict.placement = placement
		
		return temp_dict
	
	func dict_to_data(new_player_data : Dictionary) -> void:
		network_ID = new_player_data.network_ID
		player_name = new_player_data.player_name
		placeholder_name = new_player_data.placeholder_name
		color = new_player_data.color
		is_ready = new_player_data.is_ready
		global_trans = new_player_data.global_trans
		engine_rot = new_player_data.engine_rot
		placement = new_player_data.placement

var player_list : Dictionary = {}
var self_data : PlayerData = PlayerData.new()


func _ready():
	upnp.discover()


#
# Race Methods
#
remotesync func setup_online_multiplayer_race() -> void:
	if get_tree().get_rpc_sender_id() == 0:
		get_tree().network_peer.refuse_new_connections = true
		rpc("setup_online_multiplayer_race")
	else:
		for player in player_list:
			if player_list[player].player_name == "":
				player_list[player].player_name = player_list[player].placeholder_name
		
		# Signal to MultiplayerManager
		emit_signal("setup_track")


remotesync func track_ready() -> void:
	if get_tree().get_rpc_sender_id() == 0:
		self_data.is_ready = true
		rpc("track_ready")
	else:
		player_list[get_tree().get_rpc_sender_id()].is_ready = true
		if get_tree().is_network_server():
			for player in player_list:
				if !player_list[player].is_ready:
					break
			rpc("start_race")


remotesync func start_race() -> void:
	# Signal to current Track
	emit_signal("start_timer_start")


remotesync func player_finished() -> void:
	if get_tree().get_rpc_sender_id() == 0:
		rpc("player_finished")
	else:
		# Signal to MultiplayerPlayersTracker
		emit_signal("finish_race", player_list[get_tree().get_rpc_sender_id()].player_name)


#
# Lobby Methods
#
func set_IP_address(new_ip_address : String = _DEFAULT_IP) -> void:
	_ip_address = new_ip_address


func init_host() -> int:
	var port_result = upnp.add_port_mapping(_DEFAULT_PORT)
	
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
	
	max_npc_num -= 1
	
	emit_signal("update_lobby", "Peer Added")


func give_new_peer_player_data(new_peer_ID : int) -> void:
	var temp_list = {}
	for player in player_list:
		temp_list[player] = player_list[player].data_to_dict()
	rpc_id(new_peer_ID, "fill_player_list", temp_list)
	rpc_id(new_peer_ID, "update_race_info", Network.multiplayer_level, \
		Network.multiplayer_lap_amount, Network.multiplayer_npc_amount)


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
	if get_tree().get_rpc_sender_id() == 0:
		self_data.is_ready = player_ready
		player_list[get_tree().get_network_unique_id()].is_ready = player_ready
		rpc("update_player_ready", player_ready)
	else:
		player_list[get_tree().get_rpc_sender_id()].is_ready = player_ready
		
		emit_signal("update_lobby", "Player Ready")


remotesync func update_race_info(new_level_select : int, new_laps_amount : int, new_npc_amount : int) -> void:
	if get_tree().get_rpc_sender_id() == 0:
		rpc("update_race_info", new_level_select, new_laps_amount, new_npc_amount)
	else:
		Network.multiplayer_level = new_level_select
		Network.multiplayer_lap_amount = new_laps_amount
		Network.multiplayer_npc_amount = new_npc_amount
		
		emit_signal("update_lobby", "Race Info")


func remove_dead_peer(dead_peer_ID : int) -> void:
	player_list.erase(dead_peer_ID)
	update_placeholder_names()
	
	max_npc_num += 1
	
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
