extends CanvasLayer

func player_1_take_damage():
	$Health.take_damage()

func player_2_take_damage():
	$Health2.take_damage()

func player_1_center_progress(value):
	$CenterCounter/ProgressBar.set_value(value/10 * 100)

func player_2_center_progress(value):
	$CenterCounter2/ProgressBar.set_value(value/10 * 100)
	
func show_banner(text):
	$Banner.visible = true
	$Label.text = text

func hide_banner():
	$Banner.visible = false
	$Label.text = ""
	
func set_message(text):
	$Label2.text = text
	$Label2.visible = true
	await get_tree().create_timer(1).timeout
	$Label2.visible = false

func start():
	$Health.start()
	$Health2.start()
	
func _ready():
	$Health2.flip()
