extends CharacterBody2D

signal enemy_died  # Nueva señal

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
	
	if distance_to_player < chase_distance:
		is_chasing = true
	elif distance_to_player > stop_chase_distance:
		is_chasing = false
	
	if is_chasing:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		if sprite.animation != "walk":
			sprite.play("walk")
		
		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false
	else:
		velocity = Vector2.ZERO
		if sprite.animation != "idle" and sprite.animation != "muerte":
			sprite.play("idle")

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
	
	enemy_died.emit()  # Emitir señal antes de morir
	
	sprite.play("muerte")

func _on_animation_finished() -> void:
	if sprite.animation == "muerte":
		queue_free()
