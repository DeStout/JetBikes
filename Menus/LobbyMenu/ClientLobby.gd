extends LobbyMenu


signal failed_connection
var connected_to_host = false


func _ready():
	Network.connect("connected_to_host", self, "connected_to_host")
	update_lobby_info("Lobby Created")

	_wait_for_connection()


func _wait_for_connection() -> void:
	# Restrict Client from joining "ghost" server
	for attempts in range(20):
		if connected_to_host:
			$ConnectingMenu.visible = false
			$LobbyFrame.visible = true
			break
		yield(get_tree().create_timer(0.5), "timeout")
	$ConnectingMenu.get_node("Timer").stop()

	if !connected_to_host:
		# Signal to MultiplayerManager
		emit_signal("failed_connection")


func connected_to_host():
	connected_to_host = true


func toggle_racer_ready(racer_ready : bool):
	ready_button.pressed = racer_ready
	Network.update_player_ready(racer_ready)


func update_lobby_info(update_type : String) -> void:
	.update_lobby_info(update_type)

	level_name.text = Globals.level_dict_keys[Globals.multiplayer_level]
	num_laps.text = str(Globals.multiplayer_laps_number)
#	num_npcs.text = str(Globals.multiplayer_NPC_number)
	num_npcs.text = str(0)


func reset_lobby() -> void:
	.reset_lobby()
	print("Client Lobby reset")
	toggle_racer_ready(false)
