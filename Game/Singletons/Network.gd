extends Node


signal connected_successfully


#const _IP : String = "127.0.0.1"
const _IP : String = "144.24.39.221"
const _PORT : int = 34500
var upnp : UPNP = UPNP.new()

var player_list : Dictionary = {}
var self_data := {}


func _ready():
	# Called by Host and Client
	get_tree().connect("network_peer_connected", self, "_peer_connected")
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")
	# Only called by Client
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("connection_failed", self, "_server_connection_failed")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

	var upnp_result := upnp.discover()
	print("Network UPNP Result: ", str(upnp_result))

	set_self_data()


func set_self_data() -> void:
	self_data = {
		"network_ID" :  0,
		"player_name" : "",
		"placeholder_name" : "",
		"color" : Color(0.184314, 0.788235, 1),
		"is_ready" : false,
		"is_in_race" : false,
		"preview_finished" : false,
		"global_trans" : Transform(Basis(Vector3.ZERO)),
		"engine_rot" : Vector3.ZERO,
		"placement" : 0
}


func create_client() -> int:
	var peer = NetworkedMultiplayerENet.new()
	var client_code = peer.create_client(_IP, _PORT)
	if client_code == OK:
		get_tree().set_network_peer(peer)

	print("Client Creation Code: " + str(client_code))
	return client_code


func _peer_connected(new_peer_id) -> void:
	print("Peer Connected: ", new_peer_id)


func _peer_disconnected(dead_peer_id) -> void:
	print("Peer Disconnected: ", dead_peer_id)


func _connected_to_server() -> void:
	# Signal to ConnectingMenu
	emit_signal("connected_successfully")


func _server_connection_failed() -> void:
	print("Failed Server Connection")


func _server_disconnected() -> void:
	print("Disconnected From Server")


func reset_network() -> void:
	set_self_data()

	if get_tree().network_peer != null:
		get_tree().network_peer.close_connection()
		get_tree().set_network_peer(null)
