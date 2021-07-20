extends Player

var _spawn_point : Transform

func _ready():
	has_control = true
	HUD.get_node("Arrow").visible = false
	_spawn_point = global_transform

func _process(delta):
	_set_boost(50 * delta)
	
func _check_out_of_bounds():
	if global_transform.origin.y < -70:
		velocity = Vector3.ZERO
		global_transform = _spawn_point
		global_transform.basis.y = Vector3.UP
		is_crashed = true

func _crash():
	is_crashed = false
