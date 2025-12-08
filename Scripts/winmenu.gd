extends Control

func _ready():
	# Esperar 2.5 segundos (o el tiempo que quieras)
	await get_tree().create_timer(5).timeout
	# Regresar al menú principal
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
