extends Track

signal return_to_main


func _ready():
	$StartTimer.start()

func end_race():
	.end_race()
	emit_signal("return_to_main")
