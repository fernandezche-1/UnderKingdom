extends Control
## Cinemática inicial: ilustraciones fijas sobre una sola pista de narración.
## "Nueva partida" pasa por aquí antes de la prisión. Espacio, Enter, Esc o los
## botones A/B del mando la omiten.
##
## Para afinar los tiempos, cambiar `duration` en `slides`: es lo que dura cada
## ilustración en pantalla, en segundos, y cada una arranca donde acaba la
## anterior. Al mover un corte hay que compensar en la diapositiva siguiente
## para no desplazar las demás. La tabla con todos los cortes está en
## `docs/P41_CINEMATICA_INICIAL.md`. Si se editan en el Inspector, el valor
## guardado en la escena sustituye a esta lista.

const VOICE_SILENT_DB: float = -60.0

## Cada corte cae en una pausa de la voz, a mitad del fundido (negro completo).
@export var fade_time: float = 0.35
@export_file("*.tscn") var next_scene_path: String = "res://escenas/mapas/prologo_prision/camara_sellado_alma.tscn"
## Cada elemento: {"texture": Texture2D, "duration": float}. El comentario de
## cada línea dice en qué segundo del audio arranca y qué frase lo acompaña.
@export var slides: Array[Dictionary] = [
	{"texture": preload("res://assets/cinematica/01_castillo_en_paz.png"), "duration": 6.6}, # 0.00 "Hace muchos años..."
	{"texture": preload("res://assets/cinematica/02_rey_y_primera_reina.png"), "duration": 7.6}, # 6.60 "Gobernado por un rey justo..."
	{"texture": preload("res://assets/cinematica/03_enfermedad_de_la_primera_reina.png"), "duration": 7.9}, # 14.20 "Pero incluso los días más brillantes..."
	{"texture": preload("res://assets/cinematica/04_funeral_de_la_primera_reina.png"), "duration": 7.2}, # 22.10 "Su muerte dejó un vacío..."
	{"texture": preload("res://assets/cinematica/05_guerra_y_asedio.png"), "duration": 5.45}, # 29.30 "Sus enemigos aprovecharon..."
	{"texture": preload("res://assets/cinematica/06_princesa_cautiva.png"), "duration": 6.6}, # 34.75 "...arrebatando incontables vidas. Tras años de sufrimiento,"
	{"texture": preload("res://assets/cinematica/07_matrimonio_por_la_paz.png"), "duration": 4.55}, # 41.35 "una nueva unión prometió..."
	{"texture": preload("res://assets/cinematica/08_reina_ayuda_al_pueblo.png"), "duration": 4.1}, # 45.90 "La nueva soberana..."
	{"texture": preload("res://assets/cinematica/09_reina_y_los_prisioneros.png"), "duration": 4.8}, # 50.00 "Su generosidad..."
	{"texture": preload("res://assets/cinematica/10_magia_prohibida.png"), "duration": 3.85}, # 54.80 "Sin embargo, detrás de las puertas del castillo,"
	{"texture": preload("res://assets/cinematica/11_poder_del_agua.png"), "duration": 4.75}, # 58.65 "un poder desconocido..."
	{"texture": preload("res://assets/cinematica/12_rey_bajo_control.png"), "duration": 9.25}, # 63.40 "Con el paso del tiempo..."
	{"texture": preload("res://assets/cinematica/13_guerrero_enfrenta_reina.png"), "duration": 8.95}, # 72.65 "Cuando la tragedia alcanzó al rey..."
	{"texture": preload("res://assets/cinematica/14_guerrero_acusado.png"), "duration": 7.65}, # 81.60 "Despojado de su honor..."
	{"texture": preload("res://assets/cinematica/15_guerrero_encadenado.png"), "duration": 5.85}, # 89.25 "Su nombre fue condenado al olvido..."
	# El audio acaba en 100.2: lo que sobra deja la última imagen en silencio.
	{"texture": preload("res://assets/cinematica/16_despertar_en_la_mazmorra.png"), "duration": 6.6}, # 95.10 "y en las profundidades del castillo..."
]

var current_slide: int = -1
var _next_cut_time: float = 0.0
var _clock: float = 0.0
var _finishing: bool = false
var _fade_tween: Tween

@onready var _illustration: TextureRect = $Ilustracion
@onready var _fade: ColorRect = $Fundido
@onready var _voice: AudioStreamPlayer = $Voz


func _ready() -> void:
	if slides.is_empty():
		_finish()
		return
	_change_slide(0)
	_voice.play()


func _process(delta: float) -> void:
	if _finishing:
		return
	# Manda el audio para no desfasarse; al terminar la voz sigue el reloj propio.
	_clock += delta
	if _voice.playing:
		_clock = _voice.get_playback_position()
	if _clock < _next_cut_time - fade_time:
		return
	if current_slide + 1 < slides.size():
		_change_slide(current_slide + 1)
	else:
		_finish()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_finish()


func _change_slide(index: int) -> void:
	current_slide = index
	_next_cut_time += float(slides[index].get("duration", 0.0))
	var texture: Texture2D = slides[index].get("texture") as Texture2D
	_fade_tween = create_tween()
	if index > 0:
		_fade_tween.tween_property(_fade, "modulate:a", 1.0, fade_time)
	_fade_tween.tween_callback(_set_illustration.bind(texture))
	_fade_tween.tween_property(_fade, "modulate:a", 0.0, fade_time)


func _set_illustration(texture: Texture2D) -> void:
	_illustration.texture = texture


## Fundido a negro y salto a la prisión, tanto al omitir como al acabar.
func _finish() -> void:
	if _finishing:
		return
	_finishing = true
	if _fade_tween != null:
		_fade_tween.kill()
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(_fade, "modulate:a", 1.0, fade_time)
	tween.tween_property(_voice, "volume_db", VOICE_SILENT_DB, fade_time)
	await tween.finished
	var error: Error = get_tree().change_scene_to_file(next_scene_path)
	if error != OK:
		push_error("No se pudo salir de la cinemática. Error de escena: %s" % error)
