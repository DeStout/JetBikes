extends Sprite

var _save_minimap_img := false

var minimap_camera : Camera
var players : Array
var dot_size := 4.5

func _process(_delta):
	if _save_minimap_img:
		var _minimap_img = texture.get_data()
		_minimap_img.save_png("res://Tracks/TestTerrain/Assets/D_Minimap.png")

	update()

func _draw():
	if players != null and minimap_camera != null:
		for player in players:
			if player is KinematicBody:
				var player_position = minimap_camera.unproject_position(player.global_transform.origin)
				draw_circle(player_position, dot_size, player.get_racer_color())
