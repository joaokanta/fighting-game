extends Node2D

@export var speed = 400
var screen_size

signal take_damage
signal parried
signal died

var health = 3

const STARTING_ATTACK = 'attack_startup'
const ATTACKING = 'attack'
const TAKING_DAMAGE = 'take_damage'
const POST_ATTACK = 'post_attack'
const DEAD = 'dead'
const DYING = 'dying'
const BLOCKSTUN = 'block'
const PARRYING = 'parry'
const FAILED_PARRY = 'failed_parry'
const COUNTER_ATTACKING = 'counter_attack'
const IDLE = 'idle'
const WALKING = 'walk'

var flipped = false
var blocking = false

var MOVE_RIGHT = "null"
var MOVE_LEFT = "null"
var ATTACK_COMMAND = "null"
var PARRY_COMMAND = "null"


var STATE = IDLE

var executing_action = false
var action_queue = []
var action_time = 0

func is_state(state):
	return STATE in state

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_state([DEAD]):
		$AnimatedSprite2D.animation = STATE
		return
	
	var velocity = Vector2.ZERO
	if action_queue.size() > 0:
		process_action(delta)
	else:
		set_idle()
		
		velocity = get_velocity()
		if Input.is_action_just_pressed(ATTACK_COMMAND):
			attack()
		if Input.is_action_just_pressed(PARRY_COMMAND): 
			parry()

	set_blocking(velocity)
	
	$AnimatedSprite2D.animation = STATE
	set_player_position(velocity, delta)
	
func set_player_position(velocity, delta):
	if is_state(BLOCKSTUN):
		velocity.x += get_knockback(0.3)
	elif is_state(TAKING_DAMAGE):
		velocity.x += get_knockback(0.5)
	
	position += velocity * delta
	position = position.clamp(Vector2(100, 0), screen_size - Vector2(100, 0))
	
func set_idle():
	$Hitbox.set_deferred("monitorable", false)
	$Hurtbox.set_deferred("monitoring", true)
	STATE = IDLE

func set_blocking(velocity):
	if is_movement_blocked():
		blocking = false
		return
	
	if velocity.x == 0:
		blocking = true
		return
		
	blocking = velocity.x < 0
	if flipped:
		blocking = !blocking

func get_velocity():
	var velocity = Vector2.ZERO
	if  Input.is_action_pressed(MOVE_RIGHT) and Input.is_action_pressed(MOVE_LEFT):
		return velocity
	elif Input.is_action_pressed(MOVE_RIGHT):
		velocity.x += speed
		STATE = WALKING
	elif Input.is_action_pressed(MOVE_LEFT):
		velocity.x -= speed * 0.75
		STATE = WALKING
		
	return velocity
	
func process_action(delta):
	STATE = action_queue[0][0]
	if not executing_action:
		action_time = action_queue[0][1]
		executing_action = true
	elif action_time < 0:
		call(action_queue[0][2])
		executing_action = false
		action_queue.remove_at(0)
	else:
		action_time -= delta	
		
	$AnimatedSprite2D.animation = STATE

func get_knockback(multi):
	if not flipped: 
		return speed * -multi
	return speed * multi
	

func is_movement_blocked():
	return STATE in [ATTACKING, TAKING_DAMAGE, POST_ATTACK, BLOCKSTUN, STARTING_ATTACK, COUNTER_ATTACKING, PARRYING, FAILED_PARRY, DYING, DEAD]

func set_commands(move_left, move_right, attack_command, parry_command):
	self.MOVE_LEFT = move_left
	self.MOVE_RIGHT = move_right
	self.ATTACK_COMMAND = attack_command
	self.PARRY_COMMAND = parry_command


func flip():
	flipped = not flipped
	set_scale(Vector2(-1,1))

## ATTACK
func attack():
	action_queue.append([STARTING_ATTACK, 0.2, HITBOX_ON])
	action_queue.append([ATTACKING, 0.4, HITBOX_OFF])
	action_queue.append([POST_ATTACK, 0.4, NO_OP])

const NO_OP = "no_op"
func no_op():
	pass

const HITBOX_ON = "hitbox_on"
func hitbox_on():
	$Hitbox.set_deferred("monitorable", true)
	
const HITBOX_OFF = "hitbox_off"
func hitbox_off():
	$Hitbox.set_deferred("monitorable", false)

const HITSTUN_ON = "hitstun_on"
func hitstun_on():
	$Hitbox.set_deferred("monitorable", false)
	$Hurtbox.set_deferred("monitoring", false)

func dead():
	STATE = DEAD

func clear_action_queue():
	executing_action = false
	action_queue = []

func parry():
	action_queue.append([PARRYING, 0.2, NO_OP])
	action_queue.append([FAILED_PARRY, 0.4, NO_OP])

func _on_hurtbox_area_entered(_area):
	if is_state(PARRYING):
		# parried.emit()
		clear_action_queue()
		
		action_queue.append([PARRYING, 0.85, HITBOX_ON])
		action_queue.append([COUNTER_ATTACKING, 0.3, HITBOX_OFF])
		action_queue.append([POST_ATTACK, 0.4, NO_OP])
		return
		
	if blocking:
		clear_action_queue()
		action_queue.append([BLOCKSTUN, 0.4, NO_OP])
		return
		
	health -= 1
	take_damage.emit()
	if health > 0:
		clear_action_queue()
		action_queue.append([TAKING_DAMAGE, 0.4, NO_OP])
		return
	
	clear_action_queue()
	action_queue.append([DYING, 0.4, DEAD])
