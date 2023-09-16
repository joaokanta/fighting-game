extends CanvasLayer

func player_1_take_damage():
	$Health.take_damage()

func player_2_take_damage():
	$Health2.take_damage()

func game_over(winner):
	$Label.text = "GAME OVER " + str(winner) + " WINS"
	$Label.visible = true
