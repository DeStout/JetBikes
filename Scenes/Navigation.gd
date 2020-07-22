extends Navigation

onready var start_point = get_closest_point($Start.translation)
onready var end_point = get_closest_point($End.translation)
onready var nav_path = get_node("ImmediateGeometry")

func _ready():
	var path = get_simple_path(start_point, end_point)
	print(path)
	
	nav_path.clear()
	nav_path.begin(Mesh.PRIMITIVE_LINE_STRIP)
	for p in path:
		nav_path.add_vertex(p)
	nav_path.end()
	
	
