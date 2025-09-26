extends CharacterBody2D

const SPEED = 150.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var last_direction := "down"  # Para recordar hacia dónde estaba mirando

# Variable para controlar el cooldown de daño
var can_take_damage := true

func _ready() -> void:
	sprite.play("nidle_down") # Animación inicial

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
	
	# --- DETECCIÓN DE DAÑO DE ENEMIGOS ---
	# Esto es ADICIONAL a las colisiones físicas que ya maneja move_and_slide()
	if can_take_damage:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.is_in_group("enemigos"):
				print("¡Recibiste daño!")
				can_take_damage = false
				# Crear timer para reactivar el daño después de 1 segundo
				get_tree().create_timer(1.0).timeout.connect(_on_damage_cooldown_finished)
				break  # Solo un daño de enemigo por frame
	
	# Lógica de animación
	if input_vector == Vector2.ZERO:
		# Quieto → idle en la última dirección
		match last_direction:
			"down":
				sprite.play("nidle_down")
			"up":
				sprite.play("nidle_up")
			"side":
				sprite.play("nidle_side")
	else:
		# Movimiento
		if input_vector.x != 0:
			sprite.play("nwalk_side")
			sprite.flip_h = input_vector.x < 0
			last_direction = "side"
		elif input_vector.y < 0:
			sprite.play("nwalk_up")
			last_direction = "up"
		elif input_vector.y > 0:
			sprite.play("nwalk_down")
			last_direction = "down"

# Función que se ejecuta cuando termina el cooldown de daño
func _on_damage_cooldown_finished() -> void:
	can_take_damage = true
