extends CharacterBody2D
signal enemy_died
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSound  

# === VARIABLES DE VIDA ===
var max_health = 50.0
var current_health = 50.0
var is_dying = false

# === VARIABLES DE MOVIMIENTO ===
var speed = 45.0
var chase_distance = 75.0
var stop_chase_distance = 150.0
var player: CharacterBody2D = null
var is_chasing = false

# === VARIABLES DE KNOCKBACK ===
var knockback_force = 80.0  # Fuerza del empuje
var is_knocked_back = false  # Si está siendo empujado

func _ready() -> void:
	sprite.play("idle")
	add_to_group("enemigos")
	sprite.animation_finished.connect(_on_animation_finished)
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("¡Advertencia! No se encontró al jugador.")

func _physics_process(delta: float) -> void:
	if is_dying or player == null:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Determinar si debe perseguir
	if distance_to_player < chase_distance:
		is_chasing = true
	elif distance_to_player > stop_chase_distance:
		is_chasing = false
	
	# Si está siendo empujado, no perseguir
	if is_knocked_back:
		move_and_slide()
		# Reducir velocidad gradualmente
		velocity = velocity.lerp(Vector2.ZERO, 0.1)
		if velocity.length() < 5:
			is_knocked_back = false
			velocity = Vector2.ZERO
		return
	
	if is_chasing:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		# Detectar colisión con el jugador y aplicar knockback
		for i in range(get_slide_collision_count()):
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider == player:
				# Aplicar knockback al enemigo
				apply_knockback()
				break
		
		# Animaciones
		if sprite.animation != "walk":
			sprite.play("walk")
		
		# Voltear sprite
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false
	else:
		velocity = Vector2.ZERO
		if sprite.animation != "idle" and sprite.animation != "muerte":
			sprite.play("idle")

func apply_knockback() -> void:
	# Calcular dirección opuesta al jugador
	var knockback_direction = (global_position - player.global_position).normalized()
	velocity = knockback_direction * knockback_force
	is_knocked_back = true
	
	# Timer corto para permitir volver a perseguir
	await get_tree().create_timer(0.3).timeout
	if is_knocked_back:  # Por si acaso ya se detuvo
		is_knocked_back = false

func take_damage(amount: float) -> void:
	if is_dying:
		return
	
	current_health -= amount
	print("Enemigo recibió ", amount, " de daño. Vida restante: ", current_health)
	
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
	
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	remove_from_group("enemigos")
	
	enemy_died.emit()
	
	sprite.play("muerte")

func _on_animation_finished() -> void:
	if sprite.animation == "muerte":
		queue_free()
