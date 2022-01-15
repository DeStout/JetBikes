extends PathFollow
tool

const speed : int = 50
export var follow := false


func _ready():
	if !Engine.editor_hint:
		follow = true


func _process(delta):
	offset += speed * int(follow) * delta
