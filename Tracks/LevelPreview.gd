extends Node

const MAX_FRAME_COUNT : int = 60
const MAX_STDDEV_COUNT : int = 10

signal preview_finished

var frame_count : int = 0

var frames : Array = []
var std_devs : Array = []

var std_dev : float
var mean_std_dev : float = 0


func _ready():
	$ColorRect/AnimationPlayer.play("FadeIn")
	set_process_input(false)


func _process(delta):
	var frame_pos = frame_count % MAX_FRAME_COUNT
	if frame_count < MAX_FRAME_COUNT:
		frames.append(delta)
	else:
		frames[frame_pos] = delta
	
	if frames.size() > 1:
		var mean : float
		for frame in frames:
			mean += frame
		mean /= frames.size()
		
		var mean_depature : float = 0
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
	
	if frame_count > MAX_FRAME_COUNT * 3 and mean_std_dev < 0.01:
		$PreviewFollow/PreviewCamera/Label.visible = true
		set_process_input(true)


func _input(event):
	if event is InputEventKey or event is InputEventMouseButton:
		set_process(false)
		set_process_input(false)
		$PreviewFollow/PreviewCamera/Label.visible = false
		$ColorRect/AnimationPlayer.play("FadeOut")
		yield($ColorRect/AnimationPlayer, "animation_finished")
		$PreviewFollow.follow = false
		$PreviewFollow.offset = 0
		emit_signal("preview_finished")
		$ColorRect/AnimationPlayer.play("FadeIn")