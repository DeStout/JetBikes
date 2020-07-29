extends Spatial

onready var nav = get_parent().get_parent().get_node("Navigation")
onready var npc = get_parent()
#onready var path = nav.get_node("Path")

var simple_path : PoolVector3Array
var current_goal : int = 0

signal next_goal

func _ready():
	connect("next_goal", get_parent(), "set_goal")
	
	simple_path = nav.get_simple_path(npc.global_transform.origin, global_transform.origin, true)
	
#	path.clear()
#	path.begin(Mesh.PRIMITIVE_LINE_STRIP)
#	for p in simple_path:
#		print(p)
#		path.add_vertex(p)
#	path.end()
	
	emit_signal("next_goal", simple_path[current_goal])
	
func _process(delta):
	if simple_path[current_goal].distance_to(npc.global_transform.origin) < 25:
		if simple_path.size() - 1 > current_goal:
			current_goal += 1
			emit_signal("next_goal", simple_path[current_goal])
