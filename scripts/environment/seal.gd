extends UnderkingdomLever
class_name UnderkingdomSeal

## Sello de un contador de sellos ([S3] del cementerio, [S7] de las
## profundidades; P55). Hereda de la palanca: mismo aviso, mismo cuadro que
## cambia y la misma tecla E. Se activa de una de dos formas:
##  - con E al llegar a él (la tumba de las plataformas), o
##  - solo, cuando GameManager marca `listen_encounter` (la arena de la fosa,
##    el Capitán). Con `listen_encounter` relleno la E no hace nada.
## Cada sello se guarda como "sello:<seal_group>:<seal_id>" en
## completed_encounters. Al activarse los `seal_total` sellos del grupo se marca
## "sellos:<seal_group>" y se abre toda barrera con ese `open_on_seal_group`,
## en esta escena o en otra, aunque esté fuera de pantalla.

@export_category("Sello")
## Grupo que cuenta junto: "cementerio_s3", "profundidades_s7"...
@export var seal_group: String = ""
## Id del sello dentro de su grupo; único por grupo.
@export var seal_id: String = ""
@export_range(1, 9, 1) var seal_total: int = 3
## Si no está vacío, el sello se activa cuando GameManager marca este encuentro.
@export var listen_encounter: String = ""
@export var seal_message: String = "SELLO %d/%d"
@export var all_open_message: String = "ALGO SE HA ABIERTO"


func _ready() -> void:
    if seal_group.is_empty() or seal_id.is_empty():
        push_warning("Sello %s: faltan seal_group o seal_id; no contará." % name)
    # La palanca de la que hereda usa encounter_id como su clave.
    encounter_id = GameManager.seal_key(seal_group, seal_id)
    prompt_text = "E  Activar" if prompt_text == "E  Tirar" else prompt_text
    super._ready()
    if listen_encounter.is_empty():
        return
    if GameManager.is_encounter_completed(listen_encounter):
        # Ya superado en otra visita: se enciende sin aviso ni sacudida.
        if not is_pulled:
            _activate(true)
    elif not GameManager.encounter_completed.is_connected(_on_listen_completed):
        GameManager.encounter_completed.connect(_on_listen_completed)


func can_interact(player: Node) -> bool:
    # Con listen_encounter el sello se enciende solo: no hay nada que pulsar.
    if not listen_encounter.is_empty() or seal_group.is_empty() or seal_id.is_empty():
        return false
    return super.can_interact(player)


## Activa el sello (para probarlo o accionarlo desde otro script).
func pull() -> void:
    _activate(false)


func _on_listen_completed(completed_id: String) -> void:
    if completed_id == listen_encounter:
        _activate(false)


func _activate(silent: bool) -> void:
    if is_pulled or seal_group.is_empty() or seal_id.is_empty():
        return
    is_pulled = true
    _prompt.visible = false
    _set_frame(pulled_frame)
    GameManager.mark_encounter_completed(encounter_id)
    if not silent:
        _play_feedback()
    pulled.emit()
    if GameManager.get_seal_count(seal_group) >= seal_total:
        GameManager.mark_encounter_completed(GameManager.seal_group_encounter(seal_group))


func _play_feedback() -> void:
    var count := GameManager.get_seal_count(seal_group)
    if count >= seal_total:
        _show_message(all_open_message)
    else:
        _show_message(seal_message % [count, seal_total])
    if shake_strength <= 0.0:
        return
    var camera := get_viewport().get_camera_2d()
    if camera != null and camera.has_method("shake"):
        camera.call("shake", shake_strength * (2.0 if count >= seal_total else 1.0), shake_time)
