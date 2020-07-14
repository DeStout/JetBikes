extends KinematicBody

const GRAVITY = 9.8

var velocity = Vector3.ZERO

func _physics_process(delta):
	velocity.y = velocity.y - GRAVITY
	
	velocity = move_and_slide(velocity, Vector3(0,1,0))
