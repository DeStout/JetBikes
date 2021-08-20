extends Node


var SHOW_NPC_PATHFIND : bool = false
var INFINITE_BOOST : bool = true

var test_track_ : PackedScene = load("res://Levels/TestTrack/TestTrack.tscn")
var test_terrain_ : PackedScene = load("res://Levels/TestTerrain/TestTerrain.tscn")
#var test_terrain2_ : PackedScene = load("res://Levels/TestTerrain2/TestTerrain2.tscn")
#var test_terrain3_ : PackedScene = load("res://Levels/TestTerrain3/TestTerrain3.tscn")
#var new_canyon_ : PackedScene = load("res://Levels/NewCanyon/NewCanyon.tscn")
var level_dict : Dictionary = {
	"test_track" : test_track_,
	"test_terrain" : test_terrain_,
#	"test_terrain2" : test_terrain2_,
#	"test_terrain3" : test_terrain3_
#	,"new_canyon" : new_canyon_
	}
var level_dict_keys : Array = level_dict.keys()
var DEFAULT_LEVEL = 1

const DEFAULT_LAP_NUMBER : int = 3
const MIN_LAP_NUMBER : int = 1
const MAX_LAP_NUMBER : int = 99

const DEFAULT_NPC_NUMBER : int = 11
const MIN_NPC_NUMBER : int = 0
const MAX_NPC_NUMBER : int = 11

const DEFAULT_SFX_LEVEL : int = -20
#const DEFAULT_SFX_LEVEL : int = -48
#const DEFAULT_MUSIC_LEVEL : int = -30
const DEFAULT_MUSIC_LEVEL : int = -48
const MIN_SFX_LEVEL : int = -48
const MAX_SFX_LEVEL : int = -12
const MIN_MUSIC_LEVEL : int = -48
const MAX_MUSIC_LEVEL : int = -12

onready var master_bus : int = AudioServer.get_bus_index("Master")
onready var music_bus : int = AudioServer.get_bus_index("Music")
onready var sfx_bus : int = AudioServer.get_bus_index("SFX")
onready var player_bus : int = AudioServer.get_bus_index("Player_SFX")
onready var npc_bus : int = AudioServer.get_bus_index("NPC_SFX")
onready var level_bus : int = AudioServer.get_bus_index("Level_SFX")

const GRAVITY = 2.5

var level : int = -1
var laps_number : int = DEFAULT_LAP_NUMBER
var NPC_number : int = DEFAULT_NPC_NUMBER
var race_on_going : bool = false

var sfx_level : float = DEFAULT_SFX_LEVEL setget _apply_sfx_volume
var music_level : float = DEFAULT_MUSIC_LEVEL setget _apply_music_volume
var mute_sound : bool = false
var mute_music : bool = false

var player_color : Color = Color("#2fc9ff")


func _ready():
	_apply_sfx_volume(DEFAULT_SFX_LEVEL)
	_apply_music_volume(DEFAULT_MUSIC_LEVEL)


func _apply_sfx_volume(new_volume):
	sfx_level = new_volume
	AudioServer.set_bus_volume_db(sfx_bus, sfx_level)
	if sfx_level == MIN_SFX_LEVEL:
		AudioServer.set_bus_mute(sfx_bus, true)
	else:
		AudioServer.set_bus_mute(sfx_bus, false)


func _apply_music_volume(new_volume):
	music_level = new_volume
	AudioServer.set_bus_volume_db(music_bus, music_level)
	if music_level == MIN_MUSIC_LEVEL:
		AudioServer.set_bus_mute(music_bus, true)
	else:
		AudioServer.set_bus_mute(music_bus, false)
