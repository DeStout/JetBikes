extends KinematicBody
class_name PuppetRacer

var master_id : int = 0
var player_name : String

var bike_color : Color
var bike_material : SpatialMaterial = SpatialMaterial.new()
var windshield_material : SpatialMaterial = SpatialMaterial.new()

puppet var puppet_transform : Transform setget _set_puppet_transform
puppet var puppet_velocity : Vector3 = Vector3.ZERO
puppet var puppet_engine_rotation : Basis = Basis(Quat(Vector3.ZERO))

puppet var crashbike_puppet_transform : Transform setget _set_crashbike_transform

var is_crashed : bool = false
var crash_bike : RigidBody

var swing_poles : Array


func _physics_process(delta):
	var puppet_quat = global_transform.basis.get_rotation_quat()
	global_transform.basis = Basis(puppet_quat.slerp(puppet_transform.basis.orthonormalized(), delta))

	var engine_quat = $EngineRotationHelper.transform.basis.get_rotation_quat()
	$EngineRotationHelper.transform.basis = Basis(engine_quat.slerp(puppet_engine_rotation.orthonormalized(), delta))

	move_and_slide(puppet_velocity)


func _set_puppet_transform(new_puppet_transform : Transform) -> void:
	puppet_transform = new_puppet_transform
	global_transform = puppet_transform
#	global_transform.basis.slerp(puppet_transform.basis, 1)


func add_collision_impulse(impulse) -> void:
	pass


puppet func set_crashed(_crashed : bool) -> void:
	if _crashed:
		crash_bike.visible = true

		visible = false
		$CollisionShape.disabled = true
#		_set_boost_sfx()
		$GroundParticles.emitting = false
	else:
		crash_bike.visible = false

		visible = true
		$CollisionShape.disabled = false
		$GroundParticles.emitting = true


func _set_crashbike_transform(new_crashbike_transform : Transform) -> void:
	crashbike_puppet_transform = new_crashbike_transform
	crash_bike.global_transform = crashbike_puppet_transform


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
	var helmet = $EngineRotationHelper/Engine/Rider \
					.get_node("Rider/Skeleton/HelmetAttachment/Helmet").get_node("Helmet")
	var visor = $EngineRotationHelper/Engine/Rider \
					.get_node("Rider/Skeleton/HelmetAttachment/Helmet").get_node("Visor")
	var spoiler = $EngineRotationHelper/Engine/Rider \
					.get_node("Rider/Skeleton/HelmetAttachment/Helmet").get_node("Spoiler")
#	var bootL = $EngineRotationHelper/Engine/Rider.get_node("Boot_L").get_node("Boot")
#	var bootR = $EngineRotationHelper/Engine/Rider.get_node("Boot_R").get_node("Boot")
	var airbag = $EngineRotationHelper/Engine/Rider \
					.get_node("Rider/Skeleton/AirbagAttachment/Airbag").get_node("Airbag")

	$EngineRotationHelper/Engine/Shielding.get_surface_material(0).albedo_color = bike_color
	windshield_material.albedo_color = bike_color
	windshield_material.albedo_color.a = 90.0 / 255.0

	helmet.get_surface_material(0).albedo_color = bike_color
	visor.get_surface_material(0).albedo_color = bike_color
	spoiler.get_surface_material(0).albedo_color = bike_color
#	bootL.get_surface_material(1).albedo_color = bike_color
#	bootR.get_surface_material(1).albedo_color = bike_color
	airbag.get_surface_material(0).albedo_color = bike_color


func get_racer_color() -> Color:
	if bike_material == null:
		return Color(0.184314, 0.788235, 1)
	return bike_color
