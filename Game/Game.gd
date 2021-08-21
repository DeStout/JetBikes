class_name Game
extends Node

onready var main_menu = $MainMenu

#var single_player_manager_ = preload("res://Game/SinglePlayerManager/SinglePlayerManager.tscn")
#var single_player_manager
var online_multiplayer_manager_ = preload("res://Game/OnlineMultiplayerManager/OnlineMultiplayerManager.tscn")
var online_multiplayer_manager

var _single_player_track : Track = null


func _ready():
	randomize()
	
	main_menu.single_player_menu.connect("setup_single_player_race", self, "start_single_player_game")
	main_menu.online_menu.connect("setup_online_lobby", self, "setup_online_lobby")
	
#	single_player_manager = single_player_manager_.instance()
#	single_player_manager.connect("return_to_main", self, "return_to_main_menu")
	online_multiplayer_manager = online_multiplayer_manager_.instance()
	online_multiplayer_manager.connect("return_to_main", self, "return_to_main_menu")
	
	
func start_single_player_game():
	_single_player_track = Globals.level_dict[Globals.level_dict_keys[Globals.level]].instance()
	_single_player_track.connect("return_to_main", self, "return_to_main_menu")
	
	remove_child(main_menu)
	add_child(_single_player_track)


func setup_online_lobby(is_host : bool):
	remove_child(main_menu)
	
	add_child(online_multiplayer_manager)
	online_multiplayer_manager.setup_lobby_network(is_host)


func return_to_main_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if _single_player_track != null:
		remove_child(_single_player_track)
		_single_player_track = null
		
	if has_node(online_multiplayer_manager.name):
		remove_child(online_multiplayer_manager)

	add_child(main_menu)
