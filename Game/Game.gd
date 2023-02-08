class_name Game
extends Node

onready var main_menu = $MainMenu

var level_loader_ = preload("res://Menus/LoadingMenu/LoadingMenu.tscn")

var _single_player_track = null


func _ready():
	randomize()

	main_menu.single_player_menu.connect("setup_single_player_race", self, "start_single_player_game")


func start_single_player_game():
	main_menu.hide_all()

	var level_loader = level_loader_.instance()
	add_child(level_loader)
	level_loader.load_track(Globals.level_dict[Globals.level_dict_keys[Globals.level]])
	_single_player_track = yield(level_loader, "track_loaded")

	_single_player_track = _single_player_track.instance()
	add_child(_single_player_track)
	_single_player_track.connect("return_to_main", self, "return_to_main_menu")

	remove_child(main_menu)
	level_loader.queue_free()


func return_to_main_menu():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if _single_player_track != null:
		remove_child(_single_player_track)
		_single_player_track = null

	if !has_node(main_menu.name):
		add_child(main_menu)
