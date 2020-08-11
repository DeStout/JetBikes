extends RayCast

signal is_colliding

func _ready():
	connect("is_colliding", get_parent(), "_is_on_ground")
	
func _process(delta):
	if is_colliding():
		emit_signal("is_colliding")


func _on_GroundDetect1_visibility_changed():
	pass # Replace with function body.
