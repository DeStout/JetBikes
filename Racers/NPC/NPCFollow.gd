extends PathFollow

var follow : bool = false

var npc : NPC

const START_OFFSET : int = 127
const MAX_SPEED : int = 150
const PATH_VARIABILITY := 20.0

var target_distance : int = 25
var speed : float = 0


func _ready() -> void:
	offset = START_OFFSET

	rotation_mode = PathFollow.ROTATION_ORIENTED
	h_offset = (randf() * PATH_VARIABILITY) - (PATH_VARIABILITY / 2)


func _process(delta):
	if follow:
		offset += delta * speed

		var dist = global_transform.origin.distance_to(npc.global_transform.origin)
		speed = clamp(speed + (target_distance - dist), 0, MAX_SPEED)
