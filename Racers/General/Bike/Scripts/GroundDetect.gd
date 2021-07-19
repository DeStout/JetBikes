extends RayCast

signal is_colliding
	
func _process(delta):
	if is_colliding():
		emit_signal("is_colliding")
