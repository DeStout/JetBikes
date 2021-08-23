extends RigidBody

const DEFAULT_POSITION : Vector3 = Vector3(0, -100, 0)

var bike_material : SpatialMaterial = SpatialMaterial.new()
var windshield_material : SpatialMaterial = SpatialMaterial.new()

func _ready():
	visible = false
	global_transform.origin = DEFAULT_POSITION


func set_bike_color(new_color : Color) -> void:
	$SteeringColumn.set_surface_material(0, bike_material)
	$WindShield.set_surface_material(0, windshield_material)
	
	bike_material.params_cull_mode = SpatialMaterial.CULL_DISABLED
	windshield_material.params_cull_mode = SpatialMaterial.CULL_DISABLED
	windshield_material.flags_transparent = true
	
	bike_material.albedo_color = new_color
	windshield_material.albedo_color = new_color
	windshield_material.albedo_color.a = 90.0 / 255.0


func set_crash(racer : Racer):
	if racer.has_node("EngineRotationHelper/Engine"):
		global_transform = racer.get_node("EngineRotationHelper/Engine").global_transform
#	set_collision_layer_bit(0, true)
	$CollisionShape.disabled = false
	visible = true
	apply_central_impulse(racer.velocity)


func remove_crash():
	global_transform.origin = DEFAULT_POSITION
	$CollisionShape.disabled = true
	visible = false
