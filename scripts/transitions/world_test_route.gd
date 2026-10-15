extends Node
class_name UnderkingdomWorldTestRoute

## Ruta PROVISIONAL para probar los mapas existentes sin comprometer todavía
## la progresión definitiva. Crea portales visibles cerca del punto de prueba.
## Azul = siguiente mapa. Morado = mapa anterior. Se activan con E.

@export_file("*.tscn") var previous_scene_path: String
@export_file("*.tscn") var next_scene_path: String
@export var spawn_position: Vector2 = Vector2(160.0, 160.0)
## Opcionales: permiten que entrar desde el mapa anterior y regresar desde el
## siguiente usen puntos diferentes. Vector2.ZERO conserva spawn_position.
@export var entrance_spawn_position: Vector2 = Vector2.ZERO
@export var exit_spawn_position: Vector2 = Vector2.ZERO
@export var previous_portal_position: Vector2 = Vector2.ZERO
@export var next_portal_position: Vector2 = Vector2.ZERO
@export var enabled: bool = true
@export var show_portals: bool = true
@export var previous_label: String = "E - MAPA ANTERIOR"
@export var next_label: String = "E - SIGUIENTE MAPA"
@export var next_requires_world1_boss_key: bool = false
@export var next_requires_w2_knight_defeated: bool = false

const PREVIOUS_COLOR := Color(0.68, 0.22, 0.88, 0.72)
const NEXT_COLOR := Color(0.12, 0.52, 1.0, 0.72)
const PORTAL_SIZE := Vector2(42.0, 70.0)


func _ready() -> void:
    if not enabled:
        return

    var entrada := spawn_position if entrance_spawn_position == Vector2.ZERO else entrance_spawn_position
    var salida := spawn_position if exit_spawn_position == Vector2.ZERO else exit_spawn_position

    _ensure_spawn_point(&"SpawnInicio", spawn_position)
    _ensure_spawn_point(&"SpawnEntrada", entrada)
    _ensure_spawn_point(&"SpawnSalida", salida)

    if not show_portals:
        return

    if not previous_scene_path.is_empty():
        _create_portal(
            "PortalAnteriorPrueba",
            previous_portal_position,
            previous_scene_path,
            &"SpawnSalida",
            previous_label,
            PREVIOUS_COLOR,
            false,
            false
        )

    if not next_scene_path.is_empty():
        _create_portal(
            "PortalSiguientePrueba",
            next_portal_position,
            next_scene_path,
            &"SpawnEntrada",
            next_label,
            NEXT_COLOR,
            next_requires_world1_boss_key,
            next_requires_w2_knight_defeated
        )


func _ensure_spawn_point(id: StringName, position_value: Vector2) -> void:
    for node in get_tree().get_nodes_in_group("spawn_point"):
        if node is Marker2D and node.get("spawn_id") == id:
            return

    var marker := UnderkingdomSpawnPoint.new()
    marker.name = String(id)
    marker.spawn_id = id
    marker.position = position_value
    get_parent().call_deferred("add_child", marker)


func _create_portal(
    portal_name: String,
    position_value: Vector2,
    target_path: String,
    target_spawn: StringName,
    text: String,
    color: Color,
    requires_world1_key: bool,
    requires_w2_knight: bool
) -> void:
    if get_parent().get_node_or_null(portal_name) != null:
        return

    var portal := UnderkingdomMapTransition.new()
    portal.name = portal_name
    portal.position = position_value
    portal.target_scene_path = target_path
    portal.target_spawn_id = target_spawn
    portal.require_interaction = true
    portal.prompt_text = text
    portal.marker_color = color
    portal.require_world1_boss_key = requires_world1_key
    portal.require_w2_knight_defeated = requires_w2_knight
    portal.collision_layer = 0
    portal.collision_mask = 1
    portal.z_index = 50

    var shape_node := CollisionShape2D.new()
    shape_node.name = "CollisionShape2D"
    var shape := RectangleShape2D.new()
    shape.size = PORTAL_SIZE
    shape_node.shape = shape
    portal.add_child(shape_node)

    var marker := Polygon2D.new()
    marker.name = "Marker"
    marker.polygon = PackedVector2Array([
        Vector2(-PORTAL_SIZE.x * 0.5, -PORTAL_SIZE.y * 0.5),
        Vector2(PORTAL_SIZE.x * 0.5, -PORTAL_SIZE.y * 0.5),
        Vector2(PORTAL_SIZE.x * 0.5, PORTAL_SIZE.y * 0.5),
        Vector2(-PORTAL_SIZE.x * 0.5, PORTAL_SIZE.y * 0.5)
    ])
    marker.color = color
    portal.add_child(marker)

    var prompt := Label.new()
    prompt.name = "Prompt"
    prompt.text = text
    prompt.position = Vector2(-82.0, -54.0)
    prompt.z_index = 2
    prompt.visible = false
    prompt.modulate = Color.WHITE
    portal.add_child(prompt)

    get_parent().call_deferred("add_child", portal)
