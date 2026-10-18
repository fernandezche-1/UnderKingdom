extends Node2D
class_name UnderkingdomCinematicController

## INTRO: empieza al cargar W1; REENCUENTRO: solo cuando el jefe entra en cámara.
## ON_BOSS_SPAWN: el jefe lo crea una sala (UnderkingdomBossArena) y el diálogo
## empieza en cuanto aparece; el actor es ese jefe.
## No modifica mapas, animaciones de combate ni estadísticas del jefe.
enum Activation {ON_START, ON_VISIBLE, ON_BOSS_SPAWN}

@export var cinematic_id: String = ""
@export var play_once: bool = true
@export var activation: Activation = Activation.ON_START
@export var player_path: NodePath
@export var focus_actor_path: NodePath
@export var visible_notifier_path: NodePath
## Solo para ON_BOSS_SPAWN: la sala cuya señal boss_spawned abre el diálogo.
@export var boss_arena_path: NodePath
@export_file("*.json") var dialogue_path: String = ""

@export_category("Cámara / Ritmo")
@export_range(0.0, 5.0, 0.05) var start_delay: float = 0.45
@export_range(-1.0, 1.0, 1.0) var auto_walk_direction: float = 0.0
@export_range(0.0, 300.0, 5.0) var auto_walk_speed: float = 52.0
@export_range(0.0, 5.0, 0.05) var auto_walk_duration: float = 0.0
@export_range(0.1, 5.0, 0.05) var camera_pan_duration: float = 0.7
@export_range(0.1, 5.0, 0.05) var camera_return_duration: float = 0.55
@export var focus_offset: Vector2 = Vector2(0, -18)
@export_range(20.0, 300.0, 5.0) var visible_max_distance_x: float = 140.0
@export_range(20.0, 200.0, 5.0) var visible_max_distance_y: float = 100.0
@export var freeze_actor_until_dialogue: bool = false

const DIALOGUE_SCENE := preload("res://escenas/ui/dialogue_ui.tscn")

var _player: Node2D
var _actor: Node2D
var _notifier: VisibleOnScreenNotifier2D
var _normal_camera: Camera2D
var _camera: Camera2D
var _dialogue: UnderkingdomDialogueUI
var _player_hud: CanvasLayer
var _debug_hud: CanvasLayer
var _player_hud_visible: bool = true
var _debug_hud_visible: bool = false
var _actor_original_ai: bool = true
var _actor_original_attacks: bool = true
var _actor_original_patrol: bool = true
var _boss_bar: CanvasItem
var _boss_bar_visible: bool = false
var _running: bool = false
var _done: bool = false
var _restored: bool = false
var _cue_tween: Tween


func _ready() -> void:
    if cinematic_id.is_empty():
        push_warning("Cinemática sin identificador: " + str(get_path()))
        return
    if play_once and GameManager.has_seen_cinematic(cinematic_id):
        _done = true
        return
    _player = get_node_or_null(player_path) as Node2D
    _actor = get_node_or_null(focus_actor_path) as Node2D
    _notifier = get_node_or_null(visible_notifier_path) as VisibleOnScreenNotifier2D
    if _player == null:
        push_warning("No existe Player para: " + cinematic_id)
        return
    if activation == Activation.ON_VISIBLE and (_actor == null or _notifier == null):
        push_warning("Falta el actor o su notificador para: " + cinematic_id)
        return
    if freeze_actor_until_dialogue and _actor != null:
        _freeze_actor()
    if activation == Activation.ON_BOSS_SPAWN:
        var arena := get_node_or_null(boss_arena_path)
        if arena == null or not arena.has_signal(&"boss_spawned"):
            push_warning("Falta la sala del jefe para: " + cinematic_id)
            return
        arena.connect(&"boss_spawned", _on_boss_spawned, CONNECT_ONE_SHOT)
    elif activation == Activation.ON_START:
        call_deferred("_begin")
    else:
        set_process(true)


func _process(_delta: float) -> void:
    if _done or _running or activation != Activation.ON_VISIBLE:
        return
    if not is_instance_valid(_player) or not is_instance_valid(_actor) or not is_instance_valid(_notifier):
        return
    if _actor.get("dead") == true:
        return
    if not _notifier.is_on_screen():
        return
    if absf(_player.global_position.x - _actor.global_position.x) > visible_max_distance_x:
        return
    if absf(_player.global_position.y - _actor.global_position.y) > visible_max_distance_y:
        return
    _begin()


func _on_boss_spawned(boss: Node2D) -> void:
    if _done or _running or not is_instance_valid(boss):
        return
    _actor = boss
    # Se congela en el mismo cuadro en que aparece, antes de que ataque.
    if freeze_actor_until_dialogue:
        _freeze_actor()
    _begin()


func _freeze_actor() -> void:
    _actor_original_ai = bool(_actor.get("ai_enabled"))
    _actor_original_attacks = bool(_actor.get("attacks_enabled"))
    _actor_original_patrol = bool(_actor.get("patrol_enabled"))
    _actor.set("ai_enabled", false)
    _actor.set("attacks_enabled", false)
    _actor.set("patrol_enabled", false)
    _boss_bar = _actor.get_node_or_null("BossHealthBar") as CanvasItem
    if is_instance_valid(_boss_bar):
        _boss_bar_visible = _boss_bar.visible
        _boss_bar.visible = false


func _restore_actor() -> void:
    if not freeze_actor_until_dialogue or not is_instance_valid(_actor):
        return
    _actor.set("ai_enabled", _actor_original_ai)
    _actor.set("attacks_enabled", _actor_original_attacks)
    _actor.set("patrol_enabled", _actor_original_patrol)
    if is_instance_valid(_boss_bar):
        _boss_bar.visible = _boss_bar_visible


func _begin() -> void:
    if _done or _running or not is_inside_tree() or not is_instance_valid(_player):
        return
    _running = true
    _restored = false
    _normal_camera = _player.get_node_or_null("Camera2D") as Camera2D
    _player_hud = _player.get_node_or_null("PlayerHUD") as CanvasLayer
    _debug_hud = _player.get_node_or_null("DebugHUD") as CanvasLayer
    if is_instance_valid(_player_hud):
        _player_hud_visible = _player_hud.visible
        _player_hud.visible = false
    if is_instance_valid(_debug_hud):
        _debug_hud_visible = _debug_hud.visible
        _debug_hud.visible = false
    _player.call("set_controls_locked", true)
    _player.set("cinematic_invulnerable", true)

    _camera = Camera2D.new()
    _camera.name = "TemporaryCinematicCamera"
    # La cámara temporal hereda exactamente el zoom y los límites usados por
    # MapBounds. Antes no se copiaban y dejaba ver bordes grises fuera del mapa.
    if is_instance_valid(_normal_camera):
        _camera.zoom = _normal_camera.zoom
        _camera.offset = _normal_camera.offset
        _camera.limit_left = _normal_camera.limit_left
        _camera.limit_right = _normal_camera.limit_right
        _camera.limit_top = _normal_camera.limit_top
        _camera.limit_bottom = _normal_camera.limit_bottom
    _camera.position_smoothing_enabled = false
    add_child(_camera)
    var bounds := get_tree().get_first_node_in_group("map_bounds")
    if bounds != null and bounds.has_method("apply_to"):
        bounds.call("apply_to", _camera)
    var initial_position := _player.global_position + Vector2(0, 16)
    if is_instance_valid(_normal_camera):
        initial_position = _normal_camera.get_screen_center_position()
    _camera.global_position = _safe_camera_point(initial_position)
    _camera.make_current()

    _dialogue = DIALOGUE_SCENE.instantiate() as UnderkingdomDialogueUI
    add_child(_dialogue)
    _dialogue.line_shown.connect(_on_line_shown)
    if activation == Activation.ON_START:
        _play_opening()
    else:
        _play_encounter()


func _play_opening() -> void:
    # Un fundido negro sobre el juego, sin archivo de vídeo.
    var black := CanvasLayer.new()
    black.layer = 70
    black.name = "OpeningFade"
    add_child(black)
    var rect := ColorRect.new()
    rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    rect.color = Color.BLACK
    rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    black.add_child(rect)
    rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    await get_tree().process_frame
    var fade := create_tween()
    fade.tween_property(rect, "modulate:a", 0.0, 1.05)
    await fade.finished
    black.queue_free()
    if not is_inside_tree():
        return
    if start_delay > 0:
        await get_tree().create_timer(start_delay).timeout
    if not is_inside_tree():
        return
    if not is_zero_approx(auto_walk_direction) and auto_walk_duration > 0.0:
        _player.call("set_cinematic_velocity", Vector2(auto_walk_speed * auto_walk_direction, 0.0))
        await get_tree().create_timer(auto_walk_duration).timeout
        _player.call("set_cinematic_velocity", Vector2.ZERO)
    var target := _player.global_position + Vector2(45, -16)
    await _move_camera(target, camera_pan_duration)
    if not is_inside_tree():
        return
    await _play_dialogue()
    if not is_inside_tree():
        return
    await _complete_sequence()


func _play_encounter() -> void:
    if is_instance_valid(_actor) and _actor.has_node("AnimatedSprite2D"):
        var anim := _actor.get_node("AnimatedSprite2D") as AnimatedSprite2D
        if anim.sprite_frames.has_animation(&"idle"):
            anim.play(&"idle")
    var both_in_view := (_player.global_position + _actor.global_position) * 0.5
    # Si no caben los dos en pantalla (el jefe de una sala sale en el extremo
    # opuesto), la cámara enfoca al actor.
    var half_view_x := get_viewport_rect().size.x / (_camera.zoom.x * 2.0)
    if absf(_player.global_position.x - _actor.global_position.x) * 0.5 > half_view_x - 24.0:
        both_in_view = _actor.global_position
    both_in_view.y += focus_offset.y
    await _move_camera(both_in_view, camera_pan_duration)
    if not is_inside_tree():
        return
    if start_delay > 0:
        await get_tree().create_timer(start_delay).timeout
    if not is_inside_tree():
        return
    await _play_dialogue()
    if not is_inside_tree():
        return
    await _complete_sequence()


func _play_dialogue() -> void:
    var lines := _load_dialogue_lines()
    if not lines.is_empty():
        if activation == Activation.ON_START:
            _dialogue.start_dialogue(lines, {"friend": null})
        else:
            _dialogue.start_dialogue(lines)
        await _dialogue.dialogue_finished


func _complete_sequence() -> void:
    if is_instance_valid(_cue_tween) and _cue_tween.is_running():
        _cue_tween.kill()
    await _move_camera(_player.global_position + Vector2(0, 16), camera_return_duration)
    if not is_inside_tree():
        return
    # Se marca vista ANTES de abrir el combate para que el respawn no la repita.
    GameManager.mark_cinematic_seen(cinematic_id)
    _done = true
    _restore_everything()
    _running = false
    set_process(false)
    if is_instance_valid(_camera):
        _camera.queue_free()
    if is_instance_valid(_dialogue):
        _dialogue.queue_free()


func _move_camera(target: Vector2, duration: float) -> void:
    if not is_instance_valid(_camera):
        return
    var tween := create_tween()
    tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(_camera, "global_position", _safe_camera_point(target), maxf(duration, 0.05))
    await tween.finished


func _safe_camera_point(target: Vector2) -> Vector2:
    if not is_instance_valid(_camera):
        return target
    var half := get_viewport_rect().size / (_camera.zoom * 2.0)
    var min_x := float(_camera.limit_left) + half.x
    var max_x := float(_camera.limit_right) - half.x
    var min_y := float(_camera.limit_top) + half.y
    var max_y := float(_camera.limit_bottom) - half.y
    if min_x > max_x:
        target.x = (min_x + max_x) * 0.5
    else:
        target.x = clampf(target.x, min_x, max_x)
    if min_y > max_y:
        target.y = (min_y + max_y) * 0.5
    else:
        target.y = clampf(target.y, min_y, max_y)
    return target


func _on_line_shown(line: Dictionary) -> void:
    if String(line.get("camera_cue", "")) == "cementery" and is_instance_valid(_camera):
        # Breve vistazo lateral dentro del mapa; vuelve al diálogo sin alejarse.
        if is_instance_valid(_cue_tween) and _cue_tween.is_running():
            _cue_tween.kill()
        var origin := _camera.global_position
        var look := _safe_camera_point(origin + Vector2(32, -8))
        _cue_tween = create_tween()
        _cue_tween.tween_property(_camera, "global_position", look, 0.45)
        _cue_tween.tween_interval(0.35)
        _cue_tween.tween_property(_camera, "global_position", origin, 0.45)


func _load_dialogue_lines() -> Array:
    if dialogue_path.is_empty() or not FileAccess.file_exists(dialogue_path):
        push_warning("Falta archivo de diálogo: " + dialogue_path)
        return []
    var file := FileAccess.open(dialogue_path, FileAccess.READ)
    if file == null:
        return []
    var result: Variant = JSON.parse_string(file.get_as_text())
    if result is Array:
        return result
    push_warning("Formato JSON incorrecto: " + dialogue_path)
    return []


func _restore_everything() -> void:
    if _restored:
        return
    _restored = true
    # Al cerrar el mapa la cámara del Player puede salir del árbol antes.
    if is_instance_valid(_normal_camera) and _normal_camera.is_inside_tree():
        _normal_camera.make_current()
    if is_instance_valid(_player):
        _player.call("set_cinematic_velocity", Vector2.ZERO)
        _player.set("cinematic_invulnerable", false)
        _player.call("set_controls_locked", false)
    if is_instance_valid(_player_hud):
        _player_hud.visible = _player_hud_visible
    if is_instance_valid(_debug_hud):
        _debug_hud.visible = _debug_hud_visible
    _restore_actor()


func _exit_tree() -> void:
    # Protección ante cambios de mapa inesperados mientras se ve un diálogo.
    if _running:
        _restore_everything()
    elif not _done:
        _restore_actor()
