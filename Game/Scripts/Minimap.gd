extends Sprite

var minimap_camera : Camera
var players : Array

func _process(delta):
	update()

func _draw():
	if players != null and minimap_camera != null:
		for player in players:
			var player_position = minimap_camera.unproject_position(player.global_transform.origin)
			if player is Player:
				draw_circle(player_position, 5, Color(0, 0.33, 0.75))
			else:
				draw_circle(player_position, 5, Color(1.0, 0.33, 0))
