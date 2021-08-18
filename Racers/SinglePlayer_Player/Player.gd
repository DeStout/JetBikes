extends Racer
class_name Player

onready var rotation_helper : Spatial = $RotationHelper
onready var camera : Camera = $RotationHelper/Camera
onready var HUD : Control = $RotationHelper/Camera/HUD
onready var pause_menu : Control = $RotationHelper/Camera/PauseMenu

const MIN_CAM_FOV : float = 45.0
const MAX_CAM_FOV : float = 65.0
const MIN_CAM_DIST : float = 7.0
const MAX_CAM_DIST : float = 15.0

const MOUSE_VERT_SENSITIVITY : float = 0.1
const MOUSE_HORZ_SENSITIVITY : float  = 0.1

const FREE_ROTATE_VERT_SENSITIVITY : float = 0.05
const FREE_ROTATE_HORZ_SENSITIVITY : float = 0.05

var has_cam_control : bool = true

var mouse_vert_invert : int = 1
var mouse_horz_invert : int = -1

func _process(delta : float) -> void:
	_get_key_input()
	if current_path_node != null:
		_set_arrow_angle()
	_adjust_cam_fov_dist()

func _physics_process(delta : float) -> void:
	_rotate_default(delta)
	
	var move_direction : Vector3 = Vector3()
	var player_basis : Basis = global_transform.basis
	var temp_velocity : Vector3 = velocity
	temp_velocity.y = 0
	
	if is_on_ground:
		var ground_normal : Vector3 = _get_ground_normal()
		
		# Align player Y vector to ground normal
		if player_basis[1].dot(ground_normal) > 0:
			var player_quat = player_basis.get_rotation_quat()
			global_transform.basis = Basis(player_quat.slerp(_align_to_normal(ground_normal), delta*6))
		
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
			($CollisionShape/GroundDetect1.cast_to.length() - 0.1) * -0.499, \
			($CollisionShape/GroundDetect1.cast_to.length() - 0.1) * 0.499)
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
				if boost > 0:
					is_boosting = true
					_set_boost_sfx()
			elif Input.is_action_just_released("Boost"):
				is_boosting = false
				_set_boost_sfx()

func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:	
		if event is InputEventMouseButton:
			if has_control:
				if event.button_index == 1:
					is_swinging = event.is_pressed()
			if event.button_index == 2:
				is_free_rotating = event.is_pressed()
		
		# Rotate the camera based on mouse movement
		if event is InputEventMouseMotion:
			if is_free_rotating and !is_on_ground:
				$Engine.rotate_x(deg2rad(event.relative.y * mouse_vert_invert * FREE_ROTATE_VERT_SENSITIVITY))
				$Engine.rotate_z(deg2rad(event.relative.x * mouse_horz_invert * FREE_ROTATE_HORZ_SENSITIVITY))
				$CollisionShape.rotate_x(deg2rad(event.relative.y * mouse_vert_invert * FREE_ROTATE_VERT_SENSITIVITY))
				$CollisionShape.rotate_z(deg2rad(event.relative.x * mouse_horz_invert * FREE_ROTATE_HORZ_SENSITIVITY))
			elif has_cam_control:
				rotation_helper.rotate_x(-deg2rad(event.relative.y * mouse_vert_invert * MOUSE_VERT_SENSITIVITY))
				rotation_helper.rotate_y(deg2rad(event.relative.x * mouse_horz_invert * MOUSE_HORZ_SENSITIVITY))
				
				var helper_rotation : Vector3 =rotation_helper.rotation_degrees
				helper_rotation.x = clamp(helper_rotation.x, -10, 10)
				helper_rotation.y = clamp(helper_rotation.y, -30, 30)
				helper_rotation.z = 0
				rotation_helper.rotation_degrees = helper_rotation
				
				# Rotate vehicle model based on turning sharpness
				var velocity_ratio = clamp(velocity.length() / MAX_FORWARD_VEL, 0.0, 1.0)
				$Engine.rotate_object_local(Vector3(0, 0, 1), deg2rad(helper_rotation.y * 0.08 * velocity_ratio))
				var vehicle_rotation : Vector3 = $Engine.rotation_degrees
				vehicle_rotation.z = clamp(vehicle_rotation.z, -45, 45)
				$Engine.rotation_degrees = vehicle_rotation

# Return Camera, Engine, and Collision back to default values
func _rotate_default(delta : float) -> void:
	if has_cam_control:
		if rotation_helper.rotation_degrees.y != 0:
			var yRot : float =rotation_helper.rotation_degrees.y
			yRot = yRot + (0 - yRot) * (delta * TURN_SPEED)
			rotation_helper.rotation_degrees.y = yRot
			rotate_object_local(Vector3(0, 1, 0), deg2rad(yRot * delta * TURN_SPEED))
	
	if is_on_ground:
		if $Engine.rotation_degrees != Vector3(0, 0, 0):
			var engineRot : Vector3 = $Engine.rotation_degrees
			engineRot = engineRot + (Vector3(0, 0, 0) - engineRot) * (delta * TURN_SPEED * 0.8)
			$Engine.rotation_degrees = engineRot
		if $CollisionShape.rotation_degrees != Vector3(0, 0, 0):
			var engineRot : Vector3 = $CollisionShape.rotation_degrees
			engineRot = engineRot + (Vector3.ZERO - engineRot) * (delta * TURN_SPEED * 0.8)
			$CollisionShape.rotation_degrees = engineRot

func _adjust_cam_fov_dist():
	var temp_velocity : Vector2 = Vector2(velocity.x, velocity.z)
	camera.fov = ((temp_velocity.length() * MAX_CAM_FOV) / MAX_SPEED) + MIN_CAM_FOV
#	camera.transform.origin.z = (temp_velocity.length() * MIN_CAM_DIST) / MAX_SPEED
	camera.transform.origin.z = ((MIN_CAM_DIST - MAX_CAM_DIST) / MAX_SPEED) * temp_velocity.length() + MAX_CAM_DIST
	camera.fov = clamp(camera.fov, MIN_CAM_FOV, MAX_CAM_FOV)
	camera.transform.origin.z = clamp(camera.transform.origin.z, MIN_CAM_DIST, MAX_CAM_DIST)

func _set_speedometer() -> void:
	var _y_vector : Vector3 = -global_transform.basis[1]
	var _y_velocity = Vector3(0, velocity.z, 0)
	_y_velocity = _y_vector.dot(_y_velocity)
	var modified_velocity : Vector3 = Vector3(velocity.x, _y_velocity, velocity.z)
	HUD.set_speedometer(clamp(modified_velocity.length(), 0, MAX_SPEED))

func _set_arrow_angle() -> void:
	var closest_path_node_point : Vector3 = current_path_node.get_closest_point(global_transform.origin)
	var vec2_path : Vector2 = Vector2(to_local(closest_path_node_point).x, to_local(closest_path_node_point).z).normalized()
	HUD.set_arrow_angle(-(vec2_path.angle() + (PI / 2)))

func _set_boost(delta_boost : float) -> void:
	._set_boost(delta_boost)
	HUD.set_boost(boost)
	
func start_race() -> void:
	.start_race()
	HUD.set_race_notice()

func update_path_node(new_path_node : PathNode) -> void:
	if current_path_node.serial == new_path_node.serial:
		_set_boost(new_path_node.boost_value)
		if current_path_node.serial == 0:
			lap_number += 1
			if lap_number > Globals.laps_number:
				emit_signal("finished_race", self)
			HUD.set_lap(lap_number)
		if typeof(path_nodes[new_path_node.next_serial]) == TYPE_ARRAY:
			current_path_node = path_nodes[new_path_node.next_serial][0]
		else:
			current_path_node = path_nodes[current_path_node.next_serial]
			
func _crash():
	if !$CrashTimer.time_left:
		has_cam_control = false
	._crash()
	camera.look_at(crash_bike.global_transform.origin, Vector3.UP)

func _crash_finished():
	._crash_finished()
	$RotationHelper/Camera.transform = $RotationHelper/Camera.default_cam_transform
	if Globals.race_on_going == true:
		has_cam_control = true

func _mute_player_sfx():
	AudioServer.set_bus_mute(Globals.player_bus, true)

func _unmute_player_sfx():
	AudioServer.set_bus_mute(Globals.player_bus, false)
