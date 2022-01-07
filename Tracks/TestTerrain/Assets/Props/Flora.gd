extends Spatial

var flora_emitter = preload("res://Tracks/TestTerrain/Assets/Props/FloraEmitter.tscn")


func _on_Area_body_entered(body):
	if body is Racer:
#		$Area/CollisionShape.disabled = true
#		$Flora.visible = false
#		flora_emitter = flora_emitter.instance()
#		add_child(flora_emitter)
#		flora_emitter.set_emitting(true)
#		yield(get_tree().create_timer(flora_emitter.get_lifetime()), "timeout")
		queue_free()
