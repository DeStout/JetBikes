extends KinematicBody

const GRAVITY = 1.5
const FORWARD_ACCELERATION = 0.5
const STRIFE_ACCELERATION = 0.3
const REVERSE_ACCELERATION = 0.3
const BOOST_ACCELERATION = 0.75
const DEACCELERATION = 0.025
const BRAKE_DEACCEL = 0.5

const MAX_FORWARD_VEL = 50
const MAX_STRIFE_VEL = 25
const MAX_REVERSE_VEL =  35
const MAX_BOOST_VEL = 75
const TURN_SPEED = 8

var movement_input = Vector2.ZERO
var velocity = Vector3.ZERO

var is_boosting = false
var is_braking = false
var is_on_ground = false

var mouse_vert_sensitivity = 0.1
var mouse_horz_sensitivity = 0.1
var mouse_vert_invert = 1
var mouse_horz_invert = -1

onready var RotationHelper = $BasicVehicle/RotationHelper

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	_get_key_input()
	_move_camera(delta)

func _physics_process(delta):
	var move_direction = Vector3()
	var player_basis = global_transform.basis
	var temp_velocity = velocity
	temp_velocity.y = 0
	
	if is_on_ground:
		var ground_normal = _get_ground_normal()
		
		# Align player Y vector to ground normal
		if player_basis[1].dot(ground_normal) > 0:
			global_transform.basis = player_basis.slerp(_align_to_normal(ground_normal), delta*3)
		
		# Apply acceleration/deacceleration along player X vector based on input
		if movement_input.x != 0:
			var delta_move = player_basis[0] * movement_input.x * STRIFE_ACCELERATION
			var strife_vel = player_basis[0].dot(temp_velocity) * temp_velocity.normalized()
			if abs((strife_vel + delta_move).length()) < MAX_STRIFE_VEL:
				move_direction += delta_move
		else:
			move_direction -= player_basis[0].dot(temp_velocity) * player_basis[0].normalized() * DEACCELERATION
			
		# Apply acceleration/deacceleration along player Z vector based on input
		if movement_input.y > 0:
			if !is_boosting:
				var delta_move = player_basis[2] * -movement_input.y * FORWARD_ACCELERATION
				var forward_vel = player_basis[2].dot(temp_velocity) * temp_velocity.normalized()
				if abs((forward_vel + delta_move).length()) < MAX_FORWARD_VEL:
					move_direction += delta_move
			else:
				var delta_move = player_basis[2] * -movement_input.y * BOOST_ACCELERATION
				var boost_vel = player_basis[2].dot(temp_velocity) * temp_velocity.normalized()
				if abs((boost_vel + delta_move).length()) < MAX_BOOST_VEL:
					move_direction += delta_move
		elif movement_input.y < 0:
			var delta_move = player_basis[2] * -movement_input.y * REVERSE_ACCELERATION
			var reverse_vel = player_basis[2].dot(temp_velocity) * temp_velocity.normalized()
			if abs((reverse_vel + delta_move).length()) < MAX_REVERSE_VEL:
				move_direction += delta_move
		else:
			move_direction -= player_basis[2].dot(temp_velocity) * player_basis[2] * DEACCELERATION
	else:
		global_transform.basis = player_basis.slerp(_align_to_normal(Vector3(0, 1, 0)), delta*5)
		move_direction = Vector3.ZERO
	
	velocity.y -=  GRAVITY
	velocity += move_direction
	
	if is_on_ground:
		velocity.y += GRAVITY
	
	velocity = move_and_slide(velocity, Vector3(0,1,0))
	
	is_on_ground = false

# Track what keyboard input is being pressed
func _get_key_input():
	movement_input = Vector2.ZERO
	is_boosting = false
	is_braking = false
	
	if Input.is_action_pressed("Accelerate"):
		movement_input.y += 1
	if Input.is_action_pressed("Strife_Left"):
		movement_input.x -= 1
	if Input.is_action_pressed("Strife_Right"):
		movement_input.x += 1
	if Input.is_action_pressed("Reverse"):
		movement_input.y -= 1
		
	if Input.is_action_pressed("Boost"):
		is_boosting = true
	if Input.is_action_pressed("Brake"):
		is_braking = true

func _input(event):		
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

# Turn the character and correct the camera if the camera has been rotated	
func _move_camera(var delta):
	if RotationHelper.rotation_degrees.y != 0:
		var yRot = RotationHelper.rotation_degrees.y
		yRot = yRot + (0 - yRot) * (delta * TURN_SPEED)
		RotationHelper.rotation_degrees.y = yRot
		rotate_object_local(Vector3(0, 1, 0), deg2rad(yRot * delta * TURN_SPEED))

# Helper function to align player with the ground normal
func _align_to_normal(ground_normal):
	var result = Basis()
	result.x = ground_normal.cross(global_transform.basis.z)
	result.y = ground_normal
	result.z = global_transform.basis.x.cross(ground_normal)
	return result.orthonormalized()

# Called by signal if $GroundDetects are colliding
func _is_on_ground():
	is_on_ground = true
	
# Return the average vector of the normals of the surface the $GroundDetects are colliding with
func _get_ground_normal():
	var ground_normal1 = $GroundDetect1.get_collision_normal()
	var ground_normal2 = $GroundDetect2.get_collision_normal()
	return (ground_normal1 + ground_normal2) * 0.5
