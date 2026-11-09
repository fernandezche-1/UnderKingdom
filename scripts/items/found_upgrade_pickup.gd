extends UnderkingdomAbilityPickup
class_name UnderkingdomFoundUpgradePickup

## Objeto del mapa que da una mejora encontrada (GameManager.FOUND_UPGRADE_DEFINITIONS):
## la empuñadura del alcaide, el amuleto de la guardia. Reutiliza la recogida de
## la reliquia de habilidad. Una vez recogida no vuelve a aparecer en la partida.
## Detalle en docs/P51_MEJORA_ENCONTRADA.md.

## Id de GameManager.FOUND_UPGRADE_DEFINITIONS.
@export var upgrade_id: String = ""


func _already_owned() -> bool:
    if upgrade_id.is_empty() or not GameManager.FOUND_UPGRADE_DEFINITIONS.has(upgrade_id):
        push_warning("Mejora encontrada %s: upgrade_id '%s' desconocido." % [name, upgrade_id])
        return true
    return GameManager.has_found_upgrade(upgrade_id)


func _grant() -> void:
    GameManager.grant_found_upgrade(upgrade_id)
