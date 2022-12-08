extends Node

const MAX_FRAME_COUNT : int = 60
const MAX_STDDEV_COUNT : int = 10

signal preview_finished

var preview_camera = preload("res://Tracks/Assets/TrackComponents/PreviewCamera.tscn")
var paths : Array
var path_index := 0

var frame_count : int = 0
var frames : Array = []
var std_devs : Array = []
var std_dev : float
var mean_std_dev : float = 0


func _ready():
	set_process_input(false)

	preview_camera = preview_camera.instance()
	_get_paths()
	if paths.size() > 0:
		paths[path_index].get_node("PathFollow").add_child(preview_camera)
		paths[path_index].get_node("PathFollow").start_preview()

		$ColorRect/AnimationPlayer.play("FadeIn")
	else:
		emit_signal("preview_finished")


func _process(delta):
	var frame_pos = frame_count % MAX_FRAME_COUNT
	if frame_count < MAX_FRAME_COUNT:
		frames.append(delta)
	else:
		frames[frame_pos] = delta

	if frames.size() > 1:
		var mean := 0.0
		for frame in frames:
			mean += frame
		mean /= frames.size()

		var mean_depature := 0.0
		for frame in frames:
			mean_depature += pow(frame - mean, 2)
		std_dev = sqrt(mean_depature / (frames.size() - 1))

		var std_dev_pos = (frame_count-2) % MAX_STDDEV_COUNT
		if (frame_count-2) < MAX_STDDEV_COUNT:
			std_devs.append(std_dev)
		else:
			std_devs[std_dev_pos] = std_dev

		mean_std_dev = 0
		for stddev in std_devs:
			mean_std_dev += stddev
		mean_std_dev /= std_devs.size()

#	print(frame_count, "\tDelta: ", delta, "\tFPS: ", Engine.get_frames_per_second(), "\tStd Dev: ", std_dev, "\tMean Std Dev: ", mean_std_dev)

	frame_count += 1

	if frame_count > MAX_FRAME_COUNT * 2 and mean_std_dev < 0.01:
		preview_camera.get_node("Label").visible = true
		set_process_input(true)


func _input(event):
	if !event.is_action_pressed("Pause") and !event is InputEventMouseMotion:
		set_process(false)
		set_process_input(false)
		preview_camera.get_node("Label").visible = false
		$ColorRect/AnimationPlayer.play("FadeOut")
		yield($ColorRect/AnimationPlayer, "animation_finished")
		paths[path_index].get_node("PathFollow").end_preview()

		# Signal to Track _preview_finished
		emit_signal("preview_finished")

		$ColorRect/AnimationPlayer.play("FadeIn")


func _get_paths() -> void:
	var children := get_children()
	for child in children:
		if child is Path:
			paths.append(child)


func switch_cameras() -> void:
	paths[path_index].get_node("PathFollow").remove_child(preview_camera)
	path_index = (path_index + 1) % paths.size()
	paths[path_index].get_node("PathFollow").add_child(preview_camera)
	paths[path_index].get_node("PathFollow").start_preview()
