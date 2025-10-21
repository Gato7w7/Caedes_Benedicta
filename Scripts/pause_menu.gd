extends Control

@onready var pause_label = $PanelContainer/VBoxContainer/Pause
@onready var resume_button = $PanelContainer/VBoxContainer/Reanudar
@onready var exit_button = $PanelContainer/VBoxContainer/Exit

func _ready():
	# Conectar las señales de los botones
	resume_button.pressed.connect(_on_resume_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Ocultar el menú de pausa al inicio
	hide()
	
	# Configurar el process mode para que funcione cuando el juego esté pausado
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	# Detectar cuando se presiona ESC para pausar/despausar
	if event.is_action_pressed("ui_cancel"):  # ESC por defecto
		toggle_pause()

func toggle_pause():
	# Alternar entre pausado y no pausado
	var is_paused = not get_tree().paused
	get_tree().paused = is_paused
	visible = is_paused
	
	# Opcional: liberar el mouse cuando está pausado
	if is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED  # Cambia según tu juego

func _on_resume_pressed():
	# Reanudar el juego
	toggle_pause()

func _on_exit_pressed():
	# Desactivar la pausa antes de salir
	get_tree().paused = false
	
	# Opción 1: Volver al menú principal
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
	
	# Opción 2: Salir completamente del juego
	# get_tree().quit()
	
	# Opción 3: Reiniciar la escena actual
	# get_tree().reload_current_scene()
