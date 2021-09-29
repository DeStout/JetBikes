tool
extends Area
class_name SwingPole

export var disabled : bool = false
export var sphere_visible : bool = true setget _set_sphere_visible
export var swing_length : float = 16.0 setget _set_swing_length
export var swing_strength : float = 0.05

var influence_sphere : SphereShape

func _ready():
	influence_sphere = SphereShape.new()
	$InfluenceArea.shape = influence_sphere
	influence_sphere.radius = swing_length
	$Sphere.radius = swing_length

#
# Tool Shit
#
func _set_sphere_visible(new_visible : bool):
	sphere_visible = new_visible
	if has_node("Sphere"):
		$Sphere.visible = new_visible

func _set_swing_length(new_sphere_size : float):
	swing_length = new_sphere_size
	if has_node("Sphere") and has_node("InfluenceArea"):
		$Sphere.radius = new_sphere_size
		$InfluenceArea.shape.radius = new_sphere_size


#
# Functionality Shit
#
func _racer_within_influence(body):
	if !disabled:
		if body.has_method("add_remove_swing_pole"):
			body.add_remove_swing_pole(self)

func _racer_without_influence(body):
	if !disabled:
		if body.has_method("add_remove_swing_pole"):
			body.add_remove_swing_pole(self)
