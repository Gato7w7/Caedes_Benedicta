extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSound  

# === VARIABLES DE VIDA ===
var max_health = 50.0
var current_health = 50.0
var is_dying = false

# === VARIABLES DE MOVIMIENTO ===
var speed = 45.0  # Velocidad del enemigo
var chase_distance = 75.0  # Distancia a la que empieza a perseguir
var stop_chase_distance = 150.0  # Distancia a la que deja de perseguir
var player: CharacterBody2D = null
var is_chasing = false

func _ready() -> void:
	sprite.play("idle")
	add_to_group("enemigos")
	
	# Conectar la señal de animación terminada
	sprite.animation_finished.connect(_on_animation_finished)
	
	# Buscar al jugador en la escena
	await get_tree().process_frame  # Esperar un frame para asegurar que todo está cargado
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("¡Advertencia! No se encontró al jugador. Asegúrate de que esté en el grupo 'player'")

func _physics_process(delta: float) -> void:
	# No moverse si está muriendo o no hay jugador
	if is_dying or player == null:
		return
	
	# Calcular distancia al jugador
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Decidir si perseguir o detenerse
	if distance_to_player < chase_distance:
		is_chasing = true
	elif distance_to_player > stop_chase_distance:
		is_chasing = false
	
	# Si está persiguiendo, moverse hacia el jugador
	if is_chasing:
		# Calcular dirección hacia el jugador
		var direction = (player.global_position - global_position).normalized()
		
		# Aplicar movimiento
		velocity = direction * speed
		move_and_slide()
		
		# Cambiar animación a caminar
		if sprite.animation != "walk":
			sprite.play("walk")
		
		# Voltear el sprite según la dirección
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false
	else:
		# Si no está persiguiendo, quedarse quieto
		velocity = Vector2.ZERO
		if sprite.animation != "idle" and sprite.animation != "muerte":
			sprite.play("idle")

# Función para recibir daño
func take_damage(amount: float) -> void:
	# No recibir daño si ya está muriendo
	if is_dying:
		return
	
	current_health -= amount
	print("Enemigo recibió ", amount, " de daño. Vida restante: ", current_health)
	
	# Efecto visual opcional (parpadeo)
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if current_health <= 0:
		die()

func die() -> void:
	if is_dying:
		return
	
	is_dying = true
	print("¡Enemigo eliminado!")
	death_sound.play()
	
	# Detener movimiento
	velocity = Vector2.ZERO
	
	# Desactivar colisión para que el jugador pueda atravesarlo
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Sacar del grupo de enemigos para que no reciba más daño
	remove_from_group("enemigos")
	
	# Reproducir animación de muerte
	sprite.play("muerte")

# Función que se ejecuta cuando termina una animación
func _on_animation_finished() -> void:
	if sprite.animation == "muerte":
		queue_free()
