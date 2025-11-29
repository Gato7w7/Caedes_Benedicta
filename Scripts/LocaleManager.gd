# LocaleManager.gd (Autoload)
# Maneja tanto idiomas como guardado de partidas
extends Node

# ==================== SISTEMA DE IDIOMAS ====================
const LANGUAGES = {
	"spanish": "es",
	"english": "en"
}

const LOCALE_SAVE_KEY = "locale"
const CONFIG_FILE_PATH = "user://settings.cfg"

# ==================== SISTEMA DE GUARDADO ====================
const SAVE_FILE_PATH = "user://save_game.dat"
var current_slot: int = -1  # Ranura activa (-1 = ninguna)

# Estructura de datos de guardado (3 ranuras)
var save_data = {
	"slot_1": {"level": "", "exists": false, "timestamp": ""},
	"slot_2": {"level": "", "exists": false, "timestamp": ""},
	"slot_3": {"level": "", "exists": false, "timestamp": ""}
}

func _ready():
	# Cargar idioma guardado
	var saved_locale = load_locale()
	if saved_locale:
		set_locale(saved_locale)
	else:
		set_locale("spanish")
	
	# Cargar datos de guardado
	load_all_slots()

# ==================== FUNCIONES DE IDIOMA ====================
func set_locale(language: String):
	if language in LANGUAGES:
		TranslationServer.set_locale(LANGUAGES[language])
		save_locale(language)
	else:
		push_error("Idioma no válido: " + language)

func get_current_locale() -> String:
	var current = TranslationServer.get_locale()
	for lang_name in LANGUAGES:
		if LANGUAGES[lang_name] == current:
			return lang_name
	return "spanish"

func save_locale(language: String):
	var config = ConfigFile.new()
	# Cargar archivo existente para no sobrescribir otras configuraciones
	config.load(CONFIG_FILE_PATH)
	config.set_value("settings", LOCALE_SAVE_KEY, language)
	config.save(CONFIG_FILE_PATH)

func load_locale() -> String:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE_PATH)
	if err == OK:
		return config.get_value("settings", LOCALE_SAVE_KEY, "spanish")
	return ""

# ==================== FUNCIONES DE GUARDADO ====================

# Guardar progreso del jugador
func save_current_progress(level_path: String):
	if current_slot < 1 or current_slot > 3:
		push_warning("No hay ranura activa para guardar")
		return
	
	var slot_key = "slot_" + str(current_slot)
	save_data[slot_key]["level"] = level_path
	save_data[slot_key]["exists"] = true
	save_data[slot_key]["timestamp"] = Time.get_datetime_string_from_system()
	
	save_to_file()
	print("✓ Progreso guardado en ranura ", current_slot, ": ", level_path)

# Cargar una ranura específica
func load_slot(slot_number: int) -> String:
	if slot_number < 1 or slot_number > 3:
		push_error("Ranura inválida: ", slot_number)
		return ""
	
	var slot_key = "slot_" + str(slot_number)
	current_slot = slot_number
	
	if save_data[slot_key]["exists"]:
		print("Cargando partida de ranura ", slot_number)
		return save_data[slot_key]["level"]
	else:
		print("Iniciando nueva partida en ranura ", slot_number)
		return "res://Scenes/level_1.tscn"  # Nivel inicial

# Borrar una ranura
func delete_slot(slot_number: int):
	var slot_key = "slot_" + str(slot_number)
	save_data[slot_key]["level"] = ""
	save_data[slot_key]["exists"] = false
	save_data[slot_key]["timestamp"] = ""
	save_to_file()
	print("Ranura ", slot_number, " eliminada")

# Verificar si una ranura tiene datos
func slot_has_data(slot_number: int) -> bool:
	var slot_key = "slot_" + str(slot_number)
	return save_data[slot_key]["exists"]

# Obtener información de una ranura (para mostrar en UI)
func get_slot_info(slot_number: int) -> String:
	var slot_key = "slot_" + str(slot_number)
	if save_data[slot_key]["exists"]:
		var level_path = save_data[slot_key]["level"]
		var level_name = level_path.get_file().get_basename()
		return level_name.capitalize()
	return "Vacío"

# Obtener fecha/hora de guardado (opcional, para mostrar en UI)
func get_slot_timestamp(slot_number: int) -> String:
	var slot_key = "slot_" + str(slot_number)
	if save_data[slot_key]["exists"]:
		return save_data[slot_key]["timestamp"]
	return ""

# Guardar todos los datos al archivo
func save_to_file():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()
		print("Datos guardados en disco")
	else:
		push_error("Error al guardar archivo")

# Cargar todos los datos desde archivo
func load_all_slots():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No hay archivo de guardado previo")
		return
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		save_data = file.get_var()
		file.close()
		print("Datos de guardado cargados")
	else:
		push_error("Error al cargar archivo de guardado")

# Resetear ranura activa (al volver al menú sin salir del juego)
func clear_active_slot():
	current_slot = -1
	print("Ranura activa limpiada")
