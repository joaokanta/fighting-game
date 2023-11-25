extends Node2D

signal death
var flipped = false

var full_health = preload("res://sprites/icons/2267517.png")
var empty_health = preload("res://sprites/icons/sumo.png")

var hp = 3

func take_damage():
	if hp <= 3 and hp > 0:
		get_node("Sprite2D" + str(hp)).set_texture(empty_health)
		hp -= 1

func _ready():
	pass

func start():
	for i in range(1, 4):
		get_node("Sprite2D" + str(i)).set_texture(full_health)
		await get_tree().create_timer(1.0).timeout
		
func flip():
	flipped = not flipped
	var scale = get_scale()
	scale.x = scale.x * -1
	set_scale(scale)
