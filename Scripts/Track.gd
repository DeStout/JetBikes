extends Spatial

var race_on_going : bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$Players.connect("race_finished", self, "finish_race")
	
	if Globals.SHOW_NPC_PATHFIND:
		for player in $Players.players:
			if player is NPC:
				add_child(player.draw_path)

func start_race() -> void:
	race_on_going = true
	$Players.start_race()
		
func finish_race() -> void:
	if race_on_going:
		race_on_going = false
		$Players.finish_race()
