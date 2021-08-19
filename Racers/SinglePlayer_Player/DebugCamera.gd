extends Camera

var default_cam_transform : Transform

var input_map = Vector3.ZERO
var velocity = .15

var vert_invert = -1
var horz_invert = -1
var vert_mouse_sensitivity = .01
var horz_mouse_sensitivity = .00


func _ready():
	default_cam_transform = transform
	
	
func _process(delta):
	if current:
		get_key_input()
		var _delta = Vector3.ZERO
		_delta += input_map.z * velocity * global_transform.basis.z
		_delta += input_map.x * velocity * global_transform.basis.x
		_delta += input_map.y * velocity * global_transform.basis.y
		global_transform.origin += _delta


func _input(event):
	if current:
		if event is InputEventMouseMotion:
			rotate_object_local(Vector3(1,0,0), event.relative.y * vert_mouse_sensitivity * vert_invert)
			rotate_y(event.relative.x * horz_mouse_sensitivity * horz_invert)
			rotation.x = clamp(rotation.x, -0.45*PI, 0.45*PI)
			rotation.z = 0
	
	if event.is_action_pressed("esc"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_tree().set_input_as_handled()


func get_key_input():
	input_map = Vector3.ZERO
	if Input.is_action_pressed("forward"):
		input_map.z -= 1
	if Input.is_action_pressed("backward"):
		input_map.z += 1
	if Input.is_action_pressed("left"):
		input_map.x -= 1
	if Input.is_action_pressed("right"):
		input_map.x += 1
	if Input.is_action_pressed("up"):
		input_map.y += 1
	if Input.is_action_pressed("down"):
		input_map.y -= 1
	input_map = input_map.normalized()
