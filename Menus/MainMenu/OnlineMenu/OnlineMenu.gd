extends Control

signal setup_online_lobby

var is_host = false


func _host():
	$HostJoin/JoinBox.pressed = false
	$HostJoin/HostBox.pressed = true
	$Buttons/RaceButton.disabled = false
	$Buttons/RaceButton.text = "Host"
	is_host = true


func _join():
	$HostJoin/HostBox.pressed = false
	$HostJoin/JoinBox.pressed = true
	$Buttons/RaceButton.disabled = false
	$Buttons/RaceButton.text = "Join"
	is_host = false


func _setup_online_lobby():
	Network.IP_address = $IPAdress/IPText.text
	emit_signal("setup_online_lobby", is_host)
