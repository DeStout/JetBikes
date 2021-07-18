extends KinematicBody
class_name Player

signal finished_race

const FORWARD_ACCELERATION : float  = 0.85
const STRIFE_ACCELERATION : float  = 0.65
const REVERSE_ACCELERATION : float  = 0.65
const BOOST_ACCELERATION : float  = 1.1
const DEACCELERATION : float  = 0.025
const BRAKE_DEACCEL : float  = 1.5
const AIR_BRAKE_DEACCEL : float  = 0.5

const MAX_SPEED : int = 180
const MAX_BOOST : int = 250
const MAX_FORWARD_VEL : int = 90
const MAX_STRIFE_VEL : int = 50
const MAX_REVERSE_VEL : int =  75
const MAX_BOOST_VEL : int = 120
const TURN_SPEED : int = 8

const MIN_SFX_PITCH : float = 1.5
const MAX_SFX_PITCH : float = 4.0

const MIN_CAM_FOV : float = 45.0
const MAX_CAM_FOV : float = 65.0
const MIN_CAM_DIST : float = 7.0
const MAX_CAM_DIST : float = 15.0

const MOUSE_VERT_SENSITIVITY : float = 0.1
const MOUSE_HORZ_SENSITIVITY : float  = 0.1

const FREE_ROTATE_VERT_SENSITIVITY : float = 0.05
const FREE_ROTATE_HORZ_SENSITIVITY : float = 0.05

var movement_input : Vector2 = Vector2.ZERO
var velocity : Vector3 = Vector3.ZERO
var prev_velocity : Vector3 = Vector3.ZERO
var boost : float = 125
var boost_cost : float = -1.5
var swing_cost : float = -1.0

var sfx_pitch : float = MIN_SFX_PITCH

var has_control : bool = false
var is_boosting : bool = false
var is_braking : bool = true
var is_on_ground : bool = false
var is_swinging : bool = false
var is_free_rotating : bool = false
var is_crashed : bool = false

var mouse_vert_invert : int = 1
var mouse_horz_invert : int = -1

onready var RotationHelper : Spatial = $RotationHelper
onready var camera : Camera = $RotationHelper/Camera
onready var HUD : Control = $RotationHelper/Camera/HUD
onready var pause_menu : Control = $RotationHelper/Camera/PauseMenu

var ground_point : Vector3
var prev_ground_distance : float = 0

var lap_number : int = 0
var placement : int = 0

onready var navigation : Navigation
var path_nodes : Array
var current_path_node : PathNode
var path_node_distance : float
var swing_poles : Array

func _process(delta : float) -> void:
	_get_key_input()
	if current_path_node != null:
		_path_node_distance()
		_set_arrow_angle()
	_pitch_sfx()
	_adjust_cam_fov_dist()
	_emit_trail_particles()

func _physics_process(delta : float) -> void:
	_rotate_default(delta)
	_check_swing_poles(delta)
	_check_out_of_bounds()
	_check_crash()
	if is_crashed:
		_crash()
		
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
			($KinematicCollisionShape/GroundDetect1.cast_to.length() - 0.1) * -0.499, \
			($KinematicCollisionShape/GroundDetect1.cast_to.length() - 0.1) * 0.499)
		var prev_move_distance : float = ground_distance - prev_ground_distance
		
		if prev_move_distance == 0:
			prev_move_distance = 0.001
		if ground_distance == 0:
			ground_distance = 0.001
			
		var move_force : float = 1 / (ground_distance / (prev_move_distance)) - ground_distance
		move_force = clamp(move_force, -11, 11)
		
		move_direction += ground_normal * move_force * 1.1
		move_direction += downhill * -Globals.GRAVITY * 0.25
		
		prev_ground_distance = ground_distance

	else:
		prev_ground_distance = 0
		move_direction = Vector3(0, -Globals.GRAVITY, 0)
		
#	move_direction += _check_kinematic_collision()
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
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:	
		if event is InputEventMouseButton:
			if event.button_index == 1:
				is_swinging = event.is_pressed()
			if event.button_index == 2:
				is_free_rotating = event.is_pressed()
		
		# Rotate the camera based on mouse movement
		if event is InputEventMouseMotion:
			if is_free_rotating and !is_on_ground:
				$Engine.rotate_x(deg2rad(event.relative.y * mouse_vert_invert * FREE_ROTATE_VERT_SENSITIVITY))
				$Engine.rotate_z(deg2rad(event.relative.x * mouse_horz_invert * FREE_ROTATE_HORZ_SENSITIVITY))
				$KinematicCollisionShape.rotate_x(deg2rad(event.relative.y * mouse_vert_invert * FREE_ROTATE_VERT_SENSITIVITY))
				$KinematicCollisionShape.rotate_z(deg2rad(event.relative.x * mouse_horz_invert * FREE_ROTATE_HORZ_SENSITIVITY))
			else:
				RotationHelper.rotate_x(-deg2rad(event.relative.y * mouse_vert_invert * MOUSE_VERT_SENSITIVITY))
				RotationHelper.rotate_y(deg2rad(event.relative.x * mouse_horz_invert * MOUSE_HORZ_SENSITIVITY))
				
				var helper_rotation : Vector3 = RotationHelper.rotation_degrees
				helper_rotation.x = clamp(helper_rotation.x, -10, 10)
				helper_rotation.y = clamp(helper_rotation.y, -30, 30)
				helper_rotation.z = 0
				RotationHelper.rotation_degrees = helper_rotation
				
				# Rotate vehicle model based on turning sharpness
				var velocity_ratio = clamp(velocity.length() / MAX_FORWARD_VEL, 0.0, 1.0)
				$Engine.rotate_object_local(Vector3(0, 0, 1), deg2rad(helper_rotation.y * 0.08 * velocity_ratio))
				var vehicle_rotation : Vector3 = $Engine.rotation_degrees
				vehicle_rotation.z = clamp(vehicle_rotation.z, -45, 45)
				$Engine.rotation_degrees = vehicle_rotation

# Return Camera, Engine, and Collision back to default values
func _rotate_default(var delta : float) -> void:
	if RotationHelper.rotation_degrees.y != 0:
		var yRot : float = RotationHelper.rotation_degrees.y
		yRot = yRot + (0 - yRot) * (delta * TURN_SPEED)
		RotationHelper.rotation_degrees.y = yRot
		rotate_object_local(Vector3(0, 1, 0), deg2rad(yRot * delta * TURN_SPEED))
	
	if is_on_ground:
		if $Engine.rotation_degrees != Vector3(0, 0, 0):
			var engineRot : Vector3 = $Engine.rotation_degrees
			engineRot = engineRot + (Vector3(0, 0, 0) - engineRot) * (delta * TURN_SPEED * 0.8)
			$Engine.rotation_degrees = engineRot
		if $KinematicCollisionShape.rotation_degrees != Vector3(0, 0, 0):
			var engineRot : Vector3 = $KinematicCollisionShape.rotation_degrees
			engineRot = engineRot + (Vector3.ZERO - engineRot) * (delta * TURN_SPEED * 0.8)
			$KinematicCollisionShape.rotation_degrees = engineRot
	
	
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
#func _is_on_ground() -> void:
#	if !is_on_ground:
#		is_on_ground = true

func check_ray_collision(ray_detect : RayCast):
	if ray_detect.type == "Ground":
		is_on_ground = true
	elif ray_detect.type == "Side":
		if ray_detect.global_transform.basis.z.dot(Vector3.DOWN) < -0.66:
			is_crashed = true
	
# Return the average vector of the normals of the surface the $GroundDetects are colliding with
func _get_ground_normal() -> Vector3:
	var ground_normal1 : Vector3 = $KinematicCollisionShape/GroundDetect1.get_collision_normal()
	var ground_normal2 : Vector3 = $KinematicCollisionShape/GroundDetect2.get_collision_normal()
	return (ground_normal1 + ground_normal2) * 0.5

# Average the collision point of the $GroundDetects and return the local coordinates
func _get_ground_point() -> Vector3:
	var ground_point1 : Vector3 = $KinematicCollisionShape/GroundDetect1.get_collision_point()
	var ground_point2 : Vector3 = $KinematicCollisionShape/GroundDetect2.get_collision_point()
	
	return to_local((ground_point1 + ground_point2) * 0.5)

# Average and return center points of the $GroundCollisions
func _get_cast_point() -> Vector3:
	var cast_point1 = to_local($KinematicCollisionShape/GroundDetect1.global_transform.origin)
	var cast_point2 = to_local($KinematicCollisionShape/GroundDetect2.global_transform.origin)
	
	return (cast_point1 + cast_point2) * 0.5 - Vector3(0, 1.1, 0)

func _set_speedometer() -> void:
	var _y_vector : Vector3 = -global_transform.basis[1]
	var _y_velocity = Vector3(0, velocity.z, 0)
	_y_velocity = _y_vector.dot(_y_velocity)
	var modified_velocity : Vector3 = Vector3(velocity.x, _y_velocity, velocity.z)
	HUD.set_speedometer(clamp(modified_velocity.length(), 0, MAX_SPEED))

func _set_arrow_angle() -> void:
	var vec2_path = Vector2(to_local(current_path_node.global_transform.origin).x, to_local(current_path_node.global_transform.origin).z).normalized()
	HUD.set_arrow_angle(-(vec2_path.angle() + (PI/2)))

func _set_boost(var delta_boost : float) -> void:
	boost += delta_boost
	if Globals.INFINITE_BOOST:
		boost = MAX_BOOST
	boost = clamp(boost, 0, MAX_BOOST)
	HUD.set_boost(boost)
	
func start_race() -> void:
	HUD.set_race_notice()
	has_control = true
	
func finish_race() -> void:
	HUD.set_race_notice("Finished!", true)
	has_control = false
	
func _path_node_distance() -> void:
	var npc_to_path_node_local : Vector3 = current_path_node.to_local(global_transform.origin)
	var path_node_point : Vector3 = current_path_node.path.curve.get_closest_point(npc_to_path_node_local)
	path_node_distance = current_path_node.to_global(path_node_point).distance_to(global_transform.origin)

func update_path_node(var new_path_node : PathNode) -> void:
	if current_path_node.serial == new_path_node.serial:
		_set_boost(new_path_node.boost_value)
		if current_path_node.serial == 0:
			lap_number += 1
			if lap_number > Globals.laps_number:
				emit_signal("finished_race")
			HUD.set_lap(lap_number)
		if typeof(path_nodes[new_path_node.next_serial]) == TYPE_ARRAY:
			current_path_node = path_nodes[new_path_node.next_serial][0]
		else:
			current_path_node = path_nodes[current_path_node.next_serial]

func mod_node_enter(var new_mod_node : ModNode) -> void:
	match new_mod_node.function:
#		new_mod_node.FUNCTION.NULL:
#			print("NULL!?")
#		new_mod_node.FUNCTION.PATHFIND:
#			pass
#		new_mod_node.FUNCTION.SET_SPEED:
#			_set_target_speed(MAX_FORWARD_VEL)
		new_mod_node.FUNCTION.AUDIO_SFX:
			_set_audio_sfx(new_mod_node.value)

func mod_node_exit(var new_mod_node : ModNode) -> void:
	match new_mod_node.function:
#		new_mod_node.FUNCTION.NULL:
#			print("NULL!?")
#		new_mod_node.FUNCTION.PATHFIND:
#			pass
#		new_mod_node.FUNCTION.SET_SPEED:
#			_set_target_speed(MAX_FORWARD_VEL)
		new_mod_node.FUNCTION.AUDIO_SFX:
			_set_audio_sfx(new_mod_node.value)

func _set_audio_sfx(var sfx_effect):
	var effect_enabled : bool = AudioServer.is_bus_effect_enabled(Globals.player_bus, sfx_effect)
	AudioServer.set_bus_effect_enabled(Globals.player_bus, sfx_effect, !effect_enabled)

func _unmute_player_sfx():
	AudioServer.set_bus_mute(Globals.player_bus, false)

func _mute_player_sfx():
	AudioServer.set_bus_mute(Globals.player_bus, true)

func _emit_trail_particles():
	if is_on_ground:
		$Particles.emitting = true
	else:
		$Particles.emitting = false

func add_remove_swing_pole(swing_pole : SwingPole):
	if swing_poles.has(swing_pole):
		swing_poles.erase(swing_pole)
	else:
		swing_poles.append(swing_pole)
	
func _check_swing_poles(delta : float):
	if !swing_poles.empty():
		var closest_pole : SwingPole = swing_poles.front()
		for swing_pole in swing_poles:
			if global_transform.origin.distance_to(swing_pole.global_transform.origin) < \
					global_transform.origin.distance_to(closest_pole.global_transform.origin):
				closest_pole = swing_pole
		if is_swinging and boost > 0:
			_swing(closest_pole, delta)
		else:
			closest_pole.set_laser_line()

func _swing(swing_pole : SwingPole, delta : float):
	var swing_distance = global_transform.origin.distance_to(swing_pole.global_transform.origin)
	var pull_strength = (swing_distance / swing_pole.swing_length) * swing_pole.swing_strength
	var delta_velocity = Vector3.ZERO
	
	if (global_transform.origin + velocity * delta).distance_to(swing_pole.global_transform.origin) > swing_pole.swing_length:
		var delta_origin = global_transform.origin + velocity * delta
		var new_dest : Vector3 = (delta_origin).direction_to(swing_pole.global_transform.origin)
		new_dest *= swing_pole.swing_length
		delta_velocity = (global_transform.origin - new_dest) - delta_origin
		
	velocity += (swing_pole.global_transform.origin - global_transform.origin) * pull_strength
	velocity -= delta_velocity
	
	swing_pole.set_laser_line($Engine.global_transform.origin)
	
	_set_boost(swing_cost)

func _check_kinematic_collision():
	if get_slide_count():
		for i in get_slide_count():
			var collision : KinematicCollision = get_slide_collision(i)
			if collision.collider.get_class() == "KinematicBody":
#				var collision_factor : float = 1 - velocity.normalized().dot(collision.collider_velocity.normalized())
#				print(collision_factor)
				return collision.collider_velocity - velocity
	return Vector3.ZERO

# Check if the player has fallen off the map
func _check_out_of_bounds():
	if global_transform.origin.y < -70:
		global_transform.origin = navigation.get_closest_point(to_global(ground_point))
		is_crashed = true

# Crash if horizontal velocity reduces by too much
func _check_crash():
	var prev_horizontal_vel = Vector2(prev_velocity.x, prev_velocity.z)
	var horizontal_vel = Vector2(velocity.x, velocity.z)
	if horizontal_vel.length() - prev_horizontal_vel.length() < -60:
		is_crashed = true
		
func _crash_finished():
	is_crashed = false
	if Globals.race_on_going == true:
		has_control = true
	set_collision_layer_bit(0, true)
	$VisibilityTimer.stop()
	$Engine.visible = true
	$Particles.emitting = true

func _crash():
	if !$CrashTimer.time_left:
		global_transform.origin = navigation.get_closest_point(to_global(ground_point))
		global_transform.basis.y = Vector3.UP
		$Engine.rotation = Vector3(0, PI, 0)
		$KinematicCollisionShape.rotation = Vector3(0, 0, 0)
		
		velocity = Vector3.ZERO
		has_control = false
		set_collision_layer_bit(0, false)
		$CrashTimer.start()
		$VisibilityTimer.start()
		$Particles.emitting = false

func _on_VisibilityTimer_timeout():
	$Engine.visible = !$Engine.visible

func _interpolate_float(current: float, target: float, amount: float) -> float:
	current += amount * sign(target - current)
	if abs(target - current) <= abs(amount):
		current = target
	return current
