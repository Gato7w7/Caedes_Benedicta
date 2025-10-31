extends Button

# Este script se adjunta al botón de idioma en tu menú

func _ready():
	# Actualizar el texto del botón con el idioma actual
	update_button_text()
	# Conectar la señal de presionado
	pressed.connect(_on_pressed)

func _on_pressed():
	# Alternar entre idiomas
	var current = LocaleManager.get_current_locale()
	
	if current == "spanish":
		LocaleManager.set_locale("english")
	else:
		LocaleManager.set_locale("spanish")
	
	# Actualizar el texto del botón
	update_button_text()
	
	# Si necesitas recargar la escena actual para aplicar cambios
	# descomenta la siguiente línea:
	# get_tree().reload_current_scene()

func update_button_text():
	var current = LocaleManager.get_current_locale()
	if current == "spanish":
		text = "Idioma: Español"
	else:
		text = "Language: English"
