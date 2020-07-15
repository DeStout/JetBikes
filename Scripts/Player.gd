extends KinematicBody

const GRAVITY = 9.8
const FORWARD_ACCELERATION = 1.0
const STRIFE_ACCELERATION = 0.1
const REVERSE_ACCELERATION = 0.5
const BOOST_ACCELERATION = 1.5
const DEACCELERATION = 0.75
const BRAKE_DEACCEL = 1.5

const MAX_FORWARD_VEL = 10
const MAX_SRIFE_VEL = 1
const MAX_REVERSE_VEL =  5
const MAX_BOOST_VEL = 15
const TURN_SPEED = 8

var movement_input = Vector2.ZERO
var velocity = Vector3.ZERO

var is_boosting = false
var is_braking = false

var mouse_vert_sensitivity = 0.1
var mouse_horz_sensitivity = 0.1
var mouse_vert_invert = 1
var mouse_horz_invert = -1

onready var RotationHelper = $BasicVehicle/RotationHelper

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	move_camera(delta)

func _physics_process(delta):
	velocity.y = velocity.y - GRAVITY
	
	velocity = move_and_slide(velocity, Vector3(0,1,0))

func _input(event):
	movement_input = Vector2.ZERO
	is_boosting = false
	is_braking = false
	
	if event.is_action_pressed("Accelerate"):
		movement_input.y += 1
	if event.is_action_pressed("Strife_Left"):
		movement_input.x -= 1
	if event.is_action_pressed("Strife_Right"):
		movement_input.x += 1
	if event.is_action_pressed("Reverse"):
		movement_input.y -= 1
		
	if event.is_action_pressed("Boost"):
		is_boosting = true
	if event.is_action_pressed("Brake"):
		is_braking = true
		
	if event.is_action_pressed("Pause"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Rotate the camera based on mouse movement
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			RotationHelper.rotate_x(deg2rad(event.relative.y * mouse_vert_invert * mouse_vert_sensitivity))
			RotationHelper.rotate_y(deg2rad(event.relative.x * mouse_horz_invert * mouse_horz_sensitivity))
			
			var helper_rotation = RotationHelper.rotation_degrees
			helper_rotation.x = clamp(helper_rotation.x, -10, 10)
			helper_rotation.y = clamp(helper_rotation.y, -30, 30)
			helper_rotation.z = 0
			RotationHelper.rotation_degrees = helper_rotation

# Turn the character and correct the camera if the camera
# has been rotated	
func move_camera(var delta):
	if RotationHelper.rotation_degrees.y != 0:
		var yRot = RotationHelper.rotation_degrees.y
		yRot = yRot + (0 - yRot) * (delta * TURN_SPEED)
		RotationHelper.rotation_degrees.y = yRot
		rotate_object_local(Vector3(0, 1, 0), deg2rad(yRot * delta * TURN_SPEED))
