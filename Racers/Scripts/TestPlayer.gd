extends Player

var _spawn_point : Transform

func _ready():
	has_control = true;
	_spawn_point = global_transform
	
func _check_out_of_bounds():
	if global_transform.origin.y < -70:
		global_transform = _spawn_point
		is_crashed = true
