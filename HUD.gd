extends CanvasLayer

func player_1_take_damage():
	$Health.take_damage()

func player_2_take_damage():
	$Health2.take_damage()

func game_over(winner):
	pass

func start():
	$Health.start()
	$Health2.start()
	await get_tree().create_timer(3.0).timeout
	
func _ready():
	$Health2.flip()
