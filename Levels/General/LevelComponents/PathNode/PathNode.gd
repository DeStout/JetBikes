tool
extends Spatial
class_name PathNode


export var box_visible : bool = false setget _set_box_visible

enum FUNCTION {DEFAULT, NO_PATHFIND}
export(FUNCTION) var function = FUNCTION.DEFAULT
export var is_checkpoint = true
export var boost_value : int = 50

export var width : float = 20.0 setget _update_box_width
export var height : float = 7.5 setget _update_box_height

export var serial : int = 0 setget _set_next_serial
export var next_serial : int = 0
export var route : int = -1

var box_shape : BoxShape
var node_points : Array = [Vector3.ZERO, Vector3.ZERO]


func _ready() -> void:
	box_shape = BoxShape.new()
	$Area/CollisionShape.shape = box_shape
	box_shape.extents.x = width
	box_shape.extents.y = height
	$Box.width = width * 2
	$Box.height = height * 2
	
	box_shape.connect("changed", self, "_update")
	_update()


func _set_box_visible(new_box_visible : bool) -> void:
	box_visible = new_box_visible
	if has_node("Box"):
		$Box.visible = new_box_visible


func _update_box_width(new_box_width : float) -> void:
	width = new_box_width
	if has_node("Box") and box_shape != null:
		box_shape.extents.x = new_box_width
		$Box.width = new_box_width * 2
		_update()


func _update_box_height(new_box_height : float) -> void:
	height = new_box_height
	if has_node("Box") and box_shape != null:
		box_shape.extents.y = new_box_height
		$Box.height = new_box_height * 2
		_update()


func _set_next_serial(new_serial : int) -> void:
	serial = new_serial
	update_next_serial(true)


func update_next_serial(first : int) -> void:
	if Engine.is_editor_hint():
		next_serial = 0
		if get_parent():
			for sib_serial in get_parent().get_children():
				if sib_serial.serial > serial:
					next_serial = serial + 1
					return
				if first:
					sib_serial.update_next_serial(false)
				property_list_changed_notify()


func _update() -> void:
	node_points[0] = Vector3(box_shape.extents.x, 0, 0)
	node_points[1] = Vector3(-box_shape.extents.x, 0, 0)

#
# Functionality Shit
#
# Given a global point, return the closest global point inside the PathNode
func get_closest_point(point_to : Vector3) -> Vector3:
	point_to = to_local(point_to)
	var node_vector : Vector3 = node_points[1] - node_points[0]
	
	var point_to_node_begin : Vector3 = point_to - node_points[0]
	if node_vector.dot(point_to_node_begin) < 0.0:
		return to_global(node_points[0])
	
	var point_to_node_end : Vector3 = point_to - node_points[1]
	if node_vector.dot(point_to_node_end) > 0.0:
		return to_global(node_points[1])
		
	var intersection_length : float = ((point_to_node_begin.x) * (node_vector.x) + \
		(point_to_node_begin.y) * (node_vector.y) + \
		(point_to_node_begin.z) * (node_vector.z)) / pow(node_vector.length(), 2)
	var closest_point : Vector3 = Vector3(node_points[0].x + intersection_length * node_vector.x, \
	node_points[0].y + intersection_length * node_vector.y, \
	node_points[0].z + intersection_length * node_vector.z)
	return to_global(closest_point)


# Given a global point, return the distance to the closest global point inside the PathNode
func get_closest_point_distance(point_to : Vector3) -> float:
	return get_closest_point(point_to).distance_to(point_to)


func _on_Area_body_entered(body) -> void:
	if body.has_method("update_path_node"):
		body.update_path_node(self)
