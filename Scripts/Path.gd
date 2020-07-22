extends Path

onready var player = get_parent().get_node("Player")
onready var dist_line = get_parent().get_node("ImmediateGeometry")

func _process(delta):
	var closest_point = to_global(curve.get_closest_point(player.global_transform.origin))
#	print(to_global(curve.get_closest_point(player.global_transform.origin)).distance_to(player.global_transform.origin))
	
	dist_line.clear()
	dist_line.begin(Mesh.PRIMITIVE_LINE_STRIP)
	dist_line.add_vertex(player.global_transform.origin)
	dist_line.add_vertex(closest_point)
	dist_line.end()
