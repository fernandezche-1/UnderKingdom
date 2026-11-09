extends UnderkingdomAbilityPickup
class_name UnderkingdomLifeFragmentPickup

## Fragmento de vida del mapa: cuatro dan un corazón de vida máxima (tope 6) y
## llenan la vida. Reutiliza la recogida de la reliquia de habilidad. Una vez
## recogido no vuelve a aparecer en la partida. Detalle en docs/P54_FRAGMENTO_DE_VIDA.md.

## Id único del fragmento en toda la partida (por ejemplo "castillo_1").
## Con un id repetido el segundo no cuenta.
@export var fragment_id: String = ""


func _already_owned() -> bool:
	if fragment_id.is_empty():
		push_warning("Fragmento de vida %s: fragment_id vacío." % name)
		return true
	return GameManager.has_life_fragment(fragment_id)


func _grant() -> void:
	GameManager.grant_life_fragment(fragment_id)
