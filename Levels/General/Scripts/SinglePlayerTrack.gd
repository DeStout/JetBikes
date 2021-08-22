extends Track

signal return_to_main


func _ready():
	$Players.player.HUD.setup_minimap($Minimap.get_texture(), $Minimap/MinimapCamera, $Players.players)
	$Players.player.pause_menu.connect("end_race", self, "end_race")
	
	$StartTimer.start()


func _process(delta) -> void:
	if $StartTimer.time_left:
		$Players.player.HUD.set_race_notice("%d" % ($StartTimer.time_left + 1), true)


func start_race() -> void:
	.start_race()
	$Players.player.HUD.set_race_notice()


func end_race():
	.end_race()
	emit_signal("return_to_main")
