extends Node

const START = "start"

var started = false

func _ready():
	$Player.set_commands("player_1_move_left", "player_1_move_right", "player_1_attack", "player_1_parry")
	$Player2.set_commands("player_2_move_left", "player_2_move_right", "player_2_attack", "player_2_parry")
	$Player.flip()
	$Stage.play()
	$HUD.game_over("PRESS ENTER TO IGNITE THE FLAMES.")
	

func _process(delta):
	if Input.is_action_just_pressed(START) and not started:
		start()

func start():
	$HUD.start()
	await get_tree().create_timer(0.5).timeout
	$Player.round_start()
	$Player2.round_start()
	started = true

func _on_player_take_damage():
	$HUD.player_1_take_damage()

func _on_player_2_take_damage():
	$HUD.player_2_take_damage()

func _on_player_died():
	$HUD.game_over("FLAME VANQUISHED. PLAYER 2 WINS")
	
func _on_player_2_died():
	$HUD.game_over("FLAME VANQUISHED. PLAYER 1 WINS.")

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

