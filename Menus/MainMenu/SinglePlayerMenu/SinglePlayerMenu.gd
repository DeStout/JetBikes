extends Control

signal setup_single_player_race

var solo_lap_amount : int = Globals.DEFAULT_LAP_NUMBER
var solo_NPC_amount : int = Globals.DEFAULT_NPC_NUMBER
var level_select : int = Globals.DEFAULT_LEVEL

func _ready():
	$Level/LevelName.text = Globals.level_dict_keys[Globals.DEFAULT_LEVEL]
	$Laps/NumLaps.text = str(solo_lap_amount)
	$NPCs/NumNPCs.text = str(solo_NPC_amount)
	$ColorPicker.color = Globals.player_color


func _start_race():
	Globals.level = level_select
	Globals.laps_number = solo_lap_amount
	Globals.NPC_number = solo_NPC_amount
	emit_signal("setup_single_player_race")


func _select_color(new_color : Color) -> void:
	Globals.player_color = new_color


func _level_select_left():
	level_select -= 1
	if level_select < 0:
		level_select = Globals.level_dict_keys.size() - 1
	$Level/LevelName.text = Globals.level_dict_keys[level_select]


func _level_select_right():
	level_select += 1
	if level_select > Globals.level_dict_keys.size() - 1:
		level_select = 0
	$Level/LevelName.text = Globals.level_dict_keys[level_select]


func _decrease_lap_amount():
	solo_lap_amount -= 1
	if solo_lap_amount < Globals.MIN_LAP_NUMBER:
		solo_lap_amount = Globals.MAX_LAP_NUMBER
	$Laps/NumLaps.text = str(solo_lap_amount)


func _increase_lap_amount():
	solo_lap_amount += 1
	if solo_lap_amount > Globals.MAX_LAP_NUMBER:
		solo_lap_amount = Globals.MIN_LAP_NUMBER
	$Laps/NumLaps.text = str(solo_lap_amount)


func _decrease_NPC_amount():
	solo_NPC_amount -= 1
	if solo_NPC_amount < Globals.MIN_NPC_NUMBER:
		solo_NPC_amount = Globals.MAX_NPC_NUMBER
	$NPCs/NumNPCs.text = str(solo_NPC_amount)


func _increase_NPC_amount():
	solo_NPC_amount += 1
	if solo_NPC_amount > Globals.MAX_NPC_NUMBER:
		solo_NPC_amount = Globals.MIN_NPC_NUMBER
	$NPCs/NumNPCs.text = str(solo_NPC_amount)
