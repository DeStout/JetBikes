class_name Game
extends Node

var main_menu_ = load("res://Scenes/MainMenu.tscn")
var main_menu

var test_track_ = load("res://Scenes/TestTrack.tscn")

onready var single_player_manager = $SinglePlayerManager

func _ready():
	return_to_main_menu()
	
func start_single_player_game():
	main_menu.queue_free()
	single_player_manager.setup_race(test_track_.instance())

func return_to_main_menu():
	main_menu = main_menu_.instance()
	add_child(main_menu)
