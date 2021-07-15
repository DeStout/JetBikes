class_name ModNode
extends Area

enum FUNCTION {NULL, PATHFIND, SET_SPEED, AUDIO_SFX}
export(FUNCTION) var function = FUNCTION.NULL
export var value : int = 0

func _on_body_entered(body):
	if body.has_method("mod_node_enter"):
		body.mod_node_enter(self)

func _on_body_exited(body):
	if body.has_method("mod_node_exit"):
		body.mod_node_exit(self)
