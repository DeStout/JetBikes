extends Particles

var time_added : int


func _ready():
	time_added = OS.get_ticks_msec()

func _process(_delta):
	if !emitting:
		queue_free()
