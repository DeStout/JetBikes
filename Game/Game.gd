class_name Game
extends Node

onready var main_menu = $MainMenu

var single_player_manager_ = load("res://Game/SinglePlayerManager/SinglePlayerManager.tscn")
var single_player_manager
var online_multiplayer_manager_ = load("res://Game/OnlineMultiplayerManager/OnlineMultiplayerManager.tscn")
var online_multiplayer_manager

func _ready():
	randomize()
	
	main_menu.single_player_menu.connect("setup_single_player_race", self, "start_single_player_game")
	main_menu.online_menu.connect("setup_online_lobby", self, "setup_online_lobby")
	
	single_player_manager = single_player_manager_.instance()
	single_player_manager.connect("return_to_main", self, "return_to_main_menu")
	online_multiplayer_manager = online_multiplayer_manager_.instance()
	online_multiplayer_manager.connect("return_to_main", self, "return_to_main_menu")
	
func start_single_player_game():
	remove_child(main_menu)
	
	add_child(single_player_manager)
	single_player_manager.setup_race(Globals.level_dict[Globals.level_dict_keys[Globals.level]])

func setup_online_lobby(is_host : bool):
	remove_child(main_menu)
	
	add_child(online_multiplayer_manager)
	online_multiplayer_manager.setup_lobby(is_host)

func return_to_main_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if has_node(single_player_manager.name):
		remove_child(single_player_manager)
#		get_node("SinglePlayerManager").queue_free()
	if has_node(online_multiplayer_manager.name):
		remove_child(online_multiplayer_manager)
#		get_node("OnlineMultiplayerManager").queue_free()

	add_child(main_menu)
