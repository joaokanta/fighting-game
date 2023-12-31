extends Node2D

@export var speed = 400
var screen_size

signal take_damage
signal parried
signal died
signal message
signal center

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
const WALKING_BACK = 'walk_back'
const WALKING_FORWARD = 'walk_forward'
const DASHING = 'dashing'
const SHOCK = 'shock'

var flipped = false
var blocking = false

var MOVE_RIGHT = "null"
var MOVE_LEFT = "null"
var ATTACK_COMMAND = "null"
var PARRY_COMMAND = "null"
var DASH_COMMAND = "null"

var STATE = IDLE

var executing_action = false
var action_queue = []
var action_time = 0

var last_dash = 0

func is_state(state):
	return STATE in state

var round_started = false
func round_start():
	round_started = true
	flip()

func get_slam_limit():
	if flipped:
		return 1800
	return 100

func shock():
	health = 0
	clear_action_queue()
	STATE = SHOCK
	$Died.play()
	$Died.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play()

func reset():
	clear_action_queue()
	round_started = false
	health = 3
	STATE = IDLE
	flip()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	last_dash -= delta
	
	if round_started:
		if get_position().x > screen_size.x/2 and not flipped:
			var temp = get_position()
			center.emit(delta)
		elif get_position().x < screen_size.x/2 and flipped:
			var temp = get_position()
			center.emit(delta)
		
	if not round_started:
		$AnimatedSprite2D.animation = IDLE
		return
		
	if is_state([DEAD, SHOCK]):
		died.emit()
		$AnimatedSprite2D.animation = STATE
		return
	
	var velocity = Vector2.ZERO
	if action_queue.size() > 0:
		process_action(delta)
	else:
		set_idle()
		
		velocity = get_velocity()
		if Input.is_action_just_pressed(DASH_COMMAND) and velocity.x != 0 and last_dash <= 0:
			last_dash = 0.4
			dash()
		if Input.is_action_just_pressed(ATTACK_COMMAND):
			attack()
		if Input.is_action_just_pressed(PARRY_COMMAND): 
			parry()

		if velocity.x != 0:
			if not $Step.playing:
				$Step.play()
				
	set_blocking(velocity)
	
	$AnimatedSprite2D.animation = STATE
	set_player_position(velocity, delta)
	
func set_player_position(velocity, delta):
	if is_state([BLOCKSTUN]):
		velocity.x += get_knockback(1)
	elif is_state([TAKING_DAMAGE]):
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

func get_velocity(dashing = false):
	var velocity = Vector2.ZERO
	if  Input.is_action_pressed(MOVE_RIGHT) and Input.is_action_pressed(MOVE_LEFT):
		return velocity
	elif Input.is_action_pressed(MOVE_RIGHT):
		velocity.x += speed
		if flipped:
			velocity.x *= 0.75
		if not dashing:
			STATE = get_move_right_animation()
	elif Input.is_action_pressed(MOVE_LEFT):
		velocity.x -= speed
		if not flipped:
			velocity.x *= 0.75
		if not dashing:
			STATE = get_move_left_animation()
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
	
	if STATE == DASHING:
		var velocity = get_velocity(true)
		velocity.x *= 4
		set_player_position(velocity, delta)
	
	$AnimatedSprite2D.animation = STATE

func get_knockback(multi):
	if not flipped: 
		return speed * -multi
	return speed * multi

func get_move_left_animation():
	if flipped:
		return WALKING_FORWARD
	return WALKING_BACK


func get_move_right_animation():
	if flipped:
		return WALKING_BACK
	return WALKING_FORWARD


func is_movement_blocked():
	return STATE in [ATTACKING, TAKING_DAMAGE, POST_ATTACK, BLOCKSTUN, STARTING_ATTACK, COUNTER_ATTACKING, PARRYING, FAILED_PARRY, DYING, DEAD]

func set_commands(move_left, move_right, attack_command, parry_command, dash_command):
	self.MOVE_LEFT = move_left
	self.MOVE_RIGHT = move_right
	self.ATTACK_COMMAND = attack_command
	self.PARRY_COMMAND = parry_command
	self.DASH_COMMAND = dash_command


func flip():
	flipped = not flipped
	var scale = get_scale()
	scale.x = scale.x * -1
	set_scale(scale)

## ATTACK
func attack():
	action_queue.append([STARTING_ATTACK, 0.2, HITBOX_ON])
	action_queue.append([ATTACKING, 0.1, HITBOX_OFF])
	action_queue.append([POST_ATTACK, 0.4, NO_OP])

func dash():
	action_queue.append([DASHING, 0.1, NO_OP])

const NO_OP = "no_op"
func no_op():
	pass

const HITBOX_ON = "hitbox_on"
func hitbox_on():
	$Hitbox.set_deferred("monitorable", true)
	
const HITBOX_OFF = "hitbox_off"
func hitbox_off():
	$Missed.play()
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
	if is_state([PARRYING]):
		# parried.emit()
		clear_action_queue()
		
		message.emit("COUNTER")
		action_queue.append([PARRYING, 0.45, HITBOX_ON])
		action_queue.append([COUNTER_ATTACKING, 0.3, HITBOX_OFF])
		action_queue.append([POST_ATTACK, 0.4, NO_OP])
		return
		
	if blocking:
		clear_action_queue()
		$BlockEffects.play("blocked")
		$Blocked.play()
		action_queue.append([BLOCKSTUN, 0.4, NO_OP])
		return
	lose_health("HIT")

func lose_health(text):
	health -= 1
	$Hit.play()
	message.emit(text)
	take_damage.emit()
	if health > 0:
		clear_action_queue()
		action_queue.append([TAKING_DAMAGE, 0.4, NO_OP])
		return
	clear_action_queue()
	$Died.play()
	action_queue.append([DYING, 1, DEAD])


func _on_player_died():
	pass # Replace with function body.
