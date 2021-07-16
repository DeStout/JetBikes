extends RayCast

signal is_colliding

export(String, "Ground", "Side") var type
	
func _process(delta):
	if is_colliding():
		emit_signal("is_colliding", self)
