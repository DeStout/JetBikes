class_name ModNode
extends Area

enum FUNCTION {NULL, PATHFIND}
export(FUNCTION) var function = FUNCTION.NULL

func _on_body_entered(body):
	if body.has_method("mod_node_update"):
		body.mod_node_update(self)
