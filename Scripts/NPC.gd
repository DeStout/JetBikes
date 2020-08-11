class_name NPC
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

var has_control: bool = false
var is_boosting : bool = false
var is_braking : bool = false
var is_on_ground : bool = false

var prev_ground_distance : float = 0

signal race_finished
var lap_number : int = 0
var checkpoint_number : int = 0
var placement : int = 0

onready var navigation : Navigation = get_parent().get_parent().get_node("Minimap/Navigation")
onready var path_nodes : Array = navigation.get_node("PathNodes").get_children()
onready var player : Player = get_parent().get_node("Player")

var draw_path : ImmediateGeometry = ImmediateGeometry.new()
var simple_path : PoolVector3Array
var current_goal : int = 0
onready var current_path_node : PathNode = path_nodes[0]
var path_node_distance : float

func _ready():
	path_nodes = _setup_path_nodes()
	_pathfind_next_node()
	
func _process(_delta):
	if global_transform.origin.distance_to(player.global_transform.origin) < 5:
		movement_input = Vector2.ZERO
		is_braking = true
	else:
		movement_input = Vector2(0, 1)
		is_braking = false
	_path_point_distance()
	_path_node_distance()
	
func _physics_process(delta : float) -> void:
	var move_direction : Vector3 = Vector3()
	var npc_basis : Basis = global_transform.basis
	var temp_velocity : Vector3 = velocity
	temp_velocity.y = 0

	if is_on_ground and has_control:
		var ground_normal : Vector3 = _get_ground_normal()

		# Apply acceleration/deacceleration along player X vector based on input
		if !is_braking:
			if movement_input.x != 0:
				var delta_move : Vector3 = npc_basis[0] * movement_input.x * STRIFE_ACCELERATION
				var strife_vel : Vector3 = npc_basis[0].dot(temp_velocity) * temp_velocity.normalized()
				if abs((strife_vel + delta_move).length()) < MAX_STRIFE_VEL:
					move_direction += delta_move
			else:
				move_direction -= npc_basis[0].dot(temp_velocity) * npc_basis[0].normalized() * DEACCELERATION

			# Apply acceleration/deacceleration along player Z vector based on input
			if movement_input.y > 0:
				if !is_boosting:
					var delta_move : Vector3 = npc_basis[2] * -movement_input.y * FORWARD_ACCELERATION
					var forward_vel : Vector3 = npc_basis[2].dot(temp_velocity) * temp_velocity.normalized()
					if abs((forward_vel + delta_move).length()) < MAX_FORWARD_VEL:
						move_direction += delta_move
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

		# Align player Y vector to ground normal
		_aim()
		if npc_basis[1].dot(ground_normal) > 0:
			global_transform.basis = npc_basis.slerp(_align_to_normal(ground_normal), delta*4)

		# Hover along surface normal and slide downhill
		var downhill : Vector3 = Vector3(0, -1, 0).cross(ground_normal).cross(ground_normal)
		var cast_point : Vector3 = _get_cast_point()
		var ground_point : Vector3 = _get_ground_point()

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
		move_direction += downhill * -GRAVITY * 0.25

		prev_ground_distance = ground_distance

	else:
		global_transform.basis = Quat(npc_basis).slerp(_align_to_normal(Vector3(0, 1, 0)), delta*10)
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
	
func _aim() -> void:
	look_at(simple_path[current_goal], global_transform.basis[1])

func _setup_path_nodes() -> Array:
	var path_nodes_array = []
	var i : int = 0
	var j : int = 1
	while i + j <= path_nodes.size():
		var temp_array = []
		while i + j <= path_nodes.size() - 1:
			if path_nodes[i].serial != path_nodes[i + j].serial:
				break;
			j += 1
		if j > 1:
			for k in range(j):
				temp_array.append(path_nodes[k+i])
			path_nodes_array.append(temp_array)
		else:
			path_nodes_array.append(path_nodes[i])
		i += j
		j = 1
	return path_nodes_array
	
func start_race() -> void:
	has_control = true
		
func _path_point_distance() -> void:
	var temp_2D_goal = Vector2(simple_path[current_goal].x, simple_path[current_goal].z)
	var temp_2D_global = Vector2(global_transform.origin.x, global_transform.origin.z)
#	if simple_path[current_goal].distance_to(global_transform.origin) < 10:
	if temp_2D_global.distance_to(temp_2D_goal) < 25:
		if current_goal < simple_path.size()-1:
			current_goal += 1

func update_path_node(var new_path_node : PathNode) -> void:
	if current_path_node == new_path_node:
		if current_path_node.serial == 0:
			lap_number += 1
			if lap_number > Globals.laps_number:
				emit_signal("race_finished")
		if typeof(path_nodes[new_path_node.next_serial]) == TYPE_ARRAY:
			var temp_array = path_nodes[new_path_node.next_serial]
			if current_path_node.route >= 0:
				current_path_node = temp_array[current_path_node.route]
			else:
				current_path_node = temp_array[randi() % temp_array.size()]
		else:
			current_path_node = path_nodes[current_path_node.next_serial]
		
		if new_path_node.function == new_path_node.FUNCTION.DEFAULT:
			_pathfind_next_node()
			
func mod_node_update(var new_mod_node : ModNode) -> void:
	match new_mod_node.function:
		new_mod_node.FUNCTION.NULL:
			print("NULL!?")
		new_mod_node.FUNCTION.PATHFIND:
			_pathfind_next_node()

func _path_node_distance() -> void:
	var npc_to_path_node_local : Vector3 = current_path_node.to_local(global_transform.origin)
	var path_node_point : Vector3 = current_path_node.path.curve.get_closest_point(npc_to_path_node_local)
	path_node_distance = current_path_node.to_global(path_node_point).distance_to(global_transform.origin)
		
func _pathfind_next_node() -> void:
	var npc_to_path_node_local : Vector3 = current_path_node.to_local(global_transform.origin)
	var path_node_point : Vector3 = current_path_node.path.curve.get_closest_point(npc_to_path_node_local)
	
	simple_path.empty()
	simple_path = navigation.get_simple_path(global_transform.origin, \
		current_path_node.to_global(path_node_point), true)
	current_goal = 0
#	print(name + ": " + current_path_node.name)
	
	if Globals.SHOW_NPC_PATHFIND:
		draw_path.clear()
		draw_path.begin(Mesh.PRIMITIVE_LINE_STRIP)
		for p in simple_path:
			draw_path.add_vertex(p)
		draw_path.end()

func _interpolate_float(current: float, target: float, amount: float) -> float:
	current += amount * sign(target - current)
	if abs(target - current) <= abs(amount):
		current = target
	return current
