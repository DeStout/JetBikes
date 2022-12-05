extends Sprite

var minimap_camera : Camera
var players : Array

func _process(_delta):
	update()

func _draw():
	if players != null and minimap_camera != null:
		for player in players:
			if player is KinematicBody:
				var player_position = minimap_camera.unproject_position(player.global_transform.origin)
				draw_circle(player_position, 5, player.get_racer_color())
