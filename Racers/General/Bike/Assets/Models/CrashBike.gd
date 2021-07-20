extends RigidBody

const DEFAULT_POSITION : Vector3 = Vector3(0, -100, 0)

func _ready():
	visible = false
	global_transform.origin = DEFAULT_POSITION

func set_crash(player : Player):
	global_transform = player.get_node("Engine").global_transform
#	set_collision_layer_bit(0, true)
	$CollisionShape.disabled = false
	visible = true
	apply_central_impulse(player.velocity)
	
func remove_crash():
	global_transform.origin = DEFAULT_POSITION
#	set_collision_layer_bit(0, false)
	$CollisionShape.disabled = true
	visible = false
