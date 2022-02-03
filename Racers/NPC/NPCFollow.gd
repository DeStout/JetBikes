extends PathFollow

var follow : bool = false

var npc : NPC

const MAX_SPEED : int = 150

var target_distance : int = 50
var speed : float = 0


func _process(delta):
	if follow:
		offset += delta * speed

		var dist = global_transform.origin.distance_to(npc.global_transform.origin)
		speed = clamp(speed + (target_distance - dist), 0, MAX_SPEED)
