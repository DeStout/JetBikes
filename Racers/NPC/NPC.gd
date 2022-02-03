extends Racer
class_name NPC

var target_speed : int = MAX_FORWARD_VEL

var path_follow : PathFollow
var draw_path : ImmediateGeometry = ImmediateGeometry.new()
var simple_path : PoolVector3Array
var current_goal : int = 0


func _process(_delta):
	movement_input = Vector2(0, 1)
#	if path_nodes != null:
#		_path_point_distance()


func _physics_process(delta : float) -> void:
	var move_direction : Vector3 = Vector3()
	var npc_basis : Basis = global_transform.basis
	var temp_velocity : Vector3 = velocity
	temp_velocity.y = 0

	if is_on_ground:
		# Apply acceleration/deacceleration along NPC X vector based on input
		if has_control:
			if movement_input.x != 0:
				var delta_move : Vector3 = npc_basis[0] * movement_input.x * STRIFE_ACCELERATION
				var strife_vel : Vector3 = npc_basis[0].dot(temp_velocity) * temp_velocity.normalized()
				if abs((strife_vel + delta_move).length()) < MAX_STRIFE_VEL:
					move_direction += delta_move
			else:
				move_direction -= npc_basis[0].dot(temp_velocity) * npc_basis[0].normalized() * DEACCELERATION

#			# Apply acceleration/deacceleration along NPC Z vector based on input
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

		_aim(delta)

	velocity += move_direction


func start_race() -> void:
	.start_race()
	path_follow.follow = true


func finish_race() -> void:
	.finish_race()
	path_follow.follow = false


func _aim(delta) -> void:
	var look_at = global_transform.looking_at(path_follow.global_transform.origin, global_transform.basis.y)
	global_transform = global_transform.interpolate_with(look_at, TURN_SPEED * delta)


func _crash() -> void:
	._crash()
	path_follow.follow = false


func _crash_finished() -> void:
	._crash_finished()
	path_follow.follow = true


func _set_target_speed(new_target_speed : int) -> void:
	target_speed = new_target_speed


func update_path_node(new_path_node : PathNode) -> void:
	if current_path_node == new_path_node:
		if current_path_node.serial == 0:
			lap_number += 1
			if lap_number > Globals.laps_number:
				emit_signal("finished_race", self)
		if typeof(path_nodes[new_path_node.next_serial]) == TYPE_ARRAY:
			var temp_array = path_nodes[new_path_node.next_serial]
			current_path_node = temp_array[0]
#			if current_path_node.route >= 0:
#				current_path_node = temp_array[current_path_node.route]
#			else:
#				current_path_node = temp_array[randi() % temp_array.size()]
		else:
			current_path_node = path_nodes[current_path_node.next_serial]
