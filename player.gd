extends Area2D

@export var speed = 400
var screen_size

signal take_damage

var attacking = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not attacking:
		var velocity = Vector2.ZERO
		if Input.is_action_pressed("move_right"):
			velocity.x += speed
		if Input.is_action_pressed("move_left"):
			velocity.x -= speed * 0.8
		if Input.is_action_just_pressed("take_damage"):
			attack()

		position += velocity * delta
		position = position.clamp(Vector2.ZERO, screen_size)
		
		if velocity.x != 0:
			$AnimatedSprite2D.animation = "walk"
		else:
			$AnimatedSprite2D.animation = "idle"
	else:
		$AnimatedSprite2D.animation = "attack"
		
func attack():
	attacking = true
	$AttackTimer.start()

func _on_attack_timer_timeout():
	attacking = false
	take_damage.emit()
