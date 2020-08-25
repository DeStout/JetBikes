extends ColorRect

var solo_lap_amount : int = Globals.DEFAULT_LAP_NUMBER
var solo_NPC_amount : int = Globals.DEFAULT_NPC_NUMBER

func _ready():
	$Laps/NumLapsAmount.text = str(solo_lap_amount)
	$NPC/NumNPCAmount.text = str(solo_NPC_amount)

func _increase_lap_amount():
	solo_lap_amount += 1
	solo_lap_amount = clamp(solo_lap_amount, Globals.MIN_LAP_NUMBER, Globals.MAX_LAP_NUMBER)
	$Laps/NumLapsAmount.text = str(solo_lap_amount)

func _decrease_lap_amount():
	solo_lap_amount -= 1
	solo_lap_amount = clamp(solo_lap_amount, Globals.MIN_LAP_NUMBER, Globals.MAX_LAP_NUMBER)
	$Laps/NumLapsAmount.text = str(solo_lap_amount)

func _increase_NPC_amount():
	solo_NPC_amount += 1
	solo_NPC_amount = clamp(solo_NPC_amount, Globals.MIN_NPC_NUMBER, Globals.MAX_NPC_NUMBER)
	$NPC/NumNPCAmount.text = str(solo_NPC_amount)

func _decrease_NPC_amount():
	solo_NPC_amount -= 1
	solo_NPC_amount = clamp(solo_NPC_amount, Globals.MIN_NPC_NUMBER, Globals.MAX_NPC_NUMBER)
	$NPC/NumNPCAmount.text = str(solo_NPC_amount)

func _start_race():
	Globals.laps_number = solo_lap_amount
	Globals.NPC_number = solo_NPC_amount
	Globals.game.start_single_player_game()
