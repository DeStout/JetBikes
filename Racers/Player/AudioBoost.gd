extends AudioStreamPlayer

const DEFAULT_PITCH : float = 1.0
const MAX_PITCH : float = 1.1
const MIN_PITCH : float = 0.1
const DELTA_PITCH : int = 5

var is_boosting : bool = false
var acceleration : int = 0

func _ready():
	pitch_scale = DEFAULT_PITCH

func _process(delta):
	if acceleration != 0:
		if !playing:
			playing = true
		pitch_scale = clamp(pitch_scale + (delta * acceleration * DELTA_PITCH), MIN_PITCH, MAX_PITCH)

		if is_equal_approx(pitch_scale, MIN_PITCH):
			playing = false
			pitch_scale = DEFAULT_PITCH
			acceleration = 0
	else:
		playing = false

func set_playing(boosting : bool):
	if is_boosting != boosting:
		is_boosting = boosting

		if is_boosting:
			acceleration = 1
		else:
			acceleration = -1
