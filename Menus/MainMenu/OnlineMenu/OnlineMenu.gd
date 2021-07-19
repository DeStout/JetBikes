extends Control

func _host():
	$HostJoin/JoinBox.pressed = false
	$HostJoin/HostBox.pressed = true
	$Buttons/RaceButton.disabled = false
	$Buttons/RaceButton.text = "Host"

func _join():
	$HostJoin/HostBox.pressed = false
	$HostJoin/JoinBox.pressed = true
	$Buttons/RaceButton.disabled = false
	$Buttons/RaceButton.text = "Join"

func _optimist():
	$OptimistLabel.visible = true
	$OptimistLabel/Timer.start(0.3)
	
func _unoptimist():
	$OptimistLabel.visible = false
