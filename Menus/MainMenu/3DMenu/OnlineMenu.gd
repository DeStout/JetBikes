extends Control

signal setup_online_lobby

onready var host_box = $HostJoin/HostBox
onready var join_box = $HostJoin/JoinBox

var is_host = false

var current_focus : Control = null


func _ready():
	set_process_input(false)


func _hide_show() -> void:
	set_process_input(visible)
	yield(get_tree(), "idle_frame")

	if Input.get_connected_joypads().size():
		if current_focus == null:
			current_focus = $HostJoin/HostBox
		current_focus.grab_focus()
		yield(get_tree(), "idle_frame")


func _input(event: InputEvent) -> void:
	if Input.get_connected_joypads().size():
		if event.is_action_pressed("ui_up") or (event is InputEventJoypadMotion and \
								event.axis == JOY_AXIS_1 and event.axis_value == -1):
				current_focus = current_focus.get_node(current_focus.focus_neighbour_top)
				yield(get_tree(), "idle_frame")
		elif event.is_action_pressed("ui_left") or (event is InputEventJoypadMotion and \
								event.axis == JOY_AXIS_0 and event.axis_value == -1):
				current_focus = current_focus.get_node(current_focus.focus_neighbour_left)
				yield(get_tree(), "idle_frame")
		elif event.is_action_pressed("ui_right") or (event is InputEventJoypadMotion and \
								event.axis == JOY_AXIS_0 and event.axis_value == 1):
				current_focus = current_focus.get_node(current_focus.focus_neighbour_right)
				yield(get_tree(), "idle_frame")
		elif event.is_action_pressed("ui_down") or (event is InputEventJoypadMotion and \
								event.axis == JOY_AXIS_1 and event.axis_value == 1):
				current_focus = current_focus.get_node(current_focus.focus_neighbour_bottom)
				yield(get_tree(), "idle_frame")
		current_focus.grab_focus()
		print(current_focus.name)

	if event is InputEventJoypadButton:
			if Input.is_action_just_pressed("ui_accept"):
				if current_focus is Button:
					print(current_focus.name)
					current_focus.emit_signal("button_down")
				elif current_focus is LineEdit:
					print(current_focus.name)
					$IPAdress/IPText/OnscreenKeyboard.visible = true
					current_focus = $IPAdress/IPText/OnscreenKeyboard
					yield(get_tree(), "idle_frame")
					current_focus.grab_focus()
			elif event.is_action_pressed("ui_cancel"):
				$Buttons/BackButton.emit_signal("pressed")


func _host():
	print("Host")
	$HostJoin/JoinBox.pressed = false
	$HostJoin/HostBox.pressed = true
	$IPAdress/IPText.text = Network.upnp.query_external_address()
	$IPAdress/IPText.editable = false
	is_host = true
	enabled_lobby_button()


func _join():
	print("Join")
	$HostJoin/HostBox.pressed = false
	$HostJoin/JoinBox.pressed = true
	$IPAdress/IPText.editable = true
	is_host = false
	enabled_lobby_button()


func _ip_set(new_text):
	enabled_lobby_button()


func enabled_lobby_button() -> void:
	if (host_box.pressed or join_box.pressed) and $IPAdress/IPText.text != "":
		$Buttons/RaceButton.disabled = false
		if is_host:
			$Buttons/RaceButton.text = "Host"
		else:
			$Buttons/RaceButton.text = "Join"


func _setup_online_lobby():
	Network.set_IP_address($IPAdress/IPText.text)
	emit_signal("setup_online_lobby", is_host)
