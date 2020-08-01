extends Spatial

var start_timer : Timer = Timer.new()

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$Players/Player.connect("race_finished", self, "finish_race")
	start_timer.connect("timeout", $Players, "start_race")
	start_timer.one_shot = true
	add_child(start_timer)
	start_timer.start(10)

func _process(delta):
	if $Players/Player.lap_number == 0:
		$Players/Player.display_start_time(start_timer.time_left)
		
func finish_race() -> void:
	$Players.finish_race()
	start_timer.connect("timeout", self, "end_race")
	start_timer.start(5)

func end_race() -> void:
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
