class_name PuppetRacer
extends KinematicBody

var master_id : int = 0
var player_name : String

var bike_material : SpatialMaterial = SpatialMaterial.new()
var windshield_material : SpatialMaterial = SpatialMaterial.new()

puppet var puppet_transform : Transform setget _set_puppet_transform
puppet var puppet_velocity : Vector3 = Vector3.ZERO
puppet var puppet_engine_rotation : Basis = Basis(Quat(Vector3.ZERO))

var crash_bike : RigidBody

var swing_poles : Array


func _process(delta):
#	global_transform.basis.slerp(puppet_transform.basis, delta)
	$Engine.global_transform.basis.slerp(puppet_engine_rotation, delta)
	move_and_slide(puppet_velocity)


func _set_puppet_transform(new_puppet_transform : Transform) -> void:
	puppet_transform = new_puppet_transform
	global_transform = puppet_transform
#	global_transform.basis.slerp(puppet_transform.basis, 1)


func add_remove_swing_pole(swing_pole : SwingPole):
	if swing_poles.has(swing_pole):
		swing_poles.erase(swing_pole)
		$LaserLine.set_laser_line()
	else:
		swing_poles.append(swing_pole)


puppet func swing(var is_swinging : bool):
	if is_swinging:
		if !swing_poles.empty():
			var closest_pole : SwingPole = swing_poles.front()
			for swing_pole in swing_poles:
				if global_transform.origin.distance_to(swing_pole.global_transform.origin) < \
						global_transform.origin.distance_to(closest_pole.global_transform.origin):
					closest_pole = swing_pole
			$LaserLine.set_laser_line(closest_pole.global_transform.origin)
	else:
		$LaserLine.set_laser_line()


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
