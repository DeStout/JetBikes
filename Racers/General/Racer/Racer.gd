extends KinematicBody
class_name Racer

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

var sfx_pitch : float = MIN_SFX_PITCH

var movement_input : Vector2 = Vector2.ZERO
var velocity : Vector3 = Vector3.ZERO
var prev_velocity : Vector3 = Vector3.ZERO
var boost : float = 125
var boost_cost : float = -1.5
var swing_cost : float = -1.0

var has_control : bool = false
var is_boosting : bool = false
var is_braking : bool = true
var is_on_ground : bool = false
var is_crashed : bool = false
var is_swinging : bool = false
var is_free_rotating : bool = false

onready var ground_particles : Particles = $GroundParticles

var ground_point : Vector3
var prev_ground_distance : float = 0

var lap_number : int = 0
var placement : int = 0

var navigation : Navigation
var path_nodes : Array
var current_path_node : PathNode
var path_node_distance : float
var swing_poles : Array

var crash_bike : RigidBody


func _process(delta):
	if current_path_node != null:
		_path_node_distance()
	_pitch_sfx()
	_emit_trail_particles()


func _physics_process(delta):
	_check_swing_poles(delta)
	_check_out_of_bounds()
	_check_crash()
	if is_crashed:
		_crash()


func check_ray_collision(ray_detect : RayCast):
	if ray_detect.type == "Ground":
		is_on_ground = true
		
	elif ray_detect.type == "Side":
		if ray_detect.global_transform.basis.z.dot(Vector3.DOWN) < -0.66:
			is_crashed = true


# Return the average vector of the normals of the surface the $GroundDetects are colliding with
func _get_ground_normal() -> Vector3:
	var ground_normal1 : Vector3 = $CollisionShape/GroundDetect1.get_collision_normal()
	var ground_normal2 : Vector3 = $CollisionShape/GroundDetect2.get_collision_normal()
	return ((ground_normal1 + ground_normal2) * 0.5).normalized()


# Average the collision point of the $GroundDetects and return the local coordinates
func _get_ground_point() -> Vector3:
	var ground_point1 : Vector3 = $CollisionShape/GroundDetect1.get_collision_point()
	var ground_point2 : Vector3 = $CollisionShape/GroundDetect2.get_collision_point()
	
	return to_local((ground_point1 + ground_point2) * 0.5)


# Average and return center points of the $GroundCollisions
func _get_cast_point() -> Vector3:
	var cast_point1 = to_local($CollisionShape/GroundDetect1.global_transform.origin)
	var cast_point2 = to_local($CollisionShape/GroundDetect2.global_transform.origin)
	
	return (cast_point1 + cast_point2) * 0.5 - Vector3(0, 1.1, 0)


func start_race() -> void:
	has_control = true
	is_braking = false


func finish_race() -> void:
	has_control = false
	is_braking = true
	is_swinging = false
	is_boosting = false
	_set_boost_sfx()


func _path_node_distance() -> void:
	path_node_distance = current_path_node.get_closest_point_distance(global_transform.origin)


func _pitch_sfx():
	var temp_velocity : Vector2 = Vector2(velocity.x, velocity.z)
	sfx_pitch = ((temp_velocity.length() * MAX_SFX_PITCH) / MAX_SPEED) + MIN_SFX_PITCH
	sfx_pitch = clamp(sfx_pitch, MIN_SFX_PITCH, MAX_SFX_PITCH)
	$Audio_Jet.pitch_scale = sfx_pitch
	$Audio_Diesel.pitch_scale = sfx_pitch


func _set_boost_sfx():
	$Audio_Boost.set_playing(is_boosting)


func _set_boost(delta_boost : float) -> void:
	boost += delta_boost
	if Globals.INFINITE_BOOST:
		boost = MAX_BOOST
	boost = clamp(boost, 0, MAX_BOOST)
	if boost == 0:
		is_boosting = 0


func _emit_trail_particles():
	if is_on_ground:
		ground_particles.emitting = true
	else:
		ground_particles.emitting = false


# Check if the player has fallen off the map
func _check_out_of_bounds():
	if global_transform.origin.y < -70:
		is_crashed = true


# Crash if horizontal velocity reduces by too much
func _check_crash():
	var prev_horizontal_vel = Vector2(prev_velocity.x, prev_velocity.z)
	var horizontal_vel = Vector2(velocity.x, velocity.z)
	if horizontal_vel.length() - prev_horizontal_vel.length() < -60:
		is_crashed = true


func _crash():
	if !$CrashTimer.time_left:
		crash_bike.set_crash(self)
		
		visible = false
		has_control = false
		is_swinging = false
		is_free_rotating = false
		is_boosting = false
		
		$CollisionShape.disabled = true
		_set_boost_sfx()
		ground_particles.emitting = false
		$CrashTimer.start()

	velocity = Vector3.ZERO


func _crash_finished():
	is_crashed = false
	
	global_transform.origin = navigation.get_closest_point(to_global(ground_point))
	rotation = Vector3.ZERO
	$EngineRotationHelper.rotation = Vector3.ZERO
	$EngineRotationHelper/Engine.rotation = Vector3.ZERO
	$CollisionShape.rotation = Vector3.ZERO
	look_at(current_path_node.global_transform.origin, Vector3.UP)
	
	visible = true
	if Globals.race_on_going == true:
		has_control = true
	$CollisionShape.disabled = false
#	$VisibilityTimer.stop()
	ground_particles.emitting = true
	crash_bike.remove_crash()


func _on_VisibilityTimer_timeout():
	$EngineRotationHelper/Engine.visible = !$EngineRotationHelper/Engine.visible


func _check_kinematic_collision():
	if get_slide_count():
		for i in get_slide_count():
			var collision : KinematicCollision = get_slide_collision(i)
			if collision.collider.get_class() == "KinematicBody":
#				var collision_factor : float = 1 - velocity.normalized().dot(collision.collider_velocity.normalized())
				return collision.collider_velocity - velocity
	return Vector3.ZERO


func add_remove_swing_pole(swing_pole : SwingPole):
	if swing_poles.has(swing_pole):
		swing_poles.erase(swing_pole)
		$LaserLine.set_laser_line()
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
			$LaserLine.set_laser_line()


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
	
#	swing_pole.set_laser_line($EngineRotationHelper/Engine.global_transform.origin)
	$LaserLine.set_laser_line(swing_pole.global_transform.origin)
	
	_set_boost(swing_cost)


func mod_node_enter(new_mod_node : ModNode) -> void:
	match new_mod_node.function:
#		new_mod_node.FUNCTION.NULL:
#			print("NULL!?")
		new_mod_node.FUNCTION.PATHFIND:
			pathfind_next_node()
		new_mod_node.FUNCTION.SET_SPEED:
			_set_target_speed(new_mod_node.value)
#		new_mod_node.FUNCTION.AUDIO_SFX:
#			_set_audio_sfx(new_mod_node.value)


func mod_node_exit(new_mod_node : ModNode) -> void:
	match new_mod_node.function:
#		new_mod_node.FUNCTION.NULL:
#			print("NULL!?")
		new_mod_node.FUNCTION.PATHFIND:
			pass
		new_mod_node.FUNCTION.SET_SPEED:
			_set_target_speed(MAX_FORWARD_VEL)
#		new_mod_node.FUNCTION.AUDIO_SFX:
#			_set_audio_sfx(new_mod_node.value)


func pathfind_next_node() -> void:
	pass


func _set_target_speed(new_target_speed : int) -> void:
	pass


func set_racer_color(new_color : Color) -> void:
	var bike_material = $EngineRotationHelper/Engine/SteeringColumn.get_surface_material(0)
	var windshield_material = $EngineRotationHelper/Engine/WindShield.get_surface_material(0)
	if bike_material:
		bike_material.albedo_color = new_color
	if windshield_material:
		windshield_material.albedo_color = new_color
		windshield_material.albedo_color.a = 90.0 / 255.0


func _set_audio_sfx(sfx_effect):
	var effect_enabled : bool = AudioServer.is_bus_effect_enabled(Globals.player_bus, sfx_effect)
	AudioServer.set_bus_effect_enabled(Globals.player_bus, sfx_effect, !effect_enabled)


# Helper function to align player with the ground normal
func _align_to_normal(ground_normal : Vector3) -> Quat:
	var result : Basis = Basis()
	result.y = ground_normal.normalized()
	result.x = ground_normal.cross(global_transform.basis.z).normalized()
	result.z = result.x.cross(result.y).normalized()
	return result.orthonormalized().get_rotation_quat()


func _interpolate_float(current: float, target: float, amount: float) -> float:
	current += amount * sign(target - current)
	if abs(target - current) <= abs(amount):
		current = target
	return current