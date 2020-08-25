extends ColorRect

func _optimist():
	$OptimistLabel.visible = true
	$OptimistLabel/Timer.start(0.3)
	
func _unoptimist():
	$OptimistLabel.visible = false
