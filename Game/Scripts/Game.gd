class_name Game
extends Node

var main_menu_ = load("res://Menus/Scenes/MainMenu.tscn")
var main_menu

var single_player_manager_ = load("res://Game/Scenes/SinglePlayerManager.tscn")
var single_player_manager

func _ready():
	randomize()

	return_to_main_menu()
	
func start_single_player_game():
	main_menu.queue_free()
	
	single_player_manager = single_player_manager_.instance()
	single_player_manager.connect("return_to_main", self, "return_to_main_menu")
	add_child(single_player_manager)
	single_player_manager.setup_race(Globals.level_dict[Globals.level_dict_keys[Globals.level]])

func return_to_main_menu():
	if has_node("SinglePlayerManager"):
		get_node("SinglePlayerManager").queue_free()
		
	main_menu = main_menu_.instance()
	add_child(main_menu)
	main_menu.single_player_menu.connect("start_race", self, "start_single_player_game")
