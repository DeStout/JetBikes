extends Particles

func _process(delta):
	if !emitting:
		queue_free()
