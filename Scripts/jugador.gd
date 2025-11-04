extends CharacterBody2D

const SPEED = 150.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox_area: Area2D = $HitboxArea
@onready var hitbox_shape: CollisionShape2D = $HitboxArea/HitboxShape
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound  # ← AGREGAR

var last_direction := "down"
var can_take_damage := true
var is_attacking := false

# === VARIABLES DE VIDA ===
var max_health = 100.0
var current_health = 100.0
@onready var health_bar = $"../CanvasLayer/Control/TextureProgressBar"

# === VARIABLES DE ATAQUE ===
var attack_damage = 25.0
var enemies_hit_this_attack = []  # Para evitar golpear múltiples veces

func _ready() -> void:
	sprite.play("nidle_down")
	
	# Configurar barra de vida
	health_bar.max_value = max_health
	health_bar.value = current_health
	
	# Conectar señales
	sprite.animation_finished.connect(_on_animation_finished)
	hitbox_area.body_entered.connect(_on_hitbox_body_entered)
	
	# Desactivar hitbox al inicio
	hitbox_area.monitoring = false

func _physics_process(delta: float) -> void:
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var input_vector = Vector2.ZERO
	
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
	
	# Detección de daño de enemigos
	if can_take_damage:
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider.is_in_group("enemigos"):
				take_damage(20)
				can_take_damage = false
				get_tree().create_timer(1.0).timeout.connect(_on_damage_cooldown_finished)
				break
	
	# Animaciones
	if input_vector == Vector2.ZERO:
		match last_direction:
			"down":
				sprite.play("nidle_down")
			"up":
				sprite.play("nidle_up")
			"side":
				sprite.play("nidle_side")
	else:
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
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not is_attacking:
			perform_attack()

func perform_attack() -> void:
	is_attacking = true
	enemies_hit_this_attack.clear()  # Resetear enemigos golpeados
	
	# Ajustar posición y rotación del hitbox según dirección
	adjust_hitbox_for_direction()
	
	# Ejecutar animación según la dirección
	match last_direction:
		"down":
			sprite.play("attack_down")
		"up":
			sprite.play("attack_up")
		"side":
			sprite.flip_h = !sprite.flip_h
			sprite.play("attack_side")
			
		# PRIMER SLASH - Reproducir sonido y activar hitbox
	attack_sound.play()  # ← PRIMER SONIDO
	await get_tree().create_timer(0.1).timeout
	enable_hitbox()
	
	# SEGUNDO SLASH - Reproducir sonido nuevamente
	await get_tree().create_timer(0.2).timeout  # Tiempo entre slashes
	attack_sound.play()  # ← SEGUNDO SONIDO
	
	# Activar hitbox después de unos frames (cuando el swing empieza)
	await get_tree().create_timer(0.1).timeout
	enable_hitbox()
	
	# Desactivar hitbox después del swing
	await get_tree().create_timer(0.3).timeout
	disable_hitbox()

# Ajustar posición del hitbox según la dirección
func adjust_hitbox_for_direction() -> void:
	var offset = Vector2.ZERO
	var shape = hitbox_shape.shape as RectangleShape2D
	
	# Ajustar según la dirección actual
	match last_direction:
		"down":
			offset = Vector2(0, -5)  # Adelante hacia abajo
			shape.size = Vector2(35, 25)
			hitbox_shape.rotation_degrees = 0
			
		"up":
			offset = Vector2(0, -35)  # Adelante hacia arriba
			shape.size = Vector2(35, 25)
			hitbox_shape.rotation_degrees = 0
			
		"side":
			shape.size = Vector2(25, 35)
			hitbox_shape.rotation_degrees = 0
			if sprite.flip_h:  # Mirando a la izquierda
				offset = Vector2(-20, -25)
			else:  # Mirando a la derecha
				offset = Vector2(20, -23)
	
	hitbox_area.position = offset
	

func enable_hitbox() -> void:
	hitbox_area.monitoring = true
	print("Hitbox activado")

func disable_hitbox() -> void:
	hitbox_area.monitoring = false
	print("Hitbox desactivado")

# Cuando el hitbox colisiona con algo
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemigos"):
		# Evitar golpear al mismo enemigo múltiples veces en un ataque
		if body in enemies_hit_this_attack:
			return
		
		enemies_hit_this_attack.append(body)
		
		# Llamar a la función de daño del enemigo
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
			print("¡Golpeaste a un enemigo!")

func _on_animation_finished() -> void:
	if is_attacking:
		var current_anim = sprite.animation
		if current_anim.begins_with("attack_"):
			is_attacking = false
			match last_direction:
				"down":
					sprite.play("nidle_down")
				"up":
					sprite.play("nidle_up")
				"side":
					sprite.flip_h = !sprite.flip_h
					sprite.play("nidle_side")

func _on_damage_cooldown_finished() -> void:
	can_take_damage = true

func take_damage(amount):
	current_health -= amount
	current_health = clamp(current_health, 0, max_health)
	health_bar.value = current_health
	print("¡Recibiste daño! Vida actual: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	print("=== ¡PERSONAJE MUERTO! ===")
