extends Node2D
class_name UnderkingdomPrisonGuardMission

## Conserva el inicio de la misión en escenas antiguas. El equipo se recupera
## únicamente en PuntoEquipamientoFuturo; ningún enemigo entrega una espada.
func _ready() -> void:
	if not GameManager.has_sword and not GameManager.castle_equipment_recovered:
		GameManager.start_sword_mission()
