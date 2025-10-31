extends Node

# Este script debe ser un AutoLoad (Singleton)
# Ve a Proyecto -> Configuración del Proyecto -> AutoLoad
# Agrega este script con el nombre "LocaleManager"

# Idiomas disponibles
const LANGUAGES = {
	"spanish": "es",
	"english": "en"
}

# Clave para guardar el idioma en la configuración
const LOCALE_SAVE_KEY = "locale"

func _ready():
	# Cargar el idioma guardado o usar español por defecto
	var saved_locale = load_locale()
	if saved_locale:
		set_locale(saved_locale)
	else:
		set_locale("spanish")

# Cambiar el idioma actual
func set_locale(language: String):
	if language in LANGUAGES:
		TranslationServer.set_locale(LANGUAGES[language])
		save_locale(language)
	else:
		push_error("Idioma no válido: " + language)

# Obtener el idioma actual
func get_current_locale() -> String:
	var current = TranslationServer.get_locale()
	for lang_name in LANGUAGES:
		if LANGUAGES[lang_name] == current:
			return lang_name
	return "spanish"

# Guardar idioma en configuración
func save_locale(language: String):
	var config = ConfigFile.new()
	config.set_value("settings", LOCALE_SAVE_KEY, language)
	config.save("user://settings.cfg")

# Cargar idioma guardado
func load_locale() -> String:
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		return config.get_value("settings", LOCALE_SAVE_KEY, "spanish")
	return ""
