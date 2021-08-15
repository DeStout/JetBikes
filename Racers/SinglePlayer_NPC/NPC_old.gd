extends KinematicBody
#class_name NPC

signal finished_race

const FORWARD_ACCELERATION : float  = 0.85
const STRIFE_ACCELERATION : float  = 0.65
const REVERSE_ACCELERATION : float  = 0.65
const BOOST_ACCELERATION : float  = 1.1
const DEACCELERATION : float  = 0.025
const BRAKE_DEACCEL : float  = 1.5
const AIR_BRAKE_DEACCEL : float  = 0.5

const MAX_SPEED : int = 180
const MAX_FORWARD_VEL : int = 90
const MAX_STRIFE_VEL : int = 50
const MAX_REVERSE_VEL : int =  75
const MAX_BOOST_VEL : int = 120
const TURN_SPEED : int = 6

const MIN_SFX_PITCH : float = 1.5
const MAX_SFX_PITCH : float = 4.0

var movement_input : Vector2 = Vector2.ZERO
var velocity: Vector3 = Vector3.ZERO
var prev_velocity : Vector3 = Vector3.ZERO
var target_speed : int = MAX_FORWARD_VEL

var sfx_pitch : float = MIN_SFX_PITCH

var has_control: bool = false
var is_boosting : bool = false
var is_braking : bool = false
var is_on_ground : bool = false

var ground_point : Vector3
var prev_ground_distance : float = 0

var lap_number : int = 0
var checkpoint_number : int = 0
var placement : int = 0

onready var navigation : Navigation
onready var path_nodes : Array

var draw_path : ImmediateGeometry = ImmediateGeometry.new()
var simple_path : PoolVector3Array
var current_goal : int = 0
onready var current_path_node : PathNode
var path_node_distance : float
onready var ground_particles : Particles = $GroundParticles

func _ready():
	is_braking = true
	
func _process(_delta):
	movement_input = Vector2(0, 1)
	if path_nodes != null:
		_path_point_distance()
		_path_node_distance()
	_pitch_sfx()
	_emit_trail_particles()
	
func _physics_process(delta : float) -> void:
	_check_out_of_bounds()
	_check_crash()
	
	var move_direction : Vector3 = Vector3()
	var npc_basis : Basis = global_transform.basis
	var temp_velocity : Vector3 = velocity
	temp_velocity.y = 0

	if is_on_ground:
		var ground_normal : Vector3 = _get_ground_normal()
		# Apply acceleration/deacceleration along NPC X vector based on input
		if has_control:
#			if !is_braking:
			if movement_input.x != 0:
				var delta_move : Vector3 = npc_basis[0] * movement_input.x * STRIFE_ACCELERATION
				var strife_vel : Vector3 = npc_basis[0].dot(temp_velocity) * temp_velocity.normalized()
				if abs((strife_vel + delta_move).length()) < MAX_STRIFE_VEL:
					move_direction += delta_move
			else:
				move_direction -= npc_basis[0].dot(temp_velocity) * npc_basis[0].normalized() * DEACCELERATION

			# Apply acceleration/deacceleration along NPC Z vector based on input
			if movement_input.y > 0:
				if !is_boosting:
					var delta_move : Vector3 = npc_basis[2] * -movement_input.y * FORWARD_ACCELERATION
					var forward_vel : Vector3 = npc_basis[2].dot(temp_velocity) * temp_velocity.normalized()
					if abs((forward_vel + delta_move).length()) < target_speed:
						is_braking = false
						move_direction += delta_move
					elif abs((forward_vel + delta_move).length()) - target_speed > MAX_FORWARD_VEL * 0.2:
						is_braking = true
					else:
						is_braking = false
				else:
					var delta_move : Vector3 = npc_basis[2] * -movement_input.y * BOOST_ACCELERATION
					var boost_vel : Vector3 = npc_basis[2].dot(temp_velocity) * temp_velocity.normalized()
					if abs((boost_vel + delta_move).length()) < MAX_BOOST_VEL:
						move_direction += delta_move
			elif movement_input.y < 0:
				var delta_move : Vector3 = npc_basis[2] * -movement_input.y * REVERSE_ACCELERATION
				var reverse_vel : Vector3 = npc_basis[2].dot(temp_velocity) * temp_velocity.normalized()
				if abs((reverse_vel + delta_move).length()) < MAX_REVERSE_VEL:
					move_direction += delta_move
			else:
				move_direction -= npc_basis[2].dot(temp_velocity) * npc_basis[2] * DEACCELERATION
		

		# Align NPC Y vector to ground normal
		_aim()
		if npc_basis[1].dot(ground_normal) > 0:
			var npc_quat = npc_basis.get_rotation_quat()
			global_transform.basis = Basis(npc_quat.slerp(_align_to_normal(ground_normal), delta*4))

		# Hover along surface normal and slide downhill
		var downhill : Vector3 = Vector3(0, -1, 0).cross(ground_normal).cross(ground_normal)
		var cast_point : Vector3 = _get_cast_point()
		ground_point = _get_ground_point()

		var ground_distance : float = clamp(cast_point.length() - ground_point.length(), \
			($GroundDetect1.cast_to.length() - 0.1) * -0.499, \
			($GroundDetect1.cast_to.length() - 0.1) * 0.499)
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
		global_transform.basis = npc_basis.slerp(_align_to_normal(Vector3(0, 1, 0)), delta*10).orthonormalized()
		prev_ground_distance = 0
		move_direction = Vector3(0, -Globals.GRAVITY, 0)
	move_direction += _check_kinematic_collision()

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

	is_on_ground = false
	
func _pitch_sfx():
	sfx_pitch = ((velocity.length() * MAX_SFX_PITCH) / MAX_SPEED) + MIN_SFX_PITCH
	sfx_pitch = clamp(sfx_pitch, MIN_SFX_PITCH, MAX_SFX_PITCH)
	$Audio_Jet.pitch_scale = sfx_pitch
	$Audio_Diesel.pitch_scale = sfx_pitch

# Helper function to align player with the ground normal
func _align_to_normal(ground_normal : Vector3) -> Quat:
	var result : Basis = Basis()
	result.y = ground_normal.normalized()
	result.x = ground_normal.cross(global_transform.basis.z).normalized()
	result.z = result.x.cross(result.y).normalized()
	return result.orthonormalized().get_rotation_quat()

# Called by signal if $GroundDetects are colliding
func _is_on_ground() -> void:
	if !is_on_ground:
		is_on_ground = true
	
# Return the average vector of the normals of the surface the $GroundDetects are colliding with
func _get_ground_normal() -> Vector3:
	var ground_normal1 : Vector3 = $GroundDetect1.get_collision_normal()
	var ground_normal2 : Vector3 = $GroundDetect2.get_collision_normal()
	return ((ground_normal1 + ground_normal2) * 0.5).normalized()

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
	
func _aim() -> void:
	look_at(simple_path[current_goal], global_transform.basis[1])
	
func start_race() -> void:
	has_control = true
	is_braking = false
	
func finish_race() -> void:
	has_control = false
	is_braking = true

func _set_target_speed(var new_speed : int) -> void:
	target_speed = new_speed

func _set_audio_sfx(var sfx_effect : int) -> void:
		var effect_enabled : bool = AudioServer.is_bus_effect_enabled(Globals.npc_bus, sfx_effect)
		AudioServer.set_bus_effect_enabled(Globals.npc_bus, sfx_effect, !effect_enabled)

func _path_node_distance() -> void:
#	var npc_to_path_node_local : Vector3 = current_path_node.to_local(global_transform.origin)
#	var path_node_point : Vector3 = current_path_node.path.curve.get_closest_point(npc_to_path_node_local)
#	path_node_distance = current_path_node.to_global(path_node_point).distance_to(global_transform.origin)
	path_node_distance = current_path_node.get_closest_point_distance(global_transform.origin)
		
func _path_point_distance() -> void:
	var temp_2D_goal = Vector2(simple_path[current_goal].x, simple_path[current_goal].z)
	var temp_2D_global = Vector2(global_transform.origin.x, global_transform.origin.z)
	if temp_2D_global.distance_to(temp_2D_goal) < 15:
		if current_goal < simple_path.size()-1:
			current_goal += 1
	elif temp_2D_global.distance_to(temp_2D_goal) > 20:
		pathfind_next_node()

func update_path_node(var new_path_node : PathNode) -> void:
	if current_path_node == new_path_node:
		if current_path_node.serial == 0:
			lap_number += 1
			if lap_number > Globals.laps_number:
				emit_signal("finished_race", self)
		if typeof(path_nodes[new_path_node.next_serial]) == TYPE_ARRAY:
			var temp_array = path_nodes[new_path_node.next_serial]
			if current_path_node.route >= 0:
				current_path_node = temp_array[current_path_node.route]
			else:
				current_path_node = temp_array[randi() % temp_array.size()]
		else:
			current_path_node = path_nodes[current_path_node.next_serial]
		
		if new_path_node.function == new_path_node.FUNCTION.DEFAULT:
			pathfind_next_node()
		
func pathfind_next_node() -> void:
#	var npc_to_path_node_local : Vector3 = current_path_node.to_local(global_transform.origin)
#	var path_node_point : Vector3 = current_path_node.path.curve.get_closest_point(npc_to_path_node_local)
	var path_node_point : Vector3 = current_path_node.get_closest_point(global_transform.origin)
	
	simple_path.empty()
	simple_path = navigation.get_simple_path(global_transform.origin, path_node_point, true)
	current_goal = 0
	
	if Globals.SHOW_NPC_PATHFIND:
		draw_path.clear()
		draw_path.begin(Mesh.PRIMITIVE_LINE_STRIP)
		for p in simple_path:
			draw_path.add_vertex(p)
		draw_path.end()
			
func mod_node_enter(var new_mod_node : ModNode) -> void:
	match new_mod_node.function:
#		new_mod_node.FUNCTION.NULL:
#			print("NULL!?")
		new_mod_node.FUNCTION.PATHFIND:
			pathfind_next_node()
		new_mod_node.FUNCTION.SET_SPEED:
			_set_target_speed(new_mod_node.value)
		new_mod_node.FUNCTION.AUDIO_SFX:
			_set_audio_sfx(new_mod_node.value)

func mod_node_exit(var new_mod_node : ModNode) -> void:
	match new_mod_node.function:
#		new_mod_node.FUNCTION.NULL:
#			print("NULL!?")
		new_mod_node.FUNCTION.PATHFIND:
			pass
		new_mod_node.FUNCTION.SET_SPEED:
			_set_target_speed(MAX_FORWARD_VEL)
		new_mod_node.FUNCTION.AUDIO_SFX:
			_set_audio_sfx(new_mod_node.value)

func _emit_trail_particles():
	if is_on_ground:
		$Particles.emitting = true
	else:
		$Particles.emitting = false

func _check_kinematic_collision():
	if get_slide_count():
		for i in get_slide_count():
			var collision : KinematicCollision = get_slide_collision(i)
			if collision.collider.get_class() == "KinematicBody":
#				var collision_factor : float = 1 - velocity.normalized().dot(collision.collider_velocity.normalized())
				return collision.collider_velocity - velocity
	return Vector3.ZERO

func _check_out_of_bounds():
	if global_transform.origin.y < -70:
		global_transform.origin = navigation.get_closest_point(to_global(ground_point))
		_crash()
		velocity = Vector3.ZERO
	
func _check_crash():
	var prev_horizontal_vel = Vector2(prev_velocity.x, prev_velocity.z)
	var horizontal_vel = Vector2(velocity.x, velocity.z)
	if horizontal_vel.length() - prev_horizontal_vel.length() < -75:
		_crash()

func _crash():
	velocity = Vector3.ZERO
	has_control = !has_control
	if has_control:
#		set_collision_layer_bit(0, true)
		set_collision_mask_bit(0, true)
		$VisibilityTimer.stop()
		$Engine.visible = true
#		_unmute_player_sfx()
	else:
#		set_collision_layer_bit(0, false)
		set_collision_mask_bit(0, false)
		$CrashTimer.start()
		$VisibilityTimer.start()
#		_mute_player_sfx()

func _on_VisibilityTimer_timeout():
	$Engine.visible = !$Engine.visible
	
func _interpolate_float(current: float, target: float, amount: float) -> float:
	current += amount * sign(target - current)
	if abs(target - current) <= abs(amount):
		current = target
	return current
