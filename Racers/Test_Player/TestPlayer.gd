extends Player

var _spawn_point : Transform

func _ready():
	if Globals.level == -1:
		pause_menu.connect("end_race", get_tree(), "quit")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	HUD.get_node("Arrow").visible = false
	_spawn_point = global_transform
	
	start_race()

func _process(delta):
	_set_boost(75 * delta)
	
func _check_out_of_bounds():
	if global_transform.origin.y < -70:
		velocity = Vector3.ZERO
		global_transform = _spawn_point
		global_transform.basis.y = Vector3.UP
		is_crashed = true

func _crash():
	is_crashed = false
