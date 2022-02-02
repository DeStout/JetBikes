class_name Game
extends Node

onready var main_menu = $MainMenu

var online_multiplayer_manager_ = load("res://Game/MultiplayerManager/MultiplayerManager.tscn")
var online_multiplayer_manager

var level_loader_ = preload("res://Menus/LoadingMenu/LoadingMenu.tscn")

var _single_player_track = null


func _ready():
	randomize()

	main_menu.single_player_menu.connect("setup_single_player_race", self, "start_single_player_game")
	main_menu.online_menu.connect("setup_online_lobby", self, "setup_online_lobby")

	online_multiplayer_manager = online_multiplayer_manager_.instance()
	online_multiplayer_manager.connect("return_to_main", self, "return_to_main_menu")


func start_single_player_game():
#	_single_player_track = Globals.level_dict[Globals.level_dict_keys[Globals.level]].instance()

	var level_loader = level_loader_.instance()
	add_child(level_loader)
	level_loader.load_track(Globals.level_dict[Globals.level_dict_keys[Globals.level]])
	_single_player_track = yield(level_loader, "track_loaded")

	_single_player_track = _single_player_track.instance()
	add_child(_single_player_track)
	_single_player_track.connect("return_to_main", self, "return_to_main_menu")

#	yield(get_tree().create_timer(2.0), "timeout")

	remove_child(main_menu)
	remove_child(level_loader)
	level_loader.queue_free()

#	_single_player_track.begin_countdown()


func setup_online_lobby(is_host : bool):
	if online_multiplayer_manager == null:
		online_multiplayer_manager = load("res://Game/MultiplayerManager/MultiplayerManager.tscn")
		online_multiplayer_manager = online_multiplayer_manager.instance()
		online_multiplayer_manager.connect("return_to_main", self, "return_to_main_menu")

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
