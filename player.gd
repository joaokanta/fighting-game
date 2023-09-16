extends Node2D

@export var speed = 400
var screen_size

signal take_damage

var attacking = false
var taking_damage = false
var move_right = "null"
var move_left = "null"
var attack_command = "null"

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not attacking and not taking_damage:
		var velocity = Vector2.ZERO
		if Input.is_action_pressed(move_right):
			velocity.x += speed
		if Input.is_action_pressed(move_left):
			velocity.x -= speed * 0.8
		if Input.is_action_just_pressed(attack_command):
			attack()

		position += velocity * delta
		position = position.clamp(Vector2.ZERO, screen_size)
		
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "walk"
		else:
			$AnimatedSprite2D.animation = "idle"
	else:
		if attacking:
			$AnimatedSprite2D.animation = "attack"
		if taking_damage:
			$AnimatedSprite2D.animation = "take_damage"
	
func set_commands(move_left, move_right, attack_command):
	self.move_left = move_left
	self.move_right = move_right
	self.attack_command = attack_command
		
func flip():
	set_scale(Vector2(-1,1))

func attack():
	attacking = true
	$Hurtbox.monitorable = true
	$AttackTimer.start()

func _on_attack_timer_timeout():
	attacking = false	
	$Hurtbox.monitorable = false

func _on_hitbox_area_entered(area):
	take_damage.emit()
	taking_damage = true
	$Hitbox.monitoring = true
	$DamageTimer.start()


func _on_damage_timer_timeout():
	taking_damage = false
	$Hitbox.monitoring = true
