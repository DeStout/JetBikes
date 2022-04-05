extends Control

signal track_loaded

var loader : ResourceInteractiveLoader
var poll_msg : int


func _ready():
	set_process(false)


func _process(delta):
	poll_msg = loader.poll()

	if poll_msg == OK || poll_msg == ERR_FILE_EOF:
		$BG/MenuFrame/ProgressBar.value = float(loader.get_stage()) / float(loader.get_stage_count()) * 100
	else:
		print("Error loading level: ", poll_msg)

	if poll_msg == ERR_FILE_EOF:
		set_process(false)
		emit_signal("track_loaded", loader.get_resource())


func load_track(new_track) -> void:
	loader = ResourceLoader.load_interactive(new_track)
	set_process(true)
