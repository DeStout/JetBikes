extends Node

const _DEFAULT_PORT : int = 34500
const _MAX_CONNECTIONS : int = 12

var _upnp : UPNP = UPNP.new()
var _IP_address : String = "127.0.0.1"

var self_data = {"network_ID" : "", "player_ID" : "", "color" : Color(0.184314, 0.788235, 1)}
var player_list = {}


func init_host() -> void:
	var upnp_result = _upnp.discover()
	var port_result = _upnp.add_port_mapping(_DEFAULT_PORT)

	clear_network_peer()
	
	var peer = NetworkedMultiplayerENet.new()
	var connection = peer.create_server(_DEFAULT_PORT, _MAX_CONNECTIONS)
	peer.set_bind_ip(_IP_address)
	get_tree().set_network_peer(peer)
	
	print("IP Address: " + _IP_address)
	print("Server Connection Code: " + str(connection))
	
	self_data.player_ID = "Host"
	self_data.network_id = 1
	player_list[1] = self_data


func init_client() -> void:		
	clear_network_peer()
	
	var peer = NetworkedMultiplayerENet.new()
	var connection = peer.create_client(_IP_address, _DEFAULT_PORT)
	get_tree().set_network_peer(peer)
	self_data.network_ID = get_tree().get_network_unique_id()
	
	print("Client Connection Code: " + str(connection))


func set_IP_address(new_IP_address : String) -> void:
	_IP_address = new_IP_address


func clear_network_peer() -> void:
	if get_tree().network_peer != null:
		get_tree().network_peer.close_connection()
		get_tree().set_network_peer(null)
