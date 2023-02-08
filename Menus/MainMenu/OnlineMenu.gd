extends Control


var connecting_menu_ := preload("res://Menus/OnlineMenu/ConnectingMenu.tscn")
var _connecting_menu : Control
var server_menu_ := preload("res://Menus/OnlineMenu/ServerMenu.tscn")
var _server_menu : Control

var current_focus : Control = null


func _ready() -> void:
	_connecting_menu = connecting_menu_.instance()
	_connecting_menu.connect("connected_successfully", self, "open_server_menu")

	_server_menu = server_menu_.instance()


func open_server_menu() -> void:
	remove_child(_connecting_menu)
	add_child(_server_menu)


func _hide_show() -> void:
	set_process_input(visible)
	yield(get_tree(), "idle_frame")

	if visible:
		add_child(_connecting_menu)
		if Input.get_connected_joypads().size():
			if current_focus == null:
				current_focus = $ConnectingMenu/CancelButton
			current_focus.grab_focus()
			yield(get_tree(), "idle_frame")
	else:
		remove_child(_connecting_menu)
