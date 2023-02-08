extends Spatial

onready var racer = $Racer
onready var racer_default_rot = racer.rotation
var time_elapsed := 0.0


func _physics_process(delta: float) -> void:
	time_elapsed += delta
	racer.rotation.y = (0.1 * sin(time_elapsed * 0.5)) + racer_default_rot.y
