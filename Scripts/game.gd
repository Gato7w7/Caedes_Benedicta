extends Node2D

@onready var level_container = $LevelContainer
@onready var player = $Jugador

var current_level = null

# === SISTEMA DE OLEADAS ===
var enemies_alive = 0
var current_wave = 1
var enemies_per_wave = [3, 5, 7, 10, 15]  # Enemigos por oleada (ajusta a tu gusto)
var enemy_scene = preload("res://Scenes/enemigo.tscn")  # Ajusta la ruta a tu escena de enemigo

var min_distance_from_player = 150.0  # Distancia mínima del jugador
var spawn_margin_from_player = 300.0  # Distancia máxima del jugador (aparecen en un anillo)

func _ready():
	load_level("res://Scenes/level_1.tscn")

func load_level(level_path: String):
	if current_level:
		current_level.queue_free()
	
	var new_level = load(level_path).instantiate()
	level_container.add_child(new_level)
	current_level = new_level
	
	var start_position = current_level.get_node_or_null("StartPosition")
	if start_position:
		player.position = start_position.position
	
	# Reiniciar oleadas al cargar nivel
	current_wave = 1
	
	# Esperar un frame y conectar enemigos existentes
	await get_tree().process_frame
	connect_existing_enemies()

func connect_existing_enemies():
	var enemies = get_tree().get_nodes_in_group("enemigos")
	enemies_alive = 0
	
	for enemy in enemies:
		# Solo contar nodos que sean CharacterBody2D (los enemigos reales)
		if enemy is CharacterBody2D and enemy.has_signal("enemy_died"):
			enemies_alive += 1
			if not enemy.enemy_died.is_connected(_on_enemy_died):
				enemy.enemy_died.connect(_on_enemy_died)
	
	print("Oleada ", current_wave, " - Enemigos: ", enemies_alive)

func _on_enemy_died():
	enemies_alive -= 1
	print("Enemigos restantes: ", enemies_alive)
	
	if enemies_alive <= 0:
		start_next_wave()

func start_next_wave():
	current_wave += 1
	print("¡Oleada ", current_wave, " comenzando!")
	
	# Determinar cuántos enemigos spawnear
	var wave_index = current_wave - 1
	var num_enemies = 0
	
	if wave_index < enemies_per_wave.size():
		num_enemies = enemies_per_wave[wave_index]
	else:
		# Si superamos el array, seguir aumentando
		num_enemies = enemies_per_wave[-1] + (wave_index - enemies_per_wave.size() + 1) * 3
	
	# Pequeña pausa antes de la siguiente oleada
	await get_tree().create_timer(1.5).timeout
	
	spawn_wave(num_enemies)

func spawn_wave(num_enemies: int):
	enemies_alive = num_enemies
	
	for i in range(num_enemies):
		var enemy = enemy_scene.instantiate()
		var spawn_pos = get_random_spawn_position()
		enemy.global_position = spawn_pos
		
		# Agregar al nivel actual
		current_level.add_child(enemy)
		
		# Conectar la señal
		enemy.enemy_died.connect(_on_enemy_died)
	
	print("Spawneados ", num_enemies, " enemigos")

func get_random_spawn_position() -> Vector2:
	# Obtener límites del área de spawn desde el nivel
	var spawn_min_node = current_level.get_node_or_null("SpawnMin")
	var spawn_max_node = current_level.get_node_or_null("SpawnMax")
	
	var spawn_area_min: Vector2
	var spawn_area_max: Vector2
	
	if spawn_min_node and spawn_max_node:
		spawn_area_min = spawn_min_node.global_position
		spawn_area_max = spawn_max_node.global_position
	else:
		# Fallback si no existen los marcadores
		push_warning("No se encontraron SpawnMin/SpawnMax en el nivel. Usando valores por defecto.")
		spawn_area_min = Vector2(50, 50)
		spawn_area_max = Vector2(500, 400)
	
	var pos = Vector2.ZERO
	var attempts = 0
	var max_attempts = 100
	
	while attempts < max_attempts:
		pos = Vector2(
			randf_range(spawn_area_min.x, spawn_area_max.x),
			randf_range(spawn_area_min.y, spawn_area_max.y)
		)
		
		# Verificar que esté a una distancia adecuada del jugador
		if player:
			var dist = pos.distance_to(player.global_position)
			if dist >= min_distance_from_player and dist <= spawn_margin_from_player:
				break
		else:
			break
		
		attempts += 1
	
	# Si no encontró posición ideal, al menos que no esté encima del jugador
	if attempts >= max_attempts and player:
		var direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		pos = player.global_position + direction * min_distance_from_player
		pos.x = clamp(pos.x, spawn_area_min.x, spawn_area_max.x)
		pos.y = clamp(pos.y, spawn_area_min.y, spawn_area_max.y)
	
	return pos
