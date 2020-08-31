class_name PathNode
tool
extends Spatial

enum FUNCTION {DEFAULT, NO_PATHFIND}
export(FUNCTION) var function = FUNCTION.DEFAULT

export var serial : int = 0 setget _set_next_serial
export var next_serial : int = 0
export var route : int = -1
export var boost_value : int = 25

onready var draw : ImmediateGeometry = $ImmediateGeometry
onready var path : Path = $Path
var box_shape_extents : Vector3

func _ready():
	if Engine.editor_hint:
		if !is_instance_valid($Area/CollisionShape.shape):
			$Area/CollisionShape.shape = BoxShape.new()
	$Area/CollisionShape.shape.connect("changed", self, "update_path")
		
	box_shape_extents = $Area/CollisionShape.shape.extents
	$Path.curve = Curve3D.new()
	
	update_path()
	
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
				
func update_path():
	for i in range(-1, 2, 2):
		path.curve.add_point(Vector3(i * box_shape_extents[0], 0, 0))
	draw.clear()
	draw.begin(Mesh.PRIMITIVE_LINE_STRIP)
	for i in range(path.curve.get_point_count()):
		draw.add_vertex(path.curve.get_point_position(i))
	draw.end()

func _on_Area_body_entered(body):
	if body.has_method("update_path_node"):
		body.update_path_node(self)
#		print(body.name + ": " + self.name)
