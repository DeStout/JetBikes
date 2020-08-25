extends Node

var SHOW_NPC_PATHFIND : bool = false

const DEFAULT_LAP_NUMBER : int = 3
const MIN_LAP_NUMBER : int = 1
const MAX_LAP_NUMBER : int = 99

const DEFAULT_NPC_NUMBER : int = 11
const MIN_NPC_NUMBER : int = 0
const MAX_NPC_NUMBER : int = 11

const DEFAULT_SOUND_LEVEL : int = 0
const DEFAULT_MUSIC_LEVEL : int = 0
const MAX_SOUND_LEVEL : int = 0
const MAX_MUSIC_LEVEL : int = 0
const MIN_SOUND_LEVEL : int = -24
const MIN_MUSIC_LEVEL : int = -24

onready var game : Game = get_tree().get_current_scene()

onready var master_bus : int = AudioServer.get_bus_index("Master")
onready var music_bus : int = AudioServer.get_bus_index("Music")

var laps_number : int = DEFAULT_LAP_NUMBER
var NPC_number : int = DEFAULT_NPC_NUMBER

var sound_level : int = DEFAULT_SOUND_LEVEL setget _apply_master_volume
var music_level : int = DEFAULT_MUSIC_LEVEL setget _apply_music_volume
var mute_sound : bool = false
var mute_music : bool = false

func _apply_master_volume(new_volume):
	sound_level = new_volume
	AudioServer.set_bus_volume_db(master_bus, sound_level)
	if sound_level == MIN_SOUND_LEVEL:
		AudioServer.set_bus_mute(master_bus, true)
	else:
		AudioServer.set_bus_mute(master_bus, false)

func _apply_music_volume(new_volume):
	music_level = new_volume
	AudioServer.set_bus_volume_db(music_bus, music_level)
	if music_level == MIN_MUSIC_LEVEL:
		AudioServer.set_bus_mute(music_bus, true)
	else:
		AudioServer.set_bus_mute(music_bus, false)
