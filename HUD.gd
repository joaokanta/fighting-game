extends CanvasLayer

func _on_player_take_damage():
	$Health.take_damage()
