# save_slot_selection.gd
extends Control

@onready var slot_1_btn = $CenterContainer/Panel/VBoxContainer/Slot1Button
@onready var slot_2_btn = $CenterContainer/Panel/VBoxContainer/Slot2Button
@onready var slot_3_btn = $CenterContainer/Panel/VBoxContainer/Slot3Button
@onready var back_btn = $CenterContainer/Panel/VBoxContainer/BackButton

func _ready():
	# Conectar botones
	slot_1_btn.pressed.connect(_on_slot_pressed.bind(1))
	slot_2_btn.pressed.connect(_on_slot_pressed.bind(2))
	slot_3_btn.pressed.connect(_on_slot_pressed.bind(3))
	back_btn.pressed.connect(_on_back_pressed)
	
	# Actualizar texto de botones
	update_slot_buttons()

func update_slot_buttons():
	# Actualizar texto con info de las ranuras
	slot_1_btn.text = "Ranura 1: " + LocaleManager.get_slot_info(1)
	slot_2_btn.text = "Ranura 2: " + LocaleManager.get_slot_info(2)
	slot_3_btn.text = "Ranura 3: " + LocaleManager.get_slot_info(3)
	
	# Opcional: Cambiar color si la ranura está vacía
	_update_button_style(slot_1_btn, LocaleManager.slot_has_data(1))
	_update_button_style(slot_2_btn, LocaleManager.slot_has_data(2))
	_update_button_style(slot_3_btn, LocaleManager.slot_has_data(3))

func _update_button_style(button: Button, has_data: bool):
	# Esto es opcional: cambia el estilo visual según si hay datos
	if has_data:
		button.modulate = Color(1, 1, 1, 1)  # Normal
	else:
		button.modulate = Color(0.8, 0.8, 0.8, 1)  # Más tenue

func _on_slot_pressed(slot_number: int):
	print("=== Ranura seleccionada: ", slot_number, " ===")
	
	# Cargar nivel (retorna level_1 si está vacío)
	var level_to_load = LocaleManager.load_slot(slot_number)
	
	print("Cargando nivel: ", level_to_load)
	
	# Cambiar a game.tscn
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
