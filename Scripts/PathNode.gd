class_name PathNode
tool
extends Spatial

export var serial = 0 setget _set_next_serial
export var next_serial = 0

var center_point : Vector3

onready var path = $Path

func _ready():
	center_point = to_global((path.curve.get_point_position(0) + path.curve.get_point_position(1)) / 2)
	
#	var geom = $ImmediateGeometry
#	geom.clear()
#	geom.begin(Mesh.PRIMITIVE_LINE_STRIP)
#	geom.add_vertex(path.curve.get_point_position(0))
#	geom.add_vertex(path.curve.get_point_position(1))
#	geom.end()
	
func _set_next_serial(new_serial):
	serial = new_serial
	update_next_serial(true)
		
func update_next_serial(first):
	if Engine.is_editor_hint():
		next_serial = 0
		for sib_serial in get_parent().get_children():
			if sib_serial.serial > serial:
				next_serial = serial + 1
				return
			if first:
				sib_serial.update_next_serial(false)
			property_list_changed_notify()
