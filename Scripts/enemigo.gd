extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# === VARIABLES DE VIDA ===
var max_health = 50.0
var current_health = 50.0

func _ready() -> void:
	sprite.play("idle")
	add_to_group("enemigos")  # Asegurarse de estar en el grupo

# Función para recibir daño
func take_damage(amount: float) -> void:
	current_health -= amount
	print("Enemigo recibió ", amount, " de daño. Vida restante: ", current_health)
	
	# Efecto visual opcional (parpadeo)
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if current_health <= 0:
		die()

func die() -> void:
	print("¡Enemigo eliminado!")
	queue_free()
