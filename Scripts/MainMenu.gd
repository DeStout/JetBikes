extends Control

const NPC_FRAME_DEFAULT_POSITION : int = 256
const NPC_FRAME_OPTIONS_POSITION : int = 32

var solo_lap_amount : int = Globals.DEFAULT_LAP_NUMBER
var solo_NPC_amount : int = Globals.DEFAULT_NPC_NUMBER

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	$MenuFrame/SinglePlayerFrame/Laps/NumLapsAmount.text = str(solo_lap_amount)
	$MenuFrame/SinglePlayerFrame/NPC/NumNPCAmount.text = str(solo_NPC_amount)
	
func _on_SoloButton_pressed() -> void:
	_clear_options()
	$MenuFrame/MainFrame.rect_position.x = NPC_FRAME_OPTIONS_POSITION
	$MenuFrame/SinglePlayerFrame.visible = true
	$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = true

func _on_QuitButton_pressed() -> void:
	get_tree().quit()
	
func _on_LapIncrease_pressed():
	solo_lap_amount += 1
	solo_lap_amount = clamp(solo_lap_amount, Globals.MIN_LAP_NUMBER, Globals.MAX_LAP_NUMBER)
	$MenuFrame/SinglePlayerFrame/Laps/NumLapsAmount.text = str(solo_lap_amount)
	
func _on_LapDecrease_pressed():
	solo_lap_amount -= 1
	solo_lap_amount = clamp(solo_lap_amount, Globals.MIN_LAP_NUMBER, Globals.MAX_LAP_NUMBER)
	$MenuFrame/SinglePlayerFrame/Laps/NumLapsAmount.text = str(solo_lap_amount)
	
func _on_NPCIncrease_pressed():
	solo_NPC_amount += 1
	solo_NPC_amount = clamp(solo_NPC_amount, Globals.MIN_NPC_NUMBER, Globals.MAX_NPC_NUMBER)
	$MenuFrame/SinglePlayerFrame/NPC/NumNPCAmount.text = str(solo_NPC_amount)
	
func _on_NPCDecrease_pressed():
	solo_NPC_amount -= 1
	solo_NPC_amount = clamp(solo_NPC_amount, Globals.MIN_NPC_NUMBER, Globals.MAX_NPC_NUMBER)
	$MenuFrame/SinglePlayerFrame/NPC/NumNPCAmount.text = str(solo_NPC_amount)

func _on_Solo_RaceButton_pressed() -> void:
	Globals.laps_number = solo_lap_amount
	Globals.NPC_number = solo_NPC_amount
	Globals.game.start_single_player_game()

func _on_Solo_CancelButton_pressed() -> void:
	_clear_options()
	$MenuFrame/MainFrame.rect_position.x = NPC_FRAME_DEFAULT_POSITION
	
func _clear_options() -> void:
	$MenuFrame/SinglePlayerFrame.visible = false
	$MenuFrame/MainFrame/MainPanel/SoloButton.pressed = false




