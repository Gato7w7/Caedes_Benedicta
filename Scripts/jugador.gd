extends CharacterBody2D

const SPEED = 150.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var last_direction := "down"  # Para recordar hacia dónde estaba mirando

# Variable para controlar el cooldown de daño
var can_take_damage := true

# Variable para controlar si está atacando
var is_attacking := false

# === VARIABLES DE VIDA ===
var max_health = 100.0
var current_health = 100.0
@onready var health_bar = $"../CanvasLayer/Control/TextureProgressBar"

func _ready() -> void:
	sprite.play("nidle_down") # Animación inicial
	
	# Configurar barra de vida
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	# Conectar señal de animación terminada
	sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	# Si está atacando, no procesar movimiento
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
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
	if can_take_damage:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.is_in_group("enemigos"):
				take_damage(20)  # Aquí se llama a la función de daño
				can_take_damage = false
				# Crea el timer para reactivar el daño después de 1 segundo
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

func _input(event: InputEvent) -> void:
	# Detectar clic derecho del mouse
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_attacking:
			perform_attack()

# Función para ejecutar el ataque
func perform_attack() -> void:
	is_attacking = true
	
	# Ejecutar animación según la dirección
	match last_direction:
		"down":
			sprite.play("attack_down")
		"up":
			sprite.play("attack_up")
		"side":
			sprite.play("attack_side")

# Función que se ejecuta cuando termina una animación
func _on_animation_finished() -> void:
	# Solo procesar si era una animación de ataque
	if is_attacking:
		var current_anim = sprite.animation
		# Verificar que realmente terminó una animación de ataque
		if current_anim.begins_with("attack_"):
			is_attacking = false
			# Volver a la animación idle correspondiente
			match last_direction:
				"down":
					sprite.play("nidle_down")
				"up":
					sprite.play("nidle_up")
				"side":
					sprite.play("nidle_side")

# Función que se ejecuta cuando termina el cooldown de daño
func _on_damage_cooldown_finished() -> void:
	can_take_damage = true

# === FUNCIONES DE VIDA ===
func take_damage(amount):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	health_bar.value = current_health
	print("¡Recibiste daño! Vida actual: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	print("=== ¡PERSONAJE MUERTO! ===")
	# Aquí puedes agregar tu lógica de muerte después
	# Por ejemplo: queue_free() o cambiar a escena de game over
	#get_tree().change_scene_to_file("res://Scenes/menu.tscn")
