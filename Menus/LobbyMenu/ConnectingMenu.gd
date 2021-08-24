extends Control

onready var connect_text = $MenuFrame/LobbyFrame/Connection
onready var cancel_button = $MenuFrame/LobbyFrame/CancelPanel/CancelButton
var num_periods : int = 0


func _ready():
	connect_text.text = "Connecting\n\n"


func _connecting():
	connect_text.text = "Connecting"
	for period in range(num_periods):
		connect_text.text += " ."
	connect_text.text += "\n\n"
	
	num_periods = num_periods + 1 if num_periods < 3 else 0