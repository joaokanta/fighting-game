extends Node2D

signal death
var flipped = false

var hp = 3

func take_damage():
	if hp <= 3 and hp > 0:
		get_node("Flame" + str(hp)).play("fizzle")
		hp -= 1

func _ready():
	pass

func start():
	for i in range(1, 4):
		get_node("Flame" + str(i)).play("ignition")
		await get_tree().create_timer(1.0).timeout
		get_node("Flame" + str(i)).play("idle")
		
func flip():
	flipped = not flipped
	var scale = get_scale()
	scale.x = scale.x * -1
	set_scale(scale)
