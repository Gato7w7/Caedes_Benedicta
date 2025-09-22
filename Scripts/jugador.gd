extends CharacterBody2D

const SPEED = 150.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var last_direction := "down"  # Para recordar hacia dónde estaba mirando

func _ready() -> void:
	sprite.play("idle_down") # Animación inicial

func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO

	# Movimiento en los 2 ejes
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1

	input_vector = input_vector.normalized()
	velocity = input_vector * SPEED
	move_and_slide()

	# Lógica de animación
	if input_vector == Vector2.ZERO:
		# Quieto → idle en la última dirección
		match last_direction:
			"down":
				sprite.play("idle_down")
			"up":
				sprite.play("idle_up")
			"side":
				sprite.play("idle_side")
	else:
		# Movimiento
		if input_vector.x != 0:
			sprite.play("walk_side")
			sprite.flip_h = input_vector.x < 0
			last_direction = "side"
		elif input_vector.y < 0:
			sprite.play("walk_up")
			last_direction = "up"
		elif input_vector.y > 0:
			sprite.play("walk_down")
			last_direction = "down"
