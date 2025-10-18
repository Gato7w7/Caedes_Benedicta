extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_sound: AudioStreamPlayer2D = $DeathSound  # ← AGREGAR

# === VARIABLES DE VIDA ===
var max_health = 50.0
var current_health = 50.0
var is_dying = false  # Para evitar morir múltiples veces

func _ready() -> void:
	sprite.play("idle")
	add_to_group("enemigos")
	
	# Conectar la señal de animación terminada
	sprite.animation_finished.connect(_on_animation_finished)

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
		return  # Evitar ejecutar la muerte múltiples veces
	
	is_dying = true
	print("¡Enemigo eliminado!")
	death_sound.play()

	
	# Desactivar colisión para que el jugador pueda atravesarlo
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Sacar del grupo de enemigos para que no reciba más daño
	remove_from_group("enemigos")
	
	# Reproducir animación de muerte
	sprite.play("muerte")
	
	# La escena se eliminará cuando termine la animación

# Función que se ejecuta cuando termina una animación
func _on_animation_finished() -> void:
	# Si terminó la animación de muerte, eliminar el enemigo
	if sprite.animation == "muerte":
		queue_free()
