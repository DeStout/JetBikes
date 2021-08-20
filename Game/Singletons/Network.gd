extends Node

signal update_lobby
signal setup_race

const _DEFAULT_PORT : int = 34500
const _MAX_CONNECTIONS : int = 12
const _DEFAULT_IP : String = "127.0.0.1"

var _upnp : UPNP = UPNP.new()
var _IP_address : String = "127.0.0.1"

var max_npc_num : int = 11

class PlayerData:

	var network_ID : int = 0
	var player_name : String = ""
	var placeholder_name : String = ""
	var color : Color = Color(0.184314, 0.788235, 1)
	var is_ready : bool = false
	
	func data_to_dict() -> Dictionary:
		var temp_dict = {}
		temp_dict.network_ID = network_ID
		temp_dict.player_name = player_name
		temp_dict.placeholder_name = placeholder_name
		temp_dict.color = color
		temp_dict.is_ready = is_ready
		
		return temp_dict
	
	func dict_to_data(new_player_data : Dictionary) -> void:
		network_ID = new_player_data.network_ID
		player_name = new_player_data.player_name
		placeholder_name = new_player_data.placeholder_name
		color = new_player_data.color
		is_ready = new_player_data.is_ready

var player_list = {}
var self_data : PlayerData = PlayerData.new()


remotesync func setup_online_multiplayer_race() -> void:
	if get_tree().get_rpc_sender_id() == 0:
		rpc("setup_online_multiplayer_race")
	else:
		emit_signal("setup_race")


func set_IP_address(new_IP_address : String) -> void:
	_IP_address = new_IP_address


func init_host() -> int:
	var upnp_result = _upnp.discover()
	var port_result = _upnp.add_port_mapping(_DEFAULT_PORT)
	
	var peer = NetworkedMultiplayerENet.new()
	var connection = peer.create_server(_DEFAULT_PORT, _MAX_CONNECTIONS)
	if connection == OK:
		peer.set_bind_ip(_IP_address)
		get_tree().set_network_peer(peer)
	
		self_data.placeholder_name = "Host"
		self_data.network_ID = 1
		self_data.is_ready = true
		player_list[1] = self_data
	
		print("IP Address: " + _IP_address)
	
	print("Server Connection Code: " + str(connection))
	return connection


func init_client() -> int:
	var peer = NetworkedMultiplayerENet.new()
	var connection = peer.create_client(_IP_address, _DEFAULT_PORT)
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
	rpc_id(new_peer_ID, "update_race_info", Globals.multiplayer_level, \
		Globals.multiplayer_laps_number, Globals.multiplayer_NPC_number)


remote func fill_player_list(new_player_list):
	for player in new_player_list:
		var player_data = PlayerData.new()
		player_data.dict_to_data(new_player_list[player])
		player_list[player] = player_data

		if player == self_data.network_ID:
			self_data = player_data

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
		player_list[self_data.network_ID].is_ready = player_ready
		rpc("update_player_ready", player_ready)
	else:
		player_list[get_tree().get_rpc_sender_id()].is_ready = player_ready
		
		emit_signal("update_lobby", "Player Ready")


remotesync func update_race_info(new_level_select : int, new_laps_amount : int, new_npc_amount : int) -> void:
	if get_tree().get_rpc_sender_id() == 0:
		rpc("update_race_info", new_level_select, new_laps_amount, new_npc_amount)
	else:
		Globals.multiplayer_level = new_level_select
		Globals.multiplayer_laps_number = new_laps_amount
		Globals.multiplayer_NPC_number = new_npc_amount
		
		emit_signal("update_lobby", "Race Info")


func remove_peer(dead_peer_ID : int) -> void:
	player_list.erase(dead_peer_ID)
	update_placeholder_names()
	
	max_npc_num += 1
	
	emit_signal("update_lobby", "Peer Removed")


func update_placeholder_names():
	var player_num = 2
	for player in player_list:
		if player != 1:
			player_list[player].placeholder_name = "Player" + str(player_num)
			player_num += 1


func close_network_connection() -> void:
	_clear_network_peer()
	_reset_network()


remote func _clear_network_peer() -> void:
	if get_tree().network_peer != null:
		get_tree().network_peer.close_connection()
		get_tree().set_network_peer(null)


func _reset_network() -> void:
	player_list = {}
	self_data = PlayerData.new()
	_IP_address = _DEFAULT_IP
