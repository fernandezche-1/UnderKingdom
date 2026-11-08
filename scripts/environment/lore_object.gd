extends UnderkingdomNPC
class_name UnderkingdomLoreObject

## Objeto de lore: un acta, un diario, unos restos. Con el Player cerca sale
## "E  Leer" y la E abre su diálogo (un JSON de dialogues/, igual que el de un
## NPC: reutiliza npc.gd y dialogue_ui). El objeto se queda y se puede releer.
## La primera lectura marca "lore_<lore_id>" en GameManager.completed_encounters,
## para una futura pestaña de diario (que no existe todavía).
## Detalle en docs/P50_OBJETO_DE_LORE.md.

signal read_first_time

## Identificador del texto. Sin él no se marca la lectura (el objeto sigue leyéndose).
@export var lore_id: String = ""


func _ready() -> void:
	super._ready()
	if lore_id.is_empty():
		push_warning("Objeto de lore %s: falta lore_id; la lectura no se guardará." % name)
	if dialogue_path.is_empty():
		push_warning("Objeto de lore %s: falta dialogue_path." % name)


## Id que se guarda en completed_encounters.
func encounter_key() -> String:
	return "lore_%s" % lore_id


func was_read() -> bool:
	return GameManager.is_encounter_completed(encounter_key())


func _after_dialogue(_player: Node) -> void:
	if lore_id.is_empty() or was_read():
		return
	GameManager.mark_encounter_completed(encounter_key())
	read_first_time.emit()
