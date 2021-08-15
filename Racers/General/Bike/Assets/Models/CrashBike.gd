extends RigidBody

const DEFAULT_POSITION : Vector3 = Vector3(0, -100, 0)

func _ready():
	visible = false
	global_transform.origin = DEFAULT_POSITION

func set_materials(bike_mat, windshield_mat):
	$SteeringColumn.set_surface_material(0, bike_mat)
	$WindShield.set_surface_material(0, windshield_mat)

func set_crash(racer : Racer):
	if racer.has_node("Engine"):
		global_transform = racer.get_node("Engine").global_transform
#	set_collision_layer_bit(0, true)
	$CollisionShape.disabled = false
	visible = true
	apply_central_impulse(racer.velocity)
	
func remove_crash():
	global_transform.origin = DEFAULT_POSITION
	$CollisionShape.disabled = true
	visible = false
