extends Particles

var time_added : int


func _ready():
	time_added = OS.get_ticks_msec()

func _process(delta):
	if !emitting:
		queue_free()
