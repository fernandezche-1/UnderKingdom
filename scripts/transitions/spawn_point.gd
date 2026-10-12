extends Marker2D
class_name UnderkingdomSpawnPoint

@export var spawn_id: StringName = &"SpawnInicio"

func _ready() -> void:
    add_to_group("spawn_point")
