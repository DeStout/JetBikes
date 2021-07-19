extends KinematicBody

const GRAVITY : float = 2.5
const FORWARD_ACCELERATION : float  = 1.05
#const FORWARD_ACCELERATION : float  = 50.0
const STRIFE_ACCELERATION : float  = 0.65
const REVERSE_ACCELERATION : float  = 0.65
const BOOST_ACCELERATION : float  = 1.1
const DEACCELERATION : float  = 0.025
const BRAKE_DEACCEL : float  = 1.5
const AIR_BRAKE_DEACCEL : float  = 0.5

const MAX_SPEED : int = 180
const MAX_BOOST : int = 250
const MAX_FORWARD_VEL : int = 90
#const MAX_FORWARD_VEL : int = 9000
const MAX_STRIFE_VEL : int = 50
const MAX_REVERSE_VEL : int =  75
const MAX_BOOST_VEL : int = 120
const TURN_SPEED : int = 6

const MIN_SFX_PITCH : float = 1.5
const MAX_SFX_PITCH : float = 4.0

const MIN_CAM_FOV : float = 45.0
const MAX_CAM_FOV : float = 65.0
const MIN_CAM_DIST : float = 7.0
const MAX_CAM_DIST : float = 15.0

var movement_input : Vector2 = Vector2.ZERO
var velocity : Vector3 = Vector3.ZERO
var prev_velocity : Vector3 = Vector3.ZERO
var boost : float = 125
#var boost_cost : float = -1.5
var boost_cost : float = 0

var sfx_pitch : float = MIN_SFX_PITCH

var has_control : bool = false
var is_boosting : bool = false
var is_braking : bool = true
var is_on_ground : bool = false

var mouse_vert_sensitivity : float = 0.1
var mouse_horz_sensitivity : float  = 0.1
var mouse_vert_invert : int = 1
var mouse_horz_invert : int = -1

onready var HUD : Control = $RotationHelper/Camera/HUD
onready var camera : Camera = $RotationHelper/Camera
onready var RotationHelper : Spatial = $RotationHelper

var ground_point : Vector3
var prev_ground_distance : float = 0

var player_respawn : Transform

func _ready():
	player_respawn = global_transform
	has_control = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	HUD.get_node("Arrow").visible = false

func _process(delta : float) -> void:
	_get_key_input()
	_rotate_default(delta)
	_adjust_cam_fov_dist()
	_pitch_sfx()
	_emit_trail_particles()

func _physics_process(delta : float) -> void:
	_check_out_of_bounds()
	_check_crash()
		
	var move_direction : Vector3 = Vector3()
	var player_basis : Basis = global_transform.basis
	var temp_velocity : Vector3 = velocity
	temp_velocity.y = 0
	
	if is_on_ground:
		var ground_normal : Vector3 = _get_ground_normal()
		
		# Align player Y vector to ground normal
		if player_basis[1].dot(ground_normal) > 0:
			global_transform.basis = player_basis.slerp(_align_to_normal(ground_normal), delta*4).orthonormalized()
		
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
				if is_boosting and boost > 0:
					var delta_move : Vector3 = player_basis[2] * -movement_input.y * BOOST_ACCELERATION
					var boost_vel : Vector3 = player_basis[2].dot(temp_velocity) * temp_velocity.normalized()
					if abs((boost_vel + delta_move).length()) < MAX_BOOST_VEL:
						move_direction += delta_move
					_set_boost(boost_cost)
				else:
					var delta_move : Vector3 = player_basis[2] * -movement_input.y * FORWARD_ACCELERATION
					var forward_vel : Vector3 = player_basis[2].dot(temp_velocity) * temp_velocity.normalized()
					if abs((forward_vel + delta_move).length()) < MAX_FORWARD_VEL:
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
		ground_point = _get_ground_point()
		
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
		move_direction += downhill * -GRAVITY * 0.1
		
		prev_ground_distance = ground_distance
		
	# Realign UP if not on the ground
	else:
		global_transform.basis = player_basis.slerp(_align_to_normal(Vector3(0, 1, 0)), delta*2).orthonormalized()
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
	
	prev_velocity = velocity
	velocity = move_and_slide(velocity, Vector3(0,1,0))
	_set_speedometer()
	
#	if get_slide_count() > 0:
#		for i in get_slide_count():
#			if get_slide_collision(i).collider.is_class("NPC"):
#				print("crash!")
	
	is_on_ground = false

# Track what keyboard input is being pressed
func _get_key_input() -> void:
	movement_input = Vector2.ZERO
	is_boosting = false
	if has_control:
		is_braking = false
	if has_control:
		if Input.is_action_pressed("Accelerate"):
			movement_input.y += 1
		if Input.is_action_pressed("Strife_Left"):
			movement_input.x -= 1
		if Input.is_action_pressed("Strife_Right"):
			movement_input.x += 1
		if Input.is_action_pressed("Reverse"):
			movement_input.y -= 1
			
		if Input.is_action_pressed("Brake"):
			is_braking = true
		else:
			if Input.is_action_pressed("Boost"):
				is_boosting = true

func _input(event):
	# Rotate the camera based on mouse movement
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			RotationHelper.rotate_x(-deg2rad(event.relative.y * mouse_vert_invert * mouse_vert_sensitivity))
			RotationHelper.rotate_y(deg2rad(event.relative.x * mouse_horz_invert * mouse_horz_sensitivity))
			
			var helper_rotation : Vector3 = RotationHelper.rotation_degrees
			helper_rotation.x = clamp(helper_rotation.x, -10, 10)
			helper_rotation.y = clamp(helper_rotation.y, -30, 30)
			helper_rotation.z = 0
			RotationHelper.rotation_degrees = helper_rotation
			
			var velocity_ratio = clamp(velocity.length() / MAX_FORWARD_VEL, 0.0, 1.0)
			$Vehicle1.rotate_object_local(Vector3(0, 0, 1), -deg2rad(helper_rotation.y * 0.08 * velocity_ratio))
			var vehicle_rotation : Vector3 = $Vehicle1.rotation_degrees
			vehicle_rotation.z = clamp(vehicle_rotation.z, -45, 45)
			$Vehicle1.rotation_degrees = vehicle_rotation

# Turn the character and correct the camera if the camera has been rotated	
func _rotate_default(var delta : float) -> void:
	if RotationHelper.rotation_degrees.y != 0:
		var yRot : float = RotationHelper.rotation_degrees.y
		yRot = yRot + (0 - yRot) * (delta * TURN_SPEED)
		RotationHelper.rotation_degrees.y = yRot
		rotate_object_local(Vector3(0, 1, 0), deg2rad(yRot * delta * TURN_SPEED))
	if $Vehicle1.rotation_degrees.z != 0:
		var zRot : float = $Vehicle1.rotation_degrees.z
		zRot = zRot + (0 - zRot) * (delta * TURN_SPEED * 0.3)
		$Vehicle1.rotation_degrees.z = zRot
		
func _pitch_sfx():
	var temp_velocity : Vector2 = Vector2(velocity.x, velocity.z)
	sfx_pitch = ((temp_velocity.length() * MAX_SFX_PITCH) / MAX_SPEED) + MIN_SFX_PITCH
	sfx_pitch = clamp(sfx_pitch, MIN_SFX_PITCH, MAX_SFX_PITCH)
	$Audio_Jet.pitch_scale = sfx_pitch
	$Audio_Diesel.pitch_scale = sfx_pitch

func _adjust_cam_fov_dist():
	var temp_velocity : Vector2 = Vector2(velocity.x, velocity.z)
	camera.fov = ((temp_velocity.length() * MAX_CAM_FOV) / MAX_SPEED) + MIN_CAM_FOV
#	camera.transform.origin.z = (temp_velocity.length() * MIN_CAM_DIST) / MAX_SPEED
	camera.transform.origin.z = ((MIN_CAM_DIST - MAX_CAM_DIST) / MAX_SPEED) * temp_velocity.length() + MAX_CAM_DIST
	camera.fov = clamp(camera.fov, MIN_CAM_FOV, MAX_CAM_FOV)
	camera.transform.origin.z = clamp(camera.transform.origin.z, MIN_CAM_DIST, MAX_CAM_DIST)

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

func _set_speedometer() -> void:
	var _y_vector : Vector3 = -global_transform.basis[1]
	var _y_velocity = Vector3(0, velocity.z, 0)
	_y_velocity = _y_vector.dot(_y_velocity)
	var modified_velocity : Vector3 = Vector3(velocity.x, _y_velocity, velocity.z)
	HUD.set_speedometer(clamp(modified_velocity.length(), 0, MAX_SPEED))

func _set_arrow_angle() -> void:
	pass

func _set_boost(var delta : float) -> void:
	boost += delta
	boost = clamp(boost, 0, MAX_BOOST)
	HUD.set_boost(boost)
	
func start_race() -> void:
	has_control = true
	
func finish_race() -> void:
	has_control = false

func _set_audio_sfx(var sfx_effect):
	var effect_enabled : bool = AudioServer.is_bus_effect_enabled(Globals.player_bus, sfx_effect)
	AudioServer.set_bus_effect_enabled(Globals.player_bus, sfx_effect, !effect_enabled)

func _emit_trail_particles():
	if is_on_ground:
		$Particles.emitting = true
	else:
		$Particles.emitting = false

func _interpolate_float(current: float, target: float, amount: float) -> float:
	current += amount * sign(target - current)
	if abs(target - current) <= abs(amount):
		current = target
	return current

# Check if the player has fallen off the map
func _check_out_of_bounds():
	if global_transform.origin.y < -70:
		global_transform = player_respawn
		_crash()
		velocity = Vector3.ZERO

# Crash if horizontal velocity reduces by too much
func _check_crash():
	var prev_horizontal_vel = Vector2(prev_velocity.x, prev_velocity.z)
	var horizontal_vel = Vector2(velocity.x, velocity.z)
	if horizontal_vel.length() - prev_horizontal_vel.length() < -70:
		_crash()

func _crash():
	has_control = !has_control
	if has_control:
		$VisibilityTimer.stop()
		$Vehicle1.visible = true
	else:
		$CrashTimer.start()
		$VisibilityTimer.start()

func _on_VisibilityTimer_timeout():
	$Vehicle1.visible = !$Vehicle1.visible
