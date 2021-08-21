extends Track


func _ready():
	Network.track_ready()


remote func begin_race():
	$StartTimer.start()
