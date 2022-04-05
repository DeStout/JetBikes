extends PathFollow
tool

signal path_finished

const speed : int = 35
export var follow := false


#func _ready():
#	if !Engine.editor_hint:
#		follow = true


func _process(delta):
	offset += speed * int(follow) * delta

	if unit_offset >= 1.0:
		emit_signal("path_finished")
		end_preview()


func start_preview() -> void:
	follow = true


func end_preview() -> void:
	follow = false
	unit_offset = 0.0
