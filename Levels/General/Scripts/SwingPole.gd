extends Spatial
tool
class_name SwingPole

export var sphere_visible : bool = true setget _set_sphere_visible
export var swing_length : float = 16.0 setget _set_swing_length
export var swing_strength : float = 0.3

func _set_sphere_visible(new_visible : bool):
	sphere_visible = new_visible
	$Sphere.visible = new_visible

func _set_swing_length(new_sphere_size : float):
	swing_length = new_sphere_size
	$Sphere.radius = new_sphere_size
