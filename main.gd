extends Node

var player_1_health = 3
var player_2_health = 3

func _ready():
	$Player.set_commands("player_1_move_left", "player_1_move_right", "player_1_attack")
	$Player2.set_commands("player_2_move_left", "player_2_move_right", "player_2_attack")
	$Player2.flip()

func _on_player_take_damage():
	$HUD.player_1_take_damage()
	player_1_health -= 1
	if player_1_health == 0:
		$HUD.game_over("PLAYER 2")


func _on_player_2_take_damage():
	$HUD.player_2_take_damage()
	player_2_health -= 1
	if player_2_health == 0:
		$HUD.game_over("PLAYER 1")
