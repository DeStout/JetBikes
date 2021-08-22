class_name PuppetRacer
extends Spatial

var bike_material : SpatialMaterial = SpatialMaterial.new()
var windshield_material : SpatialMaterial = SpatialMaterial.new()

var crash_bike : RigidBody


func _ready():
	pass


func set_racer_color(new_color : Color) -> void:
	$Engine/SteeringColumn.set_surface_material(0, bike_material)
	$Engine/WindShield.set_surface_material(0, windshield_material)
	
	bike_material.params_cull_mode = SpatialMaterial.CULL_DISABLED
	windshield_material.params_cull_mode = SpatialMaterial.CULL_DISABLED
	windshield_material.flags_transparent = true
	
	bike_material.albedo_color = new_color
	windshield_material.albedo_color = new_color
	windshield_material.albedo_color.a = 90.0 / 255.0


func get_racer_color() -> Color:
	if bike_material == null:
		return Color(0.184314, 0.788235, 1)
	return bike_material.albedo_color
