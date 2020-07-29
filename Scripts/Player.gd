class_name Player
extends KinematicBody

const GRAVITY : float = 1.5
const FORWARD_ACCELERATION : float  = 0.75
const STRIFE_ACCELERATION : float  = 0.5
const REVERSE_ACCELERATION : float  = 0.5
const BOOST_ACCELERATION : float  = 1.0
const DEACCELERATION : float  = 0.025
const BRAKE_DEACCEL : float  = 0.75
const AIR_BRAKE_DEACCEL : float  = 0.5

const MAX_FORWARD_VEL : int = 60
const MAX_STRIFE_VEL : int = 35
const MAX_REVERSE_VEL : int =  50
const MAX_BOOST_VEL : int = 80
const TURN_SPEED : int = 8

var movement_input : Vector2 = Vector2.ZERO
var velocity: Vector3 = Vector3.ZERO

var is_boosting : bool = false
var is_braking : bool = false
var is_on_ground : bool = false

var mouse_vert_sensitivity : float = 0.1
var mouse_horz_sensitivity : float  = 0.1
var mouse_vert_invert : int = 1
var mouse_horz_invert : int = -1

onready var RotationHelper : Spatial = $BasicVehicle/RotationHelper

var prev_ground_distance : float = 0

var lap_number : int = 0
var checkpoint_number : int = 0

var current_path_node : PathNode
var local_player_path : Vector3
var path_node_point : Vector3
var path_node_distance : float

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	current_path_node = get_parent().get_parent().get_node("Navigation/PathNodes/PathNode0")

func _process(delta : float) -> void:
	_get_key_input()
	_move_camera(delta)
	
	_path_node_distance()

func _physics_process(delta : float) -> void:
	var move_direction : Vector3 = Vector3()
	var player_basis : Basis = global_transform.basis
	var temp_velocity : Vector3 = velocity
	temp_velocity.y = 0
	
	if is_on_ground:
		var ground_normal : Vector3 = _get_ground_normal()
		
		# Align player Y vector to ground normal
		if player_basis[1].dot(ground_normal) > 0:
			global_transform.basis = player_basis.slerp(_align_to_normal(ground_normal), delta*4)
		
		# Apply acceleration/deacceleration along player X vector based on input
		if !is_braking:
			if movement_input.x != 0:
				var delta_move : Vector3 = player_basis[0] * movement_input.x * STRIFE_ACCELERATION
				var strife_vel : Vector3 = player_basis[0].dot(temp_velocity) * temp_velocity.normalized()
				if abs((strife_vel + delta_move).length()) < MAX_STRIFE_VEL:
					move_direction += delta_move
			else:
				move_direction -= player_basis[0].dot(temp_velocity) * player_basis[0].normalized() * DEACCELERATION
				
			# Apply acceleration/deacceleration along player Z vector based on input
			if movement_input.y > 0:
				if !is_boosting:
					var delta_move : Vector3 = player_basis[2] * -movement_input.y * FORWARD_ACCELERATION
					var forward_vel : Vector3 = player_basis[2].dot(temp_velocity) * temp_velocity.normalized()
					if abs((forward_vel + delta_move).length()) < MAX_FORWARD_VEL:
						move_direction += delta_move
				else:
					var delta_move : Vector3 = player_basis[2] * -movement_input.y * BOOST_ACCELERATION
					var boost_vel : Vector3 = player_basis[2].dot(temp_velocity) * temp_velocity.normalized()
					if abs((boost_vel + delta_move).length()) < MAX_BOOST_VEL:
						move_direction += delta_move
			elif movement_input.y < 0:
				var delta_move : Vector3 = player_basis[2] * -movement_input.y * REVERSE_ACCELERATION
				var reverse_vel : Vector3 = player_basis[2].dot(temp_velocity) * temp_velocity.normalized()
				if abs((reverse_vel + delta_move).length()) < MAX_REVERSE_VEL:
					move_direction += delta_move
			else:
				move_direction -= player_basis[2].dot(temp_velocity) * player_basis[2] * DEACCELERATION
		
		# Hover along surface normal and slide downhill
		var downhill : Vector3 = Vector3(0, -1, 0).cross(ground_normal).cross(ground_normal)
		var cast_point : Vector3 = _get_cast_point()
		var ground_point : Vector3 = _get_ground_point()
		
		var ground_distance : float = clamp(cast_point.length() - ground_point.length(), \
			($GroundDetect1.cast_to.length() - 0.1) * -0.499, \
			($GroundDetect1.cast_to.length() - 0.1) * 0.499)
		var prev_move_distance : float = ground_distance - prev_ground_distance
		if ground_distance == 0:
			ground_distance = 0.001
		if prev_move_distance == 0:
			prev_move_distance = 0.001
		var move_force : float = 1 / (ground_distance / (prev_move_distance)) - ground_distance
		move_force = clamp(move_force, -11, 11)
		
		move_direction += ground_normal * move_force * 1.1
		move_direction += downhill * -GRAVITY * 0.25
		
		prev_ground_distance = ground_distance
		
	else:
		global_transform.basis = player_basis.slerp(_align_to_normal(Vector3(0, 1, 0)), delta*2)
		prev_ground_distance = 0
		move_direction = Vector3(0, -GRAVITY, 0)
	
	velocity += move_direction
	
	if is_braking:
		if is_on_ground:
			velocity.x = _interpolate_float(velocity.x, 0, BRAKE_DEACCEL)
			velocity.z = _interpolate_float(velocity.z, 0, BRAKE_DEACCEL)
		else:
			velocity.x = _interpolate_float(velocity.x, 0, AIR_BRAKE_DEACCEL)
			velocity.z = _interpolate_float(velocity.z, 0, AIR_BRAKE_DEACCEL)
		
	velocity = move_and_slide(velocity, Vector3(0,1,0))
	
	is_on_ground = false

# Track what keyboard input is being pressed
func _get_key_input() -> void:
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

func _input(event) -> void:		
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
			
			var helper_rotation : Vector3 = RotationHelper.rotation_degrees
			helper_rotation.x = clamp(helper_rotation.x, -10, 10)
			helper_rotation.y = clamp(helper_rotation.y, -30, 30)
			helper_rotation.z = 0
			RotationHelper.rotation_degrees = helper_rotation

# Turn the character and correct the camera if the camera has been rotated	
func _move_camera(var delta : float) -> void:
	if RotationHelper.rotation_degrees.y != 0:
		var yRot : float = RotationHelper.rotation_degrees.y
		yRot = yRot + (0 - yRot) * (delta * TURN_SPEED)
		RotationHelper.rotation_degrees.y = yRot
		rotate_object_local(Vector3(0, 1, 0), deg2rad(yRot * delta * TURN_SPEED))

# Helper function to align player with the ground normal
func _align_to_normal(ground_normal : Vector3) -> Basis:
	var result : Basis = Basis()
	result.x = ground_normal.cross(global_transform.basis.z)
	result.y = ground_normal
	result.z = global_transform.basis.x.cross(ground_normal)
	return result.orthonormalized()

# Called by signal if $GroundDetects are colliding
func _is_on_ground() -> void:
	if !is_on_ground:
		is_on_ground = true
	
# Return the average vector of the normals of the surface the $GroundDetects are colliding with
func _get_ground_normal() -> Vector3:
	var ground_normal1 : Vector3 = $GroundDetect1.get_collision_normal()
	var ground_normal2 : Vector3 = $GroundDetect2.get_collision_normal()
	return (ground_normal1 + ground_normal2) * 0.5

# Average the collision point of the $GroundDetects and return the local coordinates
func _get_ground_point() -> Vector3:
	var ground_point1 : Vector3 = $GroundDetect1.get_collision_point()
	var ground_point2 : Vector3 = $GroundDetect2.get_collision_point()
	
	return to_local((ground_point1 + ground_point2) * 0.5)

# Average and return center points of the $GroundCollisions
func _get_cast_point() -> Vector3:
	var cast_point1 = $GroundDetect1.transform.origin
	var cast_point2 = $GroundDetect2.transform.origin
	
	return (cast_point1 + cast_point2) * 0.5 - Vector3(0, 1.1, 0)
	
func checkpoint_reached(new_checkpoint : Checkpoint):
	if checkpoint_number == new_checkpoint.serial:
		if new_checkpoint.serial == 0:
			lap_number += 1
			print("Lap: " + str(lap_number))
		print("Checkpoint: " + str(checkpoint_number) + "\n")
		checkpoint_number = new_checkpoint.next_serial
		
func _path_node_distance():
	local_player_path = global_transform.origin - current_path_node.center_point
	path_node_point = current_path_node.path.curve.get_closest_point(local_player_path)
	path_node_distance = path_node_point.distance_to(local_player_path)
	if path_node_distance < 15:
		if current_path_node.serial == 0:
			lap_number += 1
			$Control/LapLabel.text = ("Lap: " + str(lap_number))
		current_path_node = get_parent().get_parent().get_node("Navigation/PathNodes/PathNode" + str(current_path_node.next_serial))
		print("Player: " + current_path_node.name)

func _interpolate_float(current: float, target: float, amount: float) -> float:
	current += amount * sign(target - current)
	if abs(target - current) <= abs(amount):
		current = target
	return current
