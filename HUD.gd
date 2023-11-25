extends CanvasLayer

func player_1_take_damage():
	$Health.take_damage()

func player_2_take_damage():
	$Health2.take_damage()

func show_banner(text):
	$Banner.visible = true
	$Label.text = text

func hide_banner():
	$Banner.visible = false
	$Label.text = ""

func start():
	$Health.start()
	$Health2.start()
	await get_tree().create_timer(3.0).timeout
	
func _ready():
	$Health2.flip()
