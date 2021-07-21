extends Area
tool
class_name SwingPole

export var sphere_visible : bool = true setget _set_sphere_visible
export var swing_length : float = 16.0 setget _set_swing_length
export var swing_strength : float = 0.3

onready var laser_line = $LaserLine

var influence_sphere = SphereShape.new()

func _ready():
	$InfluenceArea.shape = influence_sphere
	influence_sphere.radius = swing_length
	$Sphere.radius = swing_length

# Tool Shit
func _set_sphere_visible(new_visible : bool):
	sphere_visible = new_visible
	if has_node("Sphere"):
		$Sphere.visible = new_visible

func _set_swing_length(new_sphere_size : float):
	swing_length = new_sphere_size
	if has_node("Sphere") and has_node("InfluenceArea"):
		$Sphere.radius = new_sphere_size
		$InfluenceArea.shape.radius = new_sphere_size


# Functionality Shit
func set_laser_line(laser_to : Vector3 = to_global(laser_line.LASER_DEFAULT_POSITION)):
	laser_line.points[1] = to_local(laser_to)
	
#	if laser_to != to_global(laser_line.LASER_DEFAULT_POSITION):
#		laser_line.play_sfx(true)
#	else:
#		laser_line.play_sfx(false)
	
func _racer_within_influence(body):
	if body.has_method("add_remove_swing_pole"):
		body.add_remove_swing_pole(self)

func _racer_without_influence(body):
	if body.has_method("add_remove_swing_pole"):
		body.add_remove_swing_pole(self)
		laser_line.points[1] = laser_line.LASER_DEFAULT_POSITION
