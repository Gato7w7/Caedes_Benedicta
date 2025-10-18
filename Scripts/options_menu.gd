extends Control

@onready var mute_checkbox: CheckBox = $MarginContainer/VBoxContainer/MuteCheckBox
@onready var volume_slider: HSlider = $MarginContainer/VBoxContainer/VolumeSlider
@onready var volume_label: Label = $MarginContainer/VBoxContainer/VolumeLabel
@onready var back_button: Button = $MarginContainer/VBoxContainer/BackButton

# Índices de los buses de audio
const MASTER_BUS = 0

func _ready() -> void:
	# Cargar configuración guardada
	load_audio_settings()
	
	# Conectar señales
	mute_checkbox.toggled.connect(_on_mute_toggled)
	volume_slider.value_changed.connect(_on_volume_changed)
	back_button.pressed.connect(_on_back_pressed)
	
	# Actualizar estado inicial
	_update_volume_slider_state()
	_update_volume_label()

func _on_mute_toggled(is_muted: bool) -> void:
	# Mutear o desmutear el audio
	AudioServer.set_bus_mute(MASTER_BUS, is_muted)
	
	# Habilitar/deshabilitar el slider
	_update_volume_slider_state()
	
	# Guardar configuración
	save_audio_settings()

func _on_volume_changed(value: float) -> void:
	# Convertir el valor del slider (0-100) a decibelios
	# -80 dB es esencialmente silencio, 0 dB es volumen máximo
	var db = linear_to_db(value / 100.0)
	AudioServer.set_bus_volume_db(MASTER_BUS, db)
	
	# Actualizar etiqueta
	_update_volume_label()
	
	# Guardar configuración
	save_audio_settings()

func _update_volume_slider_state() -> void:
	# Deshabilitar slider si está muteado
	volume_slider.editable = not mute_checkbox.button_pressed

func _update_volume_label() -> void:
	# Mostrar el volumen como porcentaje
	volume_label.text = "Volumen: %d%%" % int(volume_slider.value)

func _on_back_pressed() -> void:
	# Volver al menú principal
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func save_audio_settings() -> void:
	var config = ConfigFile.new()
	
	config.set_value("audio", "muted", mute_checkbox.button_pressed)
	config.set_value("audio", "volume", volume_slider.value)
	
	config.save("user://audio_settings.cfg")

func load_audio_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load("user://audio_settings.cfg")
	
	if err == OK:
		# Cargar valores guardados
		var is_muted = config.get_value("audio", "muted", false)
		var volume = config.get_value("audio", "volume", 100.0)
		
		mute_checkbox.button_pressed = is_muted
		volume_slider.value = volume
		
		# Aplicar configuración
		AudioServer.set_bus_mute(MASTER_BUS, is_muted)
		var db = linear_to_db(volume / 100.0)
		AudioServer.set_bus_volume_db(MASTER_BUS, db)
	else:
		# Valores por defecto
		mute_checkbox.button_pressed = false
		volume_slider.value = 100.0
