extends Node2D

var full_heart = preload("res://sprites/Hearts/PNG/basic/heart.png")
var empty_heart = preload("res://sprites/Hearts/PNG/basic/border.png")

var hp = 3

func take_damage():
	if hp <= 3 and hp > 0:
		get_node("Heart" + str(hp)).set_texture(empty_heart)
		hp -= 1

func _ready():
	for i in range(1, 3):
		get_node("Heart" + str(hp)).set_texture(full_heart)
