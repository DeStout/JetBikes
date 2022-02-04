extends KinematicBody
class_name Racer

signal finished_race

const FORWARD_ACCELERATION : float  = 0.95
const STRIFE_ACCELERATION : float  = 0.85
const REVERSE_ACCELERATION : float  = 0.75
const BOOST_ACCELERATION : float  = 1.5
const STRIFE_DEACCELERATION : float = 1.2
const DEACCELERATION : float  = 0.5
const BRAKE_DEACCEL : float  = 1.5
const AIR_BRAKE_DEACCEL : float  = 1.2
const HOP_IMPULSE : float = 7.0

#const MAX_SPEED : int = 180
const MAX_FORWARD_VEL : int = 85
const MAX_STRIFE_VEL : int = 65
const MAX_REVERSE_VEL : int =  50
const MAX_BOOST_VEL : int = 125
const TURN_SPEED : int = 8

const MAX_BOOST : int = 250

const MIN_SFX_PITCH : float = 1.5
const MAX_SFX_PITCH : float = 4.0

var sfx_pitch : float = MIN_SFX_PITCH

var movement_input : Vector2 = Vector2.ZERO
var velocity : Vector3 = Vector3.ZERO
var prev_velocity : Vector3 = Vector3.ZERO
var boost : float = 125.0
var boost_cost : float = -1.0
var swing_cost : float = -0.66

var has_control : bool = false
var is_boosting : bool = false
var is_braking : bool = true
var is_on_ground : bool = false
var is_crashed : bool = false
var is_swinging : bool = false
var is_free_rotating : bool = false
var hop : bool = false

var bike_color : Color
var bike_material : SpatialMaterial = SpatialMaterial.new()
var windshield_material : SpatialMaterial = SpatialMaterial.new()
onready var ground_particles : Particles = $GroundParticles
var sparks_particles = load("res://Racers/General/Bike/Assets/Models/Sparks.tscn")

var ground_normal = Vector3.UP

var lap_number : int = 0
var placement : int = 0

#var navigation : Navigation
var path : Path
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
	_check_ray_collision()
	_check_out_of_bounds()
	_check_crash()
	if is_crashed:
		_crash()

	_check_swing_poles(delta)

	ground_normal = _get_ground_normal()
	var racer_basis : Basis = global_transform.basis
	var racer_quat = racer_basis.get_rotation_quat()

	if is_on_ground:
		# Align Racer to ground normal
		if racer_basis.y.dot(ground_normal) > 0:
				global_transform.basis = Basis(racer_quat.slerp(_align_to_normal(ground_normal), delta * 4))

		# Hover along surface normal and slide downhill

		var ground_distance = _get_ground_point().dot(ground_normal)
		var vertical_movement = velocity.dot(ground_normal)
		var K = 7 # Spring constant
		var move_force = ground_distance - (vertical_movement * K * delta)

		var downhill : Vector3 = Vector3.DOWN.cross(ground_normal).cross(ground_normal)

		velocity += ground_normal * move_force
		velocity += downhill * -Globals.GRAVITY * 0.25 * delta

	else:
		# Return player
		global_transform.basis = Basis(racer_quat.slerp(_align_to_normal(Vector3.UP), delta * 2))
		velocity.y -= Globals.GRAVITY * delta

	if is_braking:
		if is_on_ground:
			velocity.x = _interpolate_float(velocity.x, 0, BRAKE_DEACCEL)
			velocity.z = _interpolate_float(velocity.z, 0, BRAKE_DEACCEL)
		else:
			velocity.x = _interpolate_float(velocity.x, 0, AIR_BRAKE_DEACCEL)
			velocity.z = _interpolate_float(velocity.z, 0, AIR_BRAKE_DEACCEL)

	var kinematic_collision = move_and_collide(velocity * delta, false, true, false)
	if kinematic_collision:
		_check_kinematic_collision(kinematic_collision, delta)
		velocity = velocity.slide(kinematic_collision.normal)

#
# Instance spark particles at collisions and send impulses to other KinematicBodies
#
func _check_kinematic_collision(collision : KinematicCollision, delta : float) -> void:
	# Add sparks particles
	if velocity.length() > 10:
		var sparks : Particles = sparks_particles.instance()
		$Sparks.add_child(sparks)
		sparks.transform.origin = to_local(collision.position)
		sparks.emitting = true
		if $Sparks.get_child_count() > 3:
			var oldest : Particles = $Sparks.get_children().front()
			for spark in $Sparks.get_children():
				if spark.time_added < oldest.time_added:
					oldest = spark
			oldest.queue_free()

	# Send impulse to colliding KinematicBody
	if collision.collider.get_class() == "KinematicBody":
		var impulse = -collision.normal.dot(velocity) * velocity.normalized()
		collision.collider.add_collision_impulse(impulse)
#		velocity -= impulse


func add_collision_impulse(impulse : Vector3) -> void:
	velocity += impulse


func _check_ray_collision():
	for ray_detect in $CollisionShape.get_children():
		if ray_detect.type == "Ground":
			if ray_detect.is_colliding():
				is_on_ground = true
			else:
				is_on_ground = false

		elif ray_detect.type == "Side" and ray_detect.is_colliding():
			if ray_detect.global_transform.basis.z.dot(Vector3.DOWN) < -0.66:
				is_crashed = true


# Return the average vector of the normals of the surface the $GroundDetects are colliding with
func _get_ground_normal() -> Vector3:
	var ground_normal1 : Vector3 = $CollisionShape/GroundDetect1.get_collision_normal()
	var ground_normal2 : Vector3 = $CollisionShape/GroundDetect2.get_collision_normal()

#	if ground_normal1 == Vector3.ZERO:
#		ground_normal1 = Vector3.UP
#	if ground_normal2 == Vector3.ZERO:
#		ground_normal2 = Vector3.UP

	return ((ground_normal1 + ground_normal2) * 0.5).normalized()


# Average the collision point of the $GroundDetects and return the local coordinates
func _get_ground_point() -> Vector3:
	var ground_point1 : Vector3 = to_local($CollisionShape/GroundDetect1.get_collision_point())
	var ground_point2 : Vector3 = to_local($CollisionShape/GroundDetect2.get_collision_point())

	# If either ground_detect is not colliding set its point to inverse Z of other ground_detect
	if ground_point1.is_equal_approx(to_local(Vector3.ZERO)):
		ground_point1 = ground_point2 * Vector3(1, 1, -1)
	if ground_point2.is_equal_approx(to_local(Vector3.ZERO)):
		ground_point2 = ground_point1 * Vector3(1, 1, -1)

	return (ground_point1 + ground_point2) * 0.5


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
#	var temp_velocity : Vector2 = Vector2(velocity.x, velocity.z)
	var racer_basis : Basis = global_transform.basis
	var temp_velocity : Vector2 = Vector2(velocity.dot(racer_basis.x), velocity.dot(racer_basis.z))
	var max_speed : float = MAX_BOOST_VEL
	sfx_pitch = ((temp_velocity.length() * (MAX_SFX_PITCH - MIN_SFX_PITCH)) / max_speed) + MIN_SFX_PITCH
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
		is_boosting = false
		_set_boost_sfx()


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
	if horizontal_vel.length() - prev_horizontal_vel.length() < -80:
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
#	global_transform.origin = navigation.get_closest_point(to_global(ground_point))
	global_transform.origin = path.to_global(path.curve.get_closest_point(path.to_local(global_transform.origin)))
	rotation = ground_normal
	$EngineRotationHelper.rotation = Vector3.ZERO
	$EngineRotationHelper/Engine.rotation = Vector3.ZERO
	$CollisionShape.rotation = Vector3.ZERO
	if current_path_node != null:
		look_at(current_path_node.global_transform.origin, Vector3.UP)

	visible = true
	if Globals.race_on_going == true:
		has_control = true
	$CollisionShape.disabled = false
#	$VisibilityTimer.stop()
	ground_particles.emitting = true
	crash_bike.remove_crash()

	is_crashed = false


func _on_VisibilityTimer_timeout() -> void:
	$EngineRotationHelper/Engine.visible = !$EngineRotationHelper/Engine.visible


func add_remove_swing_pole(swing_pole : SwingPole) -> void:
	if swing_poles.has(swing_pole):
		swing_poles.erase(swing_pole)
		$LaserLine.set_laser_line()
	else:
		swing_poles.append(swing_pole)


func _check_swing_poles(delta : float) -> void:
	if !swing_poles.empty():
		var closest_pole : SwingPole = swing_poles.front()
		for swing_pole in swing_poles:
			if global_transform.origin.distance_to(swing_pole.global_transform.origin) < \
					global_transform.origin.distance_to(closest_pole.global_transform.origin):
				closest_pole = swing_pole
		if is_swinging and  boost > 0:
			_swing(closest_pole, delta)
		else:
			$LaserLine.set_laser_line()


func _swing(swing_pole : SwingPole, delta : float) -> void:
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

	$LaserLine.set_laser_line(swing_pole.global_transform.origin)

	_set_boost(swing_cost)


func mod_node_enter(new_mod_node : ModNode) -> void:
	match new_mod_node.function:
#		new_mod_node.FUNCTION.NULL:
#			print("NULL!?")
		new_mod_node.FUNCTION.SET_SPEED:
			_set_target_speed(new_mod_node.value)
#		new_mod_node.FUNCTION.AUDIO_SFX:
#			_set_audio_sfx(new_mod_node.value)


func mod_node_exit(new_mod_node : ModNode) -> void:
	match new_mod_node.function:
#		new_mod_node.FUNCTION.NULL:
#			print("NULL!?")
		new_mod_node.FUNCTION.SET_SPEED:
			_set_target_speed(MAX_FORWARD_VEL)
#		new_mod_node.FUNCTION.AUDIO_SFX:
#			_set_audio_sfx(new_mod_node.value)


func _set_target_speed(new_target_speed : int) -> void:
	pass


func set_racer_color(new_color : Color) -> void:
	bike_color = new_color
#	$EngineRotationHelper/Engine/Shielding.set_surface_material(0, bike_material)
	$EngineRotationHelper/Engine/Windshield.set_surface_material(0, windshield_material)
#
#	bike_material.params_cull_mode = SpatialMaterial.CULL_DISABLED
	windshield_material.params_cull_mode = SpatialMaterial.CULL_DISABLED
	windshield_material.flags_transparent = true
#
#	bike_material.albedo_color = new_color
	yield(get_tree(), "idle_frame")
	var helmet = $EngineRotationHelper/Engine/Rider.get_node("Helmet").get_node("Helmet")
	var visor = $EngineRotationHelper/Engine/Rider.get_node("Helmet").get_node("Visor")
	var spoiler = $EngineRotationHelper/Engine/Rider.get_node("Helmet").get_node("Spoiler")

	$EngineRotationHelper/Engine/Shielding.get_surface_material(0).albedo_color = bike_color
	windshield_material.albedo_color = bike_color
	windshield_material.albedo_color.a = 90.0 / 255.0

	helmet.get_surface_material(0).albedo_color = bike_color
	visor.get_surface_material(0).albedo_color = bike_color
	spoiler.get_surface_material(0).albedo_color = bike_color


func get_racer_color() -> Color:
	if bike_color == null:
		return Color(0.184314, 0.788235, 1)
#	return bike_material.albedo_color
	return bike_color


func _set_audio_sfx(sfx_effect) -> void:
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
