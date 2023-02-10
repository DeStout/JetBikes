extends Control


var connecting_menu_ := preload("res://Menus/OnlineMenu/ConnectingMenu.tscn")
var _connecting_menu : Control
var server_menu_ := preload("res://Menus/OnlineMenu/ServerMenu.tscn")
var _server_menu : Control

var host_menu_ := preload("res://Menus/OnlineMenu/LobbyMenus/HostLobby.tscn")
var _host_menu : Control
var client_menu_ := preload("res://Menus/OnlineMenu/LobbyMenus/ClientLobby.tscn")
var _client_menu : Control


func _add_connecting_menu() -> void:
	_connecting_menu = connecting_menu_.instance()
	add_child(_connecting_menu)
	_connecting_menu.connect("connected_successfully", self, "add_server_menu")


func add_server_menu() -> void:
	if get_children().has(_connecting_menu):
		_connecting_menu.queue_free()
	_server_menu = server_menu_.instance()
	add_child(_server_menu)

	_server_menu.connect("create_new_lobby", self, "add_host_lobby")
#	_server_menu.connect("lobby_joined", self, "add_client_lobby")


func add_host_lobby(new_lobby_name) -> void:
	if get_children().has(_server_menu):
		_server_menu.queue_free()
	_host_menu = host_menu_.instance()
	add_child(_host_menu)
	_host_menu.set_lobby_name(new_lobby_name)


func add_client_lobby() -> void:
	pass


func _hide_show() -> void:
	set_process_input(visible)
	yield(get_tree(), "idle_frame")

	if visible:
		_add_connecting_menu()

#		TODO: Move below to ConnectingMenu/ServerMenu
#		if Input.get_connected_joypads().size():
#			if current_focus == null:
#				current_focus = $ConnectingMenu/CancelButton
#			current_focus.grab_focus()
#			yield(get_tree(), "idle_frame")

	else:
		if get_children().has(_connecting_menu):
			_connecting_menu.queue_free()
		elif get_children().has(_server_menu):
			_server_menu.queue_free()
