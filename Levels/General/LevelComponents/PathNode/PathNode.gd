extends Spatial
class_name PathNode
tool

enum FUNCTION {DEFAULT, NO_PATHFIND}
export(FUNCTION) var function = FUNCTION.DEFAULT
export var is_checkpoint = true

export var serial : int = 0 setget _set_next_serial
export var next_serial : int = 0
export var route : int = -1
export var boost_value : int = 40

var node_points : Array = [Vector3.ZERO, Vector3.ZERO]
var box_shape_extents : Vector3

func _ready():
	if Engine.editor_hint:
		if !is_instance_valid($Area/CollisionShape.shape):
			$Area/CollisionShape.shape = BoxShape.new()
	$Area/CollisionShape.shape.connect("changed", self, "_update")
		
	box_shape_extents = $Area/CollisionShape.shape.extents
	
	_update()

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
	
func _set_next_serial(new_serial):
	serial = new_serial
	update_next_serial(true)
		
func update_next_serial(first):
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
				
func _update():
	node_points[0] = Vector3(box_shape_extents[0], 0, 0)
	node_points[1] = Vector3(-box_shape_extents[0], 0, 0)

func _on_Area_body_entered(body):
	if body.has_method("update_path_node"):
		body.update_path_node(self)
