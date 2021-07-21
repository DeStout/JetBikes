extends AudioStreamPlayer3D

const DEFAULT_PITCH : float = 1.0
const MAX_PITCH : float = 1.1
const MIN_PITCH : float = 0.1
const DELTA_PITCH : int = 5

var is_playing : bool = false
var acceleration : int = 0

func _ready():
	pitch_scale = DEFAULT_PITCH

func _process(delta):
	if acceleration != 0:
		if !playing:
			playing = true
		pitch_scale += delta * acceleration * DELTA_PITCH
		pitch_scale = clamp(pitch_scale, MIN_PITCH, MAX_PITCH)
		
		if pitch_scale == MIN_PITCH or pitch_scale == MAX_PITCH:
			if pitch_scale == MIN_PITCH:
				playing = false
				pitch_scale = DEFAULT_PITCH
			acceleration = 0

func set_playing(play : bool):
	if is_playing != play:
		is_playing = play
	
	if is_playing:
		acceleration = 1
	else:
		acceleration = -1
