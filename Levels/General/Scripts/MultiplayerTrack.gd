extends Track

signal return_to_lobby


func _ready():
	Network.connect("start_timer_start", self, "begin_race")
	Network.track_ready()


func begin_race():
	$StartTimer.start()


func end_race():
	.end_race()
	emit_signal("return_to_lobby")
