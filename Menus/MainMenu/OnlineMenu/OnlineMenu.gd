extends Control

signal setup_online_lobby

onready var host_box = $HostJoin/HostBox
onready var join_box = $HostJoin/JoinBox

var is_host = false


func _host():
	$HostJoin/JoinBox.pressed = false
	$HostJoin/HostBox.pressed = true
	if not OS.is_debug_build():
		$IPAdress/IPText.text = Network.upnp.query_external_address()
	is_host = true
	enabled_lobby_button()


func _join():
	$HostJoin/HostBox.pressed = false
	$HostJoin/JoinBox.pressed = true
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
