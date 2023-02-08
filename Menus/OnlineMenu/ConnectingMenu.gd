extends Control


signal connected_successfully

var connected_to_server := false
var num_attempts := 10
var yield_length := 0.5

var num_periods : int = 0


func _ready() -> void:
	$CancelButton.connect("pressed", Network, "reset_network")
	$CancelButton.connect("pressed", Globals.game.main_menu, "return_to_main")
	Network.connect("connected_successfully", self, "connected_to_server")


func _wait_for_connection() -> void:
	# Restrict Client from joining "ghost" server
	for _attempts in range(num_attempts):
		if connected_to_server:
			# Signal to OnlineMenu
			emit_signal("connected_successfully")
			break
		if is_visible_in_tree():
			yield(get_tree().create_timer(yield_length), "timeout")

	if !connected_to_server:
		print("Failed Server Connection")
		Network.reset_network()
		Globals.game.main_menu.return_to_main()


func connected_to_server() -> void:
	connected_to_server = true


# Signaled by Timer. Change Connecting text
func _connecting():
	$Connection.text = "Connecting"
	for _period in range(num_periods):
		$Connection.text += " ."

	num_periods = num_periods + 1 if num_periods < 3 else 0
