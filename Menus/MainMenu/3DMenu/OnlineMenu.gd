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
			current_focus = host_box
		current_focus.grab_focus()
		yield(get_tree(), "idle_frame")


func _input(event: InputEvent) -> void:
	if Input.get_connected_joypads().size():
		var temp_focus : Control
		if Input.is_action_just_pressed("ui_up") or (event is InputEventJoypadMotion and \
								event.axis == JOY_AXIS_1 and event.axis_value == -1):
				temp_focus = current_focus.get_node(current_focus.focus_neighbour_top)
				if !temp_focus.focus_mode == Control.FOCUS_NONE:
					current_focus = temp_focus
				else:
					current_focus = temp_focus.get_node(temp_focus.focus_neighbour_top)
				yield(get_tree(), "idle_frame")
				current_focus.grab_focus()
		elif Input.is_action_just_pressed("ui_left") or (event is InputEventJoypadMotion and \
								event.axis == JOY_AXIS_0 and event.axis_value == -1):
				temp_focus = current_focus.get_node(current_focus.focus_neighbour_left)
				if !temp_focus.focus_mode == Control.FOCUS_NONE:
					current_focus = temp_focus
				else:
					current_focus = temp_focus.get_node(temp_focus.focus_neighbour_left)
				yield(get_tree(), "idle_frame")
				current_focus.grab_focus()
		elif Input.is_action_just_pressed("ui_right") or (event is InputEventJoypadMotion and \
								event.axis == JOY_AXIS_0 and event.axis_value == 1):
				temp_focus = current_focus.get_node(current_focus.focus_neighbour_right)
				if !temp_focus.focus_mode == Control.FOCUS_NONE:
					current_focus = temp_focus
				else:
					current_focus = temp_focus.get_node(temp_focus.focus_neighbour_right)
				yield(get_tree(), "idle_frame")
				current_focus.grab_focus()
		elif Input.is_action_just_pressed("ui_down") or (event is InputEventJoypadMotion and \
								event.axis == JOY_AXIS_1 and event.axis_value == 1):
				temp_focus = current_focus.get_node(current_focus.focus_neighbour_bottom)
				while(temp_focus.get_node(temp_focus.focus_neighbour_bottom) == null):
					pass
				if !temp_focus.focus_mode == Control.FOCUS_NONE:
					current_focus = temp_focus
				else:
					current_focus = temp_focus.get_node(temp_focus.focus_neighbour_bottom)
				yield(get_tree(), "idle_frame")
				current_focus.grab_focus()

		if event is InputEventJoypadButton:
				if Input.is_action_just_pressed("ui_accept"):
					if current_focus is Button:
						print("Accept Input - ", current_focus.name)
						current_focus.emit_signal("pressed")
					elif current_focus is LineEdit:
						print("LineEdit - ", current_focus.name)
						$IPAddress/IPText/OnscreenKeyboard.visible = true
#						current_focus = $IPAddress/IPText/OnscreenKeyboard
#						yield(get_tree(), "idle_frame")
#						current_focus.grab_focus()
				elif Input.is_action_just_pressed("ui_cancel"):
					$Buttons/BackButton.emit_signal("pressed")


func _host(toggled : bool):
	print("_host")
	join_box.pressed = false
	host_box.pressed = toggled
#	host_box.focus_mode == Control.FOCUS_ALL
	$IPAddress/IPText.text = Network.upnp.query_external_address()
	$IPAddress/IPText.editable = toggled
	is_host = true
	enabled_lobby_button(toggled)


func _join(toggled : bool):
	print("_join")
	host_box.pressed = false
	join_box.pressed = toggled
	$IPAddress/IPText.editable = true
	is_host = false
	enabled_lobby_button(toggled)


func _ip_set(new_text):
	enabled_lobby_button(host_box.pressed or join_box.pressed)

	if $IPAddress/IPText.text == "":
		$Buttons/RaceButton.disabled = true


func enabled_lobby_button(toggled : bool) -> void:
	print("enabled_lobby_button")
	if toggled:
		if $IPAddress/IPText.text != "":
			$Buttons/RaceButton.disabled = false
			$Buttons/RaceButton.focus_mode = Control.FOCUS_ALL

		if is_host:
			$Buttons/RaceButton.text = "Host"
		else:
			$Buttons/RaceButton.text = "Join"

	elif !toggled:
		$Buttons/RaceButton.disabled = true
		$Buttons/RaceButton.focus_mode = Control.FOCUS_NONE
		$Buttons/RaceButton.text = ""
		$IPAddress/IPText.editable = false


func _setup_online_lobby():
	Network.set_IP_address($IPAddress/IPText.text)
	emit_signal("setup_online_lobby", is_host)
