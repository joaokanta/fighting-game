extends Node

const START = "start"

var started = false
var restarting = false

var player_1_starting_position
var player_2_starting_position

var player_1_center = 0
var player_2_center = 0

func _ready():
	player_1_starting_position = $Player.get_position()
	player_2_starting_position = $Player2.get_position()
	$Player.set_commands("player_1_move_left", "player_1_move_right", "player_1_attack", "player_1_parry", "player_1_dash")
	$Player2.set_commands("player_2_move_left", "player_2_move_right", "player_2_attack", "player_2_parry", "player_2_dash")
	$Player.flip()
	$Stage.play()
	$HUD.show_banner("Press enter to start")
	

func _process(delta):
	if Input.is_action_just_pressed(START) and not started:
		start()
	if started and not $AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()
	if player_1_center > 10:
		$HUD.set_message("King of the hill")
		$Player2.shock()
	if player_2_center > 10:
		$HUD.set_message("King of the hill")
		$Player.shock()

func start():
	$HUD.start()
	await get_tree().create_timer(0.5).timeout
	$HUD.hide_banner()
	$Player.round_start()
	$Player2.round_start()
	started = true
	
func restart():
	await get_tree().create_timer(5).timeout
	get_tree().reload_current_scene()

func _on_player_take_damage():
	$HUD.player_1_take_damage()

func _on_player_2_take_damage():
	$HUD.player_2_take_damage()

func _on_player_died():
	$HUD.show_banner("Player 2 wins")
	if not restarting:
		restart()
	
func _on_player_2_died():
	$HUD.show_banner("Player 1 wins")
	if not restarting:
		restart()

func _on_player_parried():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(Engine, "time_scale", 0.5, 0.25)
	tween.tween_property($AudioStreamPlayer, "pitch_scale", 0.5, 0.25)
	$SlowMoTimer.start()

func _on_slow_mo_timer_timeout():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(Engine, "time_scale", 1, 0.1)
	tween.tween_property($AudioStreamPlayer, "pitch_scale", 1, 0.1)

func _on_player_message(text):
	$HUD.set_message(text)
	
func _on_player_1_center(delta):
	player_1_center += delta
	$HUD.player_1_center_progress(player_1_center)

func _on_player_2_center(delta):
	player_2_center += delta
	$HUD.player_2_center_progress(player_2_center)
