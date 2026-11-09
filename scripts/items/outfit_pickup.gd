extends UnderkingdomSwordRecovery
class_name UnderkingdomOutfitPickup

## Atuendo que se recoge con E (P69): un id de GameManager.OUTFIT_DEFINITIONS.
## Generaliza la espada oxidada: el atuendo con espada la da si no se tenía
## (los harapos son E1, la espada oxidada). Al tomarlo se recuerda como objeto
## consumido y por outfits_found, así que no vuelve a salir.
@export var outfit_id: String = "soldado"
## Solo se ve desde que empieza la misión de la espada (la escena de la
## prisión o el carcelero la empiezan). Lo usa la espada oxidada del calabozo.
@export var requires_sword_mission: bool = false

const RAGS_OUTFIT_ID := "harapos"


func _ready() -> void:
	if notice_title.is_empty():
		notice_title = String(GameManager.get_outfit_info(outfit_id).get("name", outfit_id))
	if notice_text.is_empty():
		notice_text = String(GameManager.get_outfit_info(outfit_id).get("hint", ""))
	super._ready()


## Ya encontrado, o los harapos cuando ya se tiene espada: no darían nada.
func _already_owned() -> bool:
	if GameManager.has_outfit(outfit_id):
		return true
	return outfit_id == RAGS_OUTFIT_ID and GameManager.has_sword


func _is_available() -> bool:
	return not requires_sword_mission or GameManager.sword_mission_started


func _grant(player: UnderkingdomPlayer) -> bool:
	return GameManager.grant_outfit(outfit_id, player)
