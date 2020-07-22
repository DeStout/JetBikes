extends RayCast

signal is_colliding

func _ready():
	connect("is_colliding", get_parent(), "_is_on_ground")
	
func _process(delta):
	if is_colliding():
		call_deferred("emit_signal", "is_colliding")
