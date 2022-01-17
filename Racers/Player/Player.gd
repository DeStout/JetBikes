# Jimmy Jazz
extends Racer
class_name Player

onready var engine_rot_help : Spatial = $EngineRotationHelper
onready var engine : Spatial = $EngineRotationHelper/Engine
onready var cam_rot_help : Spatial = $CamRotationHelper
onready var camera : Camera = $CamRotationHelper/SpringArm/CamPosHelper/Camera
onready var HUD : Control = $CamRotationHelper/SpringArm/CamPosHelper/Camera/HUD
onready var pause_menu : Control = $CamRotationHelper/SpringArm/CamPosHelper/Camera/PauseMenu

const MIN_CAM_FOV : float = 40.0
const MAX_CAM_FOV : float = 75.0
#const MIN_CAM_DIST : float = 10.0
#const MAX_CAM_DIST : float = 25.0
const MIN_CAM_DIST : float = -10.0
const MAX_CAM_DIST : float = 0.0
#const MIN_CAM_HEIGHT : float = 10.0
#const MAX_CAM_HEIGHT : float = 12.5
const MIN_CAM_HEIGHT : float = 5.0
const MAX_CAM_HEIGHT : float = 5.0

const MOUSE_VERT_SENSITIVITY : float = 0.1
const MOUSE_HORZ_SENSITIVITY : float  = 0.1

const FREE_ROTATE_VERT_SENSITIVITY : float = 0.05
const FREE_ROTATE_HORZ_SENSITIVITY : float = 0.05

var has_cam_control : bool = false
onready var default_spring_arm_orientation : Transform = $CamRotationHelper/SpringArm.transform

var mouse_vert_invert : int = 1
var mouse_horz_invert : int = -1
var free_rotate_origin : Vector2 = Vector2.ZERO
var max_rotate_speed : int = 200


func _process(delta : float) -> void:
	_get_key_input()
	if current_path_node != null:
		_set_arrow_angle()
	_adjust_cam_fov_dist()


func _physics_process(delta : float) -> void:
	_rotate_default(delta)
	_free_rotate(delta)
	
	var player_basis : Basis = global_transform.basis
	
	if is_on_ground:
		
		# Align player Y vector to ground normal
		var move_direction : Vector3 = Vector3.ZERO
		var basis_velocity : Vector3 = Vector3(velocity.dot(player_basis.x), \
							velocity.dot(player_basis.y), velocity.dot(player_basis.z))
		
		if player_basis[1].dot(ground_normal) > 0:
			var player_quat = player_basis.get_rotation_quat()
			global_transform.basis = Basis(player_quat.slerp(_align_to_normal(ground_normal), delta*4))
		
		if !is_braking:
			var delta_move : Vector3
			
			#
			# Apply acceleration/deacceleration along player X vector based on input
			#
			if movement_input.x != 0:
				if abs(basis_velocity.x) > MAX_STRIFE_VEL and sign(movement_input.x) == sign(basis_velocity.x):
					move_direction.x = _interpolate_float(basis_velocity.x, \
						MAX_STRIFE_VEL * sign(movement_input.x), STRIFE_DEACCELERATION * 0.5) - basis_velocity.x
				else:
					move_direction.x = _interpolate_float(basis_velocity.x, \
						MAX_STRIFE_VEL * sign(movement_input.x), STRIFE_ACCELERATION) - basis_velocity.x
			else:
				move_direction.x = _interpolate_float(basis_velocity.x, 0, STRIFE_DEACCELERATION) - basis_velocity.x
			
			#
			# Apply acceleration/deacceleration along player Z vector based on input
			#
			if movement_input.y > 0:
				var max_forward_vel : float = MAX_FORWARD_VEL * 1.15
				var acceleration : float = FORWARD_ACCELERATION
				if is_boosting:
					max_forward_vel = MAX_BOOST_VEL
					acceleration = BOOST_ACCELERATION
					_set_boost(boost_cost)

				if basis_velocity.z < -max_forward_vel:
					move_direction.z = _interpolate_float(basis_velocity.z, \
						-max_forward_vel, DEACCELERATION * 0.5) - basis_velocity.z
				else:
					move_direction.z = _interpolate_float(basis_velocity.z, \
						-max_forward_vel, acceleration) - basis_velocity.z
			elif movement_input.y < 0:
				if basis_velocity.z < MAX_REVERSE_VEL:
					move_direction.z = _interpolate_float(basis_velocity.z, \
						MAX_REVERSE_VEL, DEACCELERATION * 0.5) - basis_velocity.z
				else:
					move_direction.z = _interpolate_float(basis_velocity.z, \
						MAX_REVERSE_VEL, REVERSE_ACCELERATION) - basis_velocity.z
			else:
				move_direction.z = _interpolate_float(basis_velocity.z, 0, DEACCELERATION) - basis_velocity.z
		
			basis_velocity += move_direction
			
			# Throttle diagonal movement speed
			var mod_basis_velocity : Vector3 = Vector3(basis_velocity.x, 0, basis_velocity.z)
			if movement_input.y > 0 and movement_input.x != 0:
				var max_forward_vel : float = MAX_FORWARD_VEL
				if is_boosting:
					max_forward_vel = MAX_BOOST_VEL
					
				if mod_basis_velocity.length() > max_forward_vel:
					var max_z_vel : float = max_forward_vel * (basis_velocity.z / mod_basis_velocity.length())
					var max_x_vel : float = max_forward_vel * (basis_velocity.x / mod_basis_velocity.length())
					basis_velocity.z = _interpolate_float(basis_velocity.z, max_z_vel, DEACCELERATION * 2)
					basis_velocity.x = _interpolate_float(basis_velocity.x, max_x_vel, DEACCELERATION * 2)
			
			velocity = player_basis.xform(basis_velocity)
		
		# Hover along surface normal and slide downhill
		ground_normal = _get_ground_normal()
		var downhill : Vector3 = Vector3(0, -1, 0).cross(ground_normal).cross(ground_normal)
		var cast_point : Vector3 = _get_cast_point()
		ground_point = _get_ground_point()
		
		var ground_distance : float = clamp(cast_point.length() - ground_point.length(), \
			($CollisionShape/GroundDetect1.cast_to.length() - 0.1) * -0.5, \
			($CollisionShape/GroundDetect1.cast_to.length() - 0.1) * 0.5)
		var prev_move_distance : float = ground_distance - prev_ground_distance
		
		if prev_move_distance == 0:
			prev_move_distance = 0.001
			
		var move_force : float = 1 / (ground_distance / prev_move_distance) - ground_distance
		move_force = clamp(move_force, -10, 10)
		
		if hop:
			$Audio_Hop.play()
			velocity += ground_normal * 7.5
		
		velocity += ground_normal * move_force
		velocity += downhill * -Globals.GRAVITY * 0.25 * delta
		
		prev_ground_distance = ground_distance
	
	# Else if not on ground
	else:
		var player_quat = player_basis.get_rotation_quat()
		global_transform.basis = Basis(player_quat.slerp(_align_to_normal(Vector3.UP), delta*2))

		prev_ground_distance = 0
		velocity.y -= Globals.GRAVITY * delta
		
		if hop:
			hop = false
	
	velocity += _check_kinematic_collision()
	
	if is_braking:
		if is_on_ground:
			velocity.x = _interpolate_float(velocity.x, 0, BRAKE_DEACCEL)
			velocity.z = _interpolate_float(velocity.z, 0, BRAKE_DEACCEL)
		else:
			velocity.x = _interpolate_float(velocity.x, 0, AIR_BRAKE_DEACCEL)
			velocity.z = _interpolate_float(velocity.z, 0, AIR_BRAKE_DEACCEL)
	
	prev_velocity = velocity
	
	velocity = move_and_slide(velocity, Vector3.UP, false, 4, 0.785, false)
	
	_set_speedometer()


# Track what keyboard input is being pressed
func _get_key_input() -> void:
	movement_input = Vector2.ZERO
		
	if has_control:
		if Input.is_action_pressed("Accelerate"):
			movement_input.y += 1
		if Input.is_action_pressed("Strife_Left"):
			movement_input.x -= 1
		if Input.is_action_pressed("Strife_Right"):
			movement_input.x += 1
		if Input.is_action_pressed("Reverse"):
			movement_input.y -= 1
			
		if Input.is_action_just_pressed("Brake"):
			is_braking = true
		elif Input.is_action_just_released("Brake"):
			is_braking = false
		else:
			if Input.is_action_just_pressed("Boost"):
				if boost > 0 and movement_input.y > 0:
					is_boosting = true
					_set_boost_sfx()
			elif Input.is_action_just_released("Boost"):
				is_boosting = false
				_set_boost_sfx()
		
		if Input.is_action_just_pressed("Hop"):
			hop = true


func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:	
		if event is InputEventMouseButton:
			if has_control:
				if event.button_index == 1:
					is_swinging = event.pressed
				if event.button_index == 2:
					is_free_rotating = event.pressed
					free_rotate_origin = Vector2.ZERO
		
		if event is InputEventMouseMotion:
			# Free rotate the player
			if is_free_rotating and !is_on_ground:
				if engine.rotation != Vector3.ZERO:
					engine_rot_help.rotation += engine.rotation
					$CollisionShape.rotation += engine.rotation
					engine.rotation = Vector3.ZERO
					
				free_rotate_origin.x = clamp(free_rotate_origin.x + event.relative.x * 0.07, -max_rotate_speed, max_rotate_speed)
				free_rotate_origin.y = clamp(free_rotate_origin.y + event.relative.y * 0.07, -max_rotate_speed, max_rotate_speed)
				
			# Rotate the camera based on mouse movement
			elif has_cam_control:
				cam_rot_help.rotate_x(-deg2rad(event.relative.y * mouse_vert_invert * MOUSE_VERT_SENSITIVITY))
				cam_rot_help.rotate_y(deg2rad(event.relative.x * mouse_horz_invert * MOUSE_HORZ_SENSITIVITY))
				
				var helper_rotation : Vector3 = cam_rot_help.rotation_degrees
				helper_rotation.x = clamp(helper_rotation.x, -28, -5)
				helper_rotation.y = clamp(helper_rotation.y, -30, 30)
				helper_rotation.z = 0
				cam_rot_help.rotation_degrees = helper_rotation
				
				# Rotate vehicle model based on turning sharpness
				var velocity_ratio = clamp(velocity.length() / MAX_FORWARD_VEL, 0.0, 1.0)
				engine.rotate_object_local(Vector3(0, 0, 1), deg2rad(helper_rotation.y * 0.08 * velocity_ratio))
				var vehicle_rotation : Vector3 = engine.rotation_degrees
				vehicle_rotation.z = clamp(vehicle_rotation.z, -45, 45)
				engine.rotation_degrees = vehicle_rotation


# Return Camera, Engine, and Collision back to default values
func _rotate_default(delta : float) -> void:
	if has_cam_control:
		if cam_rot_help.rotation_degrees.y != 0:
			var yRot : float = cam_rot_help.rotation_degrees.y
			yRot = yRot + (0 - yRot) * (delta * TURN_SPEED)
			cam_rot_help.rotation_degrees.y = yRot
			rotate_object_local(Vector3.UP, deg2rad(yRot * delta * TURN_SPEED))
	
	if engine.rotation_degrees != Vector3.ZERO:
		var engineRot : Vector3 = engine.rotation_degrees
		engineRot = engineRot + (Vector3.ZERO - engineRot) * (delta * TURN_SPEED * 0.5)
		engine.rotation_degrees = engineRot
	
	if is_on_ground:
		if engine_rot_help.rotation_degrees != Vector3.ZERO:
			var engineRot : Vector3 = engine_rot_help.rotation_degrees
			engineRot = engineRot + (Vector3.ZERO - engineRot) * (delta * TURN_SPEED * 0.5)
			engine_rot_help.rotation_degrees = engineRot
		if $CollisionShape.rotation_degrees != Vector3.ZERO:
			var engineRot : Vector3 = $CollisionShape.rotation_degrees
			engineRot = engineRot + (Vector3.ZERO - engineRot) * (delta * TURN_SPEED * 0.5)
			$CollisionShape.rotation_degrees = engineRot


func _free_rotate(delta : float) -> void:
	if is_free_rotating and !is_on_ground:
		engine_rot_help.rotate_x(deg2rad(free_rotate_origin.y * mouse_vert_invert * FREE_ROTATE_VERT_SENSITIVITY))
		engine_rot_help.rotate_z(deg2rad(free_rotate_origin.x * mouse_horz_invert * FREE_ROTATE_HORZ_SENSITIVITY))
		$CollisionShape.rotate_x(deg2rad(free_rotate_origin.y * mouse_vert_invert * FREE_ROTATE_VERT_SENSITIVITY))
		$CollisionShape.rotate_z(deg2rad(free_rotate_origin.x * mouse_horz_invert * FREE_ROTATE_HORZ_SENSITIVITY))


func _adjust_cam_fov_dist():
	var player_basis : Basis = global_transform.basis
	var temp_velocity : Vector2 = Vector2(velocity.dot(player_basis.x), velocity.dot(player_basis.z))
	var max_speed : float = MAX_FORWARD_VEL
#	if is_boosting:
#		max_speed = MAX_BOOST_VEL
	camera.fov = clamp(((temp_velocity.length() * (MAX_CAM_FOV - MIN_CAM_FOV)) / max_speed) + MIN_CAM_FOV, \
		MIN_CAM_FOV, MAX_CAM_FOV)
	camera.transform.origin.z = ((temp_velocity.length() * (MIN_CAM_DIST - MAX_CAM_DIST)) / max_speed) + MAX_CAM_DIST
	camera.transform.origin.y = ((temp_velocity.length() * (MIN_CAM_HEIGHT - MAX_CAM_HEIGHT)) / max_speed) + MAX_CAM_HEIGHT
	camera.transform.origin.z = clamp(camera.transform.origin.z, MIN_CAM_DIST, MAX_CAM_DIST)
	camera.transform.origin.y = clamp(camera.transform.origin.y, MIN_CAM_HEIGHT, MAX_CAM_HEIGHT)


func _set_speedometer() -> void:
	var _y_vector : Vector3 = -global_transform.basis[1]
	var _y_velocity = Vector3(0, velocity.y, 0)
	_y_velocity = _y_vector.dot(_y_velocity)
	var modified_velocity : Vector3 = Vector3(velocity.x, _y_velocity, velocity.z)
	HUD.set_speedometer(clamp(modified_velocity.length(), 0, MAX_BOOST_VEL))


func _set_arrow_angle() -> void:
	var closest_path_node_point : Vector3 = current_path_node.get_closest_point(global_transform.origin)
	var vec2_path : Vector2 = Vector2(to_local(closest_path_node_point).x, to_local(closest_path_node_point).z).normalized()
	HUD.set_arrow_angle(-(vec2_path.angle() + (PI / 2)))


func _set_boost(delta_boost : float) -> void:
	._set_boost(delta_boost)
	HUD.set_boost(boost)


func set_current() -> void:
	$CamRotationHelper/SpringArm/CamPosHelper/Camera.current = true


func start_race() -> void:
	.start_race()
	HUD.set_race_notice()


func update_path_node(new_path_node : PathNode) -> void:
	if current_path_node.serial == new_path_node.serial:
		_set_boost(new_path_node.boost_value)
		if current_path_node.serial == 0:
			lap_number += 1
			check_lap_number()
		if typeof(path_nodes[new_path_node.next_serial]) == TYPE_ARRAY:
			current_path_node = path_nodes[new_path_node.next_serial][0]
		else:
			current_path_node = path_nodes[current_path_node.next_serial]


func check_lap_number() -> void:
	if lap_number > Globals.laps_number:
		emit_signal("finished_race", self)
	HUD.set_lap(lap_number)


func _crash():
	if !$CrashTimer.time_left:
		has_cam_control = false
	._crash()
	$CamRotationHelper/SpringArm.look_at(crash_bike.global_transform.origin, Vector3.UP)
#	camera.look_at(crash_bike.global_transform.origin, Vector3.UP)


func _crash_finished():
	._crash_finished()
	$CamRotationHelper/SpringArm.transform = default_spring_arm_orientation
#	camera.transform = camera.default_cam_transform
	if Globals.race_on_going == true:
		has_cam_control = true


func _mute_player_sfx():
	AudioServer.set_bus_mute(Globals.player_bus, true)


func _unmute_player_sfx():
	AudioServer.set_bus_mute(Globals.player_bus, false)
