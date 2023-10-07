extends Node2D

@export var speed = 400
var screen_size

signal take_damage
signal parried
signal died

var health = 3

var STARTING_ATTACK = 'starting_attack'
var ATTACKING = 'attacking'
var TAKING_DAMAGE = 'taking_damage'
var POST_ATTACK = 'post_attack'
var DEAD = 'dead'
var DYING = 'dying'
var BLOCKSTUN = 'blockstun'
var PARRYING = 'parrying'
var FAILED_PARRY = 'failed_parry'
var COUNTER_ATTACKING = 'counter_attacking'
var IDLE = 'idle'
var WALKING = 'walk'

var flipped = false
var blocking = false

var MOVE_RIGHT = "null"
var MOVE_LEFT = "null"
var ATTACK_COMMAND = "null"
var PARRY_COMMAND = "null"

var states = {
	ATTACKING: 'attack',
	BLOCKSTUN: 'block',
	COUNTER_ATTACKING: 'counter_attack',
	DEAD: 'dead',
	DYING: 'dying',
	IDLE: 'idle',
	POST_ATTACK: 'post_attack',
	STARTING_ATTACK: 'attack_startup',
	TAKING_DAMAGE: 'take_damage',
	WALKING: 'walk',
	FAILED_PARRY: 'failed_parry',
	PARRYING: 'parry'
}

var STATE = IDLE

func isState(state):
	return STATE in state

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if isState([DYING, DEAD]):
		$AnimatedSprite2D.animation = states[STATE]
		return
		
	var velocity = Vector2.ZERO
	
	if not is_movement_blocked():
		if Input.is_action_pressed(MOVE_RIGHT):
			blocking = false
			if flipped:
				blocking = true
			velocity.x += speed
		if Input.is_action_pressed(MOVE_LEFT):
			blocking = true
			if flipped:
				blocking = false
			velocity.x -= speed * 0.75
				
		if velocity.x != 0:
			STATE = WALKING
		else:
			STATE = IDLE
		
		if Input.is_action_just_pressed(ATTACK_COMMAND):
			attack()
		if Input.is_action_just_pressed(PARRY_COMMAND): 
			parry()
	else:
		if isState(BLOCKSTUN):
			blocking = true
			velocity.x += get_knockback(1.2)
		elif isState(TAKING_DAMAGE):
			velocity.x += get_knockback(0.8)

	$AnimatedSprite2D.animation = states[STATE]
	position += velocity * delta
	position = position.clamp(Vector2(100, 0), screen_size - Vector2(100, 0))


func get_knockback(multi):
	if not flipped: 
		return speed * -multi
	return speed * multi
	

func is_movement_blocked():
	return STATE in [ATTACKING, TAKING_DAMAGE, POST_ATTACK, BLOCKSTUN, STARTING_ATTACK, COUNTER_ATTACKING, PARRYING, FAILED_PARRY]

func set_commands(move_left, move_right, attack_command, parry_command):
	self.MOVE_LEFT = move_left
	self.MOVE_RIGHT = move_right
	self.ATTACK_COMMAND = attack_command
	self.PARRY_COMMAND = parry_command


func flip():
	flipped = not flipped
	set_scale(Vector2(-1,1))


func attack():
	STATE = STARTING_ATTACK
	await get_tree().create_timer(0.2).timeout
	STATE = ATTACKING
	$Hurtbox.monitorable = true
	await get_tree().create_timer(0.4).timeout
	$Hurtbox.monitorable = false
	STATE = POST_ATTACK
	await get_tree().create_timer(0.4).timeout
	STATE = IDLE

func parry():
	STATE = PARRYING
	$ParryTimer.start()

func _on_parry_timer_timeout():
	STATE = FAILED_PARRY
	await get_tree().create_timer(0.4).timeout
	STATE = IDLE


func _on_hitbox_area_entered(_area):
	if isState(PARRYING):
		$ParryTimer.stop()
		parried.emit()
		$Hitbox.set_deferred("monitoring", false)
		await get_tree().create_timer(0.85).timeout
		
		STATE = COUNTER_ATTACKING
		$Hurtbox.set_deferred("monitorable", true)
		await get_tree().create_timer(0.3).timeout
		
		$Hitbox.set_deferred("monitoring", true)
		$Hurtbox.set_deferred("monitorable", false)
		STATE = IDLE
		return
		
	if blocking:
		STATE = BLOCKSTUN
		await get_tree().create_timer(0.8).timeout
		STATE = IDLE
		return
		
	health -= 1
	take_damage.emit()
	if health > 0:
		$Hurtbox.set_deferred("monitorable", false)
		STATE = TAKING_DAMAGE
		await get_tree().create_timer(0.4).timeout
		
		STATE = IDLE
		return
		
	STATE = DYING
	await get_tree().create_timer(0.4).timeout
	STATE = DEAD
