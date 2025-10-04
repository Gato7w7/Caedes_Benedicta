extends Node2D

@onready var level_container = $LevelContainer
@onready var player = $Jugador
var current_level = null

func _ready():
	# Apenas entres al Game, carga el nivel 1
	load_level("res://Scenes/level_1.tscn")

func load_level(level_path: String):
	# Si hubiera un nivel cargado, lo borramos
	if current_level:
		current_level.queue_free()

	# Instanciar el nivel
	var new_level = load(level_path).instantiate()
	level_container.add_child(new_level)
	current_level = new_level

	# Colocar jugador en StartPosition si existe
	var start_position = current_level.get_node_or_null("StartPosition")
	if start_position:
		player.position = start_position.position
