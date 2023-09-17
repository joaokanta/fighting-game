extends Node

func _ready():
	$Player.set_commands("player_1_move_left", "player_1_move_right", "player_1_attack", "player_1_parry")
	$Player2.set_commands("player_2_move_left", "player_2_move_right", "player_2_attack", "player_2_parry")
	$Player2.flip()

func _on_player_take_damage():
	$HUD.player_1_take_damage()

func _on_player_2_take_damage():
	$HUD.player_2_take_damage()

func _on_player_died():
	$HUD.game_over("PLAYER 2")
	
func _on_player_2_died():
	$HUD.game_over("PLAYER 1")

func _on_player_parried():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(Engine, "time_scale", 0.5, 0.25)
	tween.tween_property($AudioStreamPlayer, "pitch_scale", 0.5, 0.25)
	$SlowMoTimer.start()


func _on_slow_mo_timer_timeout():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(Engine, "time_scale", 1, 0.1)
	tween.tween_property($AudioStreamPlayer, "pitch_scale", 1, 0.1)
	print()
