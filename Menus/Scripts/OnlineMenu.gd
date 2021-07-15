extends ColorRect

func _host():
	$HostOptions/JoinBox.pressed = false
	$HostOptions/HostBox.pressed = true
	$Buttons/RaceButton.disabled = false
	$Buttons/RaceButton.text = "Host"

func _join():
	$HostOptions/HostBox.pressed = false
	$HostOptions/JoinBox.pressed = true
	$Buttons/RaceButton.disabled = false
	$Buttons/RaceButton.text = "Join"

func _optimist():
	$OptimistLabel.visible = true
	$OptimistLabel/Timer.start(0.3)
	
func _unoptimist():
	$OptimistLabel.visible = false
