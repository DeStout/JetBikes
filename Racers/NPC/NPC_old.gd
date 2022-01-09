extends Racer

var target_speed : int = MAX_FORWARD_VEL

var draw_path : ImmediateGeometry = ImmediateGeometry.new()
var simple_path : PoolVector3Array
var current_goal : int = 0


func _process(_delta):
	movement_input = Vector2(0, 1)
	if path_nodes != null:
		_path_point_distance()


func _physics_process(delta : float) -> void:	
	var move_direction : Vector3 = Vector3()
	var npc_basis : Basis = global_transform.basis
	var temp_velocity : Vector3 = velocity
	temp_velocity.y = 0

	if is_on_ground:
		ground_normal = _get_ground_normal()
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
			($CollisionShape/GroundDetect1.cast_to.length() - 0.1) * -0.499, \
			($CollisionShape/GroundDetect2.cast_to.length() - 0.1) * 0.499)
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
		var npc_quat = npc_basis.get_rotation_quat()
		global_transform.basis = Basis(npc_quat.slerp(_align_to_normal(Vector3.UP), delta*4))
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


func _aim() -> void:
	look_at(simple_path[current_goal], global_transform.basis[1])


func _set_target_speed(new_target_speed : int) -> void:
	target_speed = new_target_speed


func _path_point_distance() -> void:
	if simple_path.size() > 0:
		var temp_2D_goal = Vector2(simple_path[current_goal].x, simple_path[current_goal].z)
		var temp_2D_global = Vector2(global_transform.origin.x, global_transform.origin.z)
		if temp_2D_global.distance_to(temp_2D_goal) < 5:
			if current_goal < simple_path.size()-1:
				current_goal += 1
		elif temp_2D_global.distance_to(temp_2D_goal) > 20:
			pathfind_next_node()
	else:
		pathfind_next_node()


func update_path_node(new_path_node : PathNode) -> void:
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
	var path_node_point : Vector3 = current_path_node.get_closest_point(global_transform.origin)
	
	simple_path.empty()
	simple_path = navigation.get_simple_path(global_transform.origin, path_node_point, true)
	current_goal = 0
	
	if Globals.SHOW_NPC_PATHFIND:
		draw_path.clear()
		draw_path.begin(Mesh.PRIMITIVE_LINES)
		draw_path.set_color(Color.red)
		for p in simple_path:
			draw_path.add_vertex(p)
		draw_path.end()