extends Node2D

@export var speed = 400
var screen_size

signal take_damage
signal parried
signal died

var health = 3

var starting_attack = false
var attacking = false
var taking_damage = false
var post_attack = false
var dead = false
var dying = false
var blocking = false
var blockstun = false
var parrying = false
var failed_parry = false
var counter_attacking = false
var flipped = false

var move_right = "null"
var move_left = "null"
var attack_command = "null"
var parry_command = "null"

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dying:
		$AnimatedSprite2D.animation = "dying"
		return
		
	if dead:
		$AnimatedSprite2D.animation = "dead"
		return
		
	var velocity = Vector2.ZERO
	if not is_movement_blocked():
		if Input.is_action_pressed(move_right):
			blocking = false
			if flipped:
				blocking = true
			velocity.x += speed
		if Input.is_action_pressed(move_left):
			blocking = true
			if flipped:
				blocking = false
			velocity.x -= speed * 0.75
		if Input.is_action_just_pressed(attack_command):
			attack()
		if Input.is_action_just_pressed(parry_command):
			parry()
		
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "walk"
		else:
			$AnimatedSprite2D.animation = "idle"
	else:
		if blockstun:
			blocking = true
			velocity.x += get_knockback(1.2)
			$AnimatedSprite2D.animation = "block"
		elif parrying:
			$AnimatedSprite2D.animation = "parry"
		elif failed_parry:
			$AnimatedSprite2D.animation = "failed_parry"
		elif counter_attacking:
			$AnimatedSprite2D.animation = "counter_attack"
		elif starting_attack:
			$AnimatedSprite2D.animation = "attack_startup"
		elif attacking:
			$AnimatedSprite2D.animation = "attack"
		elif taking_damage:
			velocity.x += get_knockback(0.8)
			$AnimatedSprite2D.animation = "take_damage"
		elif post_attack:
			$AnimatedSprite2D.animation = "post_attack"
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)


func get_knockback(multi):
	if not flipped: 
		return speed * -multi
	return speed * multi
	

func is_movement_blocked():
	return attacking or taking_damage or post_attack or blockstun or starting_attack or counter_attacking or parrying or failed_parry

func set_commands(move_left, move_right, attack_command, parry_command):
	self.move_left = move_left
	self.move_right = move_right
	self.attack_command = attack_command
	self.parry_command = parry_command


func flip():
	flipped = not flipped
	if not flipped:
		set_scale(Vector2(-1,1))
		return
	set_scale(Vector2(-1,1))


func attack():
	starting_attack = true
	$AttackStartupTimer.start()


func _on_attack_startup_timer_timeout():
	starting_attack = false
	attacking = true
	$Hurtbox.monitorable = true
	$AttackTimer.start()


func _on_attack_timer_timeout():
	attacking = false	
	$Hurtbox.monitorable = false
	post_attack = true
	$PostAttackTimer.start()


func _on_post_attack_timer_timeout():
	post_attack = false
	failed_parry = false


func parry():
	parrying = true
	$ParryTimer.start()


func _on_parry_timer_timeout():
	parrying = false
	failed_parry = true
	$PostAttackTimer.start()

func _on_parry_animation_timer_timeout():
	parrying = false
	counter_attacking = true
	$CounterAttackTimer.start()
	$Hurtbox.set_deferred("monitorable", true)
	
func _on_counter_attack_timer_timeout():
	$Hitbox.set_deferred("monitoring", true)
	$Hurtbox.monitorable = false
	counter_attacking = false


func _on_hitbox_area_entered(area):
	if parrying:
		parried.emit()
		$ParryTimer.stop()
		$ParryAnimationTimer.start()
		$Hitbox.set_deferred("monitoring", false)
		return
		
	if blocking:
		blockstun = true
		$BlockstunTimer.start()
		return
		
	health -= 1
	take_damage.emit()
	if health > 0:
		attacking = false	
		$Hurtbox.set_deferred("monitorable", false)
		taking_damage = true
		$DamageTimer.start()
		return
	dying = true
	$DyingTimer.start()


func _on_damage_timer_timeout():
	taking_damage = false
	$Hitbox.monitoring = true


func _on_dying_timer_timeout():
	dying = false
	dead = true
	died.emit()


func _on_blockstun_timer_timeout():
	blockstun = false
