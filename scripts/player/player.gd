extends CharacterBody2D
class_name UnderkingdomPlayer

## Player principal de prueba.
## Conserva movimiento, escalada, daño, respawn y cámara,
## y añade combate usando las animaciones que YA existen en player.tscn.

signal health_changed(current_health: float, max_health: float)
signal damaged(amount: float)
signal died
signal respawned
signal attack_started(animation_name: StringName, damage: float)

enum PlayerAction {
    NORMAL,
    ATTACK,
    AIR_ATTACK,
    ROLL,
    DEFEND,
    ULTIMATE,
    HURT,
    CAST
}

## Cómo se juega cada animación de ataque. Las del combo son acumulativas:
## "attack 2" empieza repitiendo el tajo de "attack" (cuadros 0-7) y
## "attack 3" repite todo "attack 2" (0-16) antes de su remate, así que cada
## etapa arranca en el cuadro donde empieza lo suyo. Cada golpe es una ventana
## de cuadros [desde, hasta]: un enemigo recibe un impacto por ventana.
## area: "front" delante, "wide" delante y más grande, "blast" explosión más
## lejos, "around" alrededor del Player (la ráfaga golpea delante y detrás).
## knockback: false = daño sin empuje ni aturdir, para que los golpes
## seguidos de una ráfaga conecten todos; el último de cada ataque empuja.
## lunge: el Player da un paso corto hacia delante al soltar el tajo.
const ATTACK_PROFILES := {
    &"puch": {"start": 0, "end": 5, "hits": [
        {"frames": Vector2i(3, 4), "ratio": 1.0, "area": "front", "knockback": true},
    ]},
    &"attack": {"start": 0, "end": 10, "lunge": true, "hits": [
        {"frames": Vector2i(4, 6), "ratio": 1.0, "area": "front", "knockback": true},
    ]},
    &"attack 2": {"start": 8, "end": 18, "hits": [
        {"frames": Vector2i(9, 9), "ratio": 0.125, "area": "around", "knockback": false},
        {"frames": Vector2i(10, 10), "ratio": 0.125, "area": "around", "knockback": false},
        {"frames": Vector2i(11, 11), "ratio": 0.125, "area": "around", "knockback": false},
        {"frames": Vector2i(12, 12), "ratio": 0.125, "area": "around", "knockback": false},
        {"frames": Vector2i(13, 13), "ratio": 0.125, "area": "around", "knockback": false},
        {"frames": Vector2i(14, 14), "ratio": 0.125, "area": "around", "knockback": false},
        {"frames": Vector2i(15, 15), "ratio": 0.125, "area": "around", "knockback": false},
        {"frames": Vector2i(16, 16), "ratio": 0.125, "area": "around", "knockback": true},
    ]},
    &"attack 3": {"start": 17, "end": 27, "lunge": true, "hits": [
        {"frames": Vector2i(22, 22), "ratio": 0.4, "area": "wide", "knockback": false},
        {"frames": Vector2i(23, 25), "ratio": 0.6, "area": "blast", "knockback": true},
    ]},
    &"air attack": {"start": 0, "end": 7, "hits": [
        {"frames": Vector2i(3, 5), "ratio": 1.0, "area": "front", "knockback": true},
    ]},
    &"attack ultimate": {"start": 0, "end": 17, "hits": [
        {"frames": Vector2i(10, 10), "ratio": 0.15, "area": "wide", "knockback": false},
        {"frames": Vector2i(11, 11), "ratio": 0.15, "area": "wide", "knockback": false},
        {"frames": Vector2i(12, 12), "ratio": 0.25, "area": "blast", "knockback": false},
        {"frames": Vector2i(13, 13), "ratio": 0.25, "area": "blast", "knockback": false},
        {"frames": Vector2i(14, 14), "ratio": 0.2, "area": "blast", "knockback": true},
    ]},
}

@export_category("Movimiento")
@export_range(20.0, 800.0, 5.0) var move_speed: float = 230.0
@export_range(100.0, 5000.0, 50.0) var acceleration: float = 1800.0
@export_range(100.0, 5000.0, 50.0) var deceleration: float = 2200.0
@export_range(-1200.0, -100.0, 10.0) var jump_velocity: float = -560.0
@export_range(100.0, 5000.0, 50.0) var gravity: float = 1500.0
@export_range(100.0, 3000.0, 50.0) var max_fall_speed: float = 1000.0

@export_category("Escaleras y rampas")
@export_range(30.0, 500.0, 5.0) var climb_speed: float = 150.0
@export_range(30.0, 500.0, 5.0) var climb_horizontal_speed: float = 120.0
@export_range(30.0, 85.0, 1.0) var max_stair_slope_degrees: float = 65.0
@export_range(0.0, 40.0, 1.0) var floor_snap_distance: float = 4.0

@export_category("Plataformas One Way")
@export_range(1, 32, 1) var one_way_collision_layer: int = 2
@export_range(0.05, 1.0, 0.05) var drop_through_time: float = 0.25
@export_range(20.0, 600.0, 10.0) var drop_down_speed: float = 160.0

@export_category("Vida y daño")
@export_range(0.25, 20.0, 0.25) var max_health: float = 4.0
@export_range(0.0, 3.0, 0.05) var invulnerability_time: float = 0.45
@export_range(0.0, 1500.0, 10.0) var knockback_horizontal: float = 260.0
@export_range(-1000.0, 0.0, 10.0) var knockback_vertical: float = -220.0
@export_range(0.0, 1.0, 0.01) var hurt_animation_time: float = 0.22
@export_range(0.0, 1.0, 0.05) var defense_damage_reduction: float = 1.0
## Vida que devuelve cada poción (C). 1.0 = un corazón.
@export_range(0.25, 4.0, 0.25) var potion_heal_amount: float = 1.0

@export_category("Guardia")
@export_range(1, 10, 1) var guard_max_hits: int = 3
@export_range(0.1, 3.0, 0.05) var guard_break_stun_time: float = 0.75
@export_range(0.1, 5.0, 0.05) var guard_recharge_delay: float = 1.25
## Parry: cubrirse como mucho este tiempo antes del golpe no gasta guardia y
## aturde al atacante.
@export_range(0.0, 0.5, 0.01) var parry_window: float = 0.15
@export_range(0.0, 2.0, 0.05) var parry_stun_time: float = 0.8
## Tiempo sin cubrirse necesario para que el siguiente bloqueo pueda ser
## parry; evita que machacar Q haga parry siempre.
@export_range(0.0, 1.5, 0.05) var parry_rearm_time: float = 0.35
## Empuje hacia atrás al bloquear un golpe normal (no quita vida).
@export_range(0.0, 400.0, 10.0) var block_pushback: float = 140.0

@export_category("Combate")
@export_range(0.1, 10.0, 0.05) var attack_1_damage: float = 0.50
@export_range(0.05, 0.5, 0.05) var unarmed_attack_damage: float = 0.25
@export_range(0.1, 10.0, 0.05) var attack_2_damage: float = 0.75
@export_range(0.1, 10.0, 0.05) var attack_3_damage: float = 1.00
@export_range(0.1, 10.0, 0.05) var air_attack_damage: float = 0.75
@export_range(0.1, 20.0, 0.05) var ultimate_damage: float = 2.00
@export_range(0.0, 1.0, 0.01) var attack_active_start_ratio: float = 0.28
@export_range(0.0, 1.0, 0.01) var attack_active_end_ratio: float = 0.72
@export_range(10.0, 300.0, 1.0) var attack_hitbox_offset_x: float = 52.0
@export_range(-100.0, 200.0, 1.0) var attack_hitbox_offset_y: float = 34.0
@export_range(0.05, 2.0, 0.05) var combo_queue_window: float = 0.45
@export_range(1.0, 2.0, 0.05) var combo_base_speed_multiplier: float = 1.35
## Velocidad propia del primer tajo, que sustituye a combo_base_speed_multiplier:
## es el golpe que más se usa y el único al empezar una partida.
@export_range(1.0, 2.0, 0.05) var attack_1_speed_multiplier: float = 1.35
## Velocidad propia del ataque aéreo (la animación del pack va a 9 fps).
@export_range(1.0, 3.0, 0.05) var air_attack_speed_multiplier: float = 1.80
## Velocidad del puñetazo sin espada (la animación va a 5 fps: 2.4 la deja en 12).
@export_range(1.0, 4.0, 0.05) var unarmed_attack_speed_multiplier: float = 2.40
@export_range(0, 30, 1) var attack_1_chain_frame: int = 7
## Sin la Ráfaga, el primer tajo se encadena consigo mismo desde
## attack_1_chain_frame y vuelve a empezar en este cuadro, saltándose la
## preparación agachada (cuadros 0-1, la misma pose que el final).
@export_range(0, 10, 1) var attack_1_repeat_frame: int = 2
## Sin la Ráfaga, cuadro desde el que el tajo se encadena consigo mismo. Va
## después de attack_1_chain_frame para que machacar el botón haga menos daño
## por segundo que el combo.
@export_range(0, 10, 1) var attack_1_repeat_chain_frame: int = 9
@export_range(0, 40, 1) var attack_2_chain_frame: int = 17
## Si está activado, moverse, saltar o rodar corta los ataques. Desactivado por defecto.
@export var movement_cancels_attacks: bool = false
## Distancia total del roll. Arranca rápido y frena hasta detenerse al
## final de la animación; 96 px alcanzan para atravesar a cualquier enemigo
## actual (el más ancho mide 42 px) si se rueda desde cerca.
@export_range(16.0, 400.0, 4.0) var roll_distance: float = 96.0
@export_range(0.1, 10.0, 0.1) var ultimate_cooldown: float = 6.0

@export_category("Impacto")
## Paso hacia delante de los ataques con "lunge" en ATTACK_PROFILES.
@export_range(0.0, 40.0, 1.0) var attack_lunge_distance: float = 10.0
@export_range(0.01, 0.4, 0.01) var attack_lunge_time: float = 0.12
## Hitstop al conectar con un enemigo, en segundos reales: el juego entero
## va a hit_stop_time_scale de su velocidad. 0 lo desactiva.
@export_range(0.0, 0.3, 0.005) var hit_stop_time: float = 0.06
## Golpes intermedios de una ráfaga (sin empuje).
@export_range(0.0, 0.3, 0.005) var hit_stop_continuous_time: float = 0.02
## Remates con área "blast" (Golpe final, Ultimate).
@export_range(0.0, 0.3, 0.005) var hit_stop_heavy_time: float = 0.1
@export_range(0.0, 1.0, 0.01) var hit_stop_time_scale: float = 0.05
## Temblor de la cámara (píxeles) en los golpes que empujan.
@export_range(0.0, 8.0, 1.0) var hit_shake_strength: float = 2.0
@export_range(0.0, 8.0, 1.0) var hit_shake_heavy_strength: float = 4.0
@export_range(0.0, 0.5, 0.01) var hit_shake_time: float = 0.12

@export_category("Adrenalina")
@export var adrenaline_enabled: bool = true
@export_range(0.1, 0.9, 0.05) var adrenaline_health_ratio: float = 0.50
@export_range(1.0, 2.0, 0.05) var adrenaline_attack_speed_multiplier: float = 1.25
@export var adrenaline_affects_ultimate: bool = false

@export_category("Robo de vida")
@export var lifesteal_enabled: bool = true
@export_range(0.25, 20.0, 0.25) var lifesteal_damage_required: float = 2.0
@export_range(0.25, 2.0, 0.25) var lifesteal_heal_amount: float = 0.25
@export_range(0.0, 1.0, 0.05) var ultimate_lifesteal_multiplier: float = 1.0

@export_category("Respawn")
@export_range(0.1, 5.0, 0.1) var respawn_delay: float = 0.8
## Al morir recarga el mapa (enemigos y jefes vuelven a empezar) y reaparece en
## el último checkpoint o en la entrada del mapa. Sin esto, reaparece en el
## sitio sin reiniciar nada.
@export var reload_map_on_death: bool = true
## Respaldo si el mapa no tiene MapBounds.
@export var fall_limit_y: float = 1200.0
## Muere al caer esta distancia por debajo del borde inferior del mapa.
@export_range(0.0, 400.0, 4.0) var fall_margin_below_map: float = 64.0

@export_category("Bola de fuego")
## Prueba de una animación hecha con IA (Elementals_fire_knight_FREE_v1.1/bola_fuego/).
@export var fireball_enabled: bool = true
@export_range(0.25, 10.0, 0.25) var fireball_damage: float = 1.0
@export_range(40.0, 900.0, 10.0) var fireball_speed: float = 300.0
@export_range(0.0, 10.0, 0.1) var fireball_cooldown: float = 1.2
@export_range(1.0, 30.0, 1.0) var fireball_fps: float = 10.0
## Cuadro de la animación en que la bola sale de la mano.
@export_range(0, 5, 1) var fireball_release_frame: int = 3
## Dónde aparece la bola respecto al centro del sprite, mirando a la derecha
## (en la hoja, la bola del cuadro 4 está en x 159, y 96 de 288x128).
@export var fireball_spawn_offset: Vector2 = Vector2(16.0, 32.0)

@export_category("Pruebas")
@export var enable_debug_keys: bool = false
@export var show_debug_hud: bool = false
@export var blink_while_invulnerable: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var camera: UnderkingdomBoundedCamera = get_node_or_null("Camera2D") as UnderkingdomBoundedCamera
@onready var debug_hud: CanvasLayer = get_node_or_null("DebugHUD")
@onready var info_label: Label = get_node_or_null("DebugHUD/Panel/Info")

var current_health: float
var spawn_position: Vector2
var dead: bool = false
var controls_locked: bool = false
var cinematic_invulnerable: bool = false
var _cinematic_velocity: Vector2 = Vector2.ZERO

var _jump_requested: bool = false
var _hurt_time_left: float = 0.0
var _invulnerability_left: float = 0.0
var _blink_accumulator: float = 0.0
var _blink_visible: bool = true

var _climb_zones: Array[Node] = []
var _climbing: bool = false
var _active_climb_zone: Node = null
var _drop_through_left: float = 0.0
var _normal_floor_snap_length: float = 4.0
var _terrain_collision_temporarily_disabled: bool = false


var _ledge_transition_zones: Array[Node] = []
var _active_ledge_transition_zone: Node = null
var _ledge_transition_cooldown: float = 0.0

var _action: PlayerAction = PlayerAction.NORMAL
var _action_time_left: float = 0.0
var _action_total_time: float = 0.0
var _current_attack_damage: float = 0.0
var _attack_sequence_id: int = 0
var _current_attack_animation: StringName = &""
## El tajo en curso es una repetición del primero (sin la Ráfaga): pega sin
## aturdir, para que machacar el botón no deje al enemigo sin responder.
var _attack_is_repeat: bool = false
var _combo_step: int = 0
var _combo_queued: bool = false
var _combo_queue_left: float = 0.0
var _combo_buffered_inputs: int = 0
var _roll_direction: float = 1.0
var _ultimate_cooldown_left: float = 0.0
var _fireball_cooldown_left: float = 0.0
var _fireball_released: bool = false
var _attack_hit_targets: Array[int] = []
var _attack_subwindow_index: int = -1
var _current_attack_speed_multiplier: float = 1.0
var _attack_lunge_left: float = 0.0
var _lifesteal_damage_bank: float = 0.0

var _guard_hits_remaining: int = 3
var _guard_recharge_left: float = 0.0
var _guard_requires_release: bool = false
var _defend_elapsed: float = 0.0
var _time_since_guard: float = 99.0
var _parry_available: bool = false
var _block_push_left: float = 0.0
var _roll_collision_exceptions: Array[PhysicsBody2D] = []
var _attack_held_direction: float = 0.0
var _fall_limit: float = 1200.0
var _base_sprite_scale: Vector2 = Vector2.ONE
var _base_sprite_position: Vector2 = Vector2.ZERO
var _armed_sprite_position: Vector2 = Vector2.ZERO
var _armed_sprite_frames: SpriteFrames
var _unarmed_sprite_frames: SpriteFrames
var _armed_sprite_offset: Vector2 = Vector2.ZERO
var _base_sprite_offset: Vector2 = Vector2.ZERO
var _uses_normalized_prisoner_frames: bool = false
var _armed_sprite_scale: Vector2 = Vector2.ONE
@export var debug_slide_collisions: bool = true
var _last_blocked_contact_signature: String = ""
var _armory_stuck_frames: int = 0
var _armory_block_reported: bool = false
const ARMORY_STUCK_FRAMES_TO_REPORT: int = 5
const UNARMED_IDLE_SHEET: Texture2D = preload("res://Elementals_fire_knight_FREE_v1.1/idle_8_frames_288x128.png")
const UNARMED_PUNCH_SHEET: Texture2D = preload("res://Elementals_fire_knight_FREE_v1.1/Right_Punch_6_frames_1728x128_alineado.png")
const UNARMED_RUN_SHEET: Texture2D = preload("res://Elementals_fire_knight_FREE_v1.1/run_unarmed_8_frames_2304x128.png")
const FIREBALL_SHEET: Texture2D = preload("res://Elementals_fire_knight_FREE_v1.1/bola_fuego/bola_fuego_6_frames_1728x128.png")
const FIREBALL_FRAME_COUNT: int = 6
const FIREBALL_SCENE: PackedScene = preload("res://escenas/proyectiles/bola_fuego_player.tscn")


func _ready() -> void:
    add_to_group("player")
    _base_sprite_scale = sprite.scale
    _base_sprite_position = sprite.position
    _base_sprite_offset = sprite.offset
    if sprite.sprite_frames.has_animation(&"attack"):
        _armed_sprite_frames = sprite.sprite_frames
        _armed_sprite_offset = sprite.offset
        _armed_sprite_position = sprite.position
        _armed_sprite_scale = sprite.scale
    else:
        # prisn.tscn ya trae sus SpriteFrames normalizados en la escena.
        _uses_normalized_prisoner_frames = true
        _unarmed_sprite_frames = sprite.sprite_frames
        _load_armed_sprite_frames()
    _add_fireball_animation(_armed_sprite_frames)
    set_sword_equipped(GameManager.has_sword)
    floor_max_angle = deg_to_rad(max_stair_slope_degrees)
    floor_snap_length = floor_snap_distance
    _normal_floor_snap_length = floor_snap_distance
    floor_stop_on_slope = true
    floor_block_on_wall = true
    safe_margin = 0.02

    spawn_position = global_position
    _fall_limit = fall_limit_y
    # MapBounds puede entrar al árbol después del Player.
    call_deferred("_update_fall_limit_from_map")
    GameManager.apply_upgrades_to_player(self)
    current_health = max_health
    _guard_hits_remaining = guard_max_hits

    attack_hitbox.monitoring = true
    attack_hitbox.monitorable = false
    _update_attack_hitbox_position()

    if debug_hud:
        debug_hud.visible = show_debug_hud

    _restore_sprite_visibility()
    _update_hud("LISTO")
    health_changed.emit(current_health, max_health)


func set_sword_equipped(equipped: bool) -> void:
    if not is_instance_valid(sprite):
        return
    if _armed_sprite_frames == null:
        _armed_sprite_frames = sprite.sprite_frames
    if equipped:
        sprite.sprite_frames = _armed_sprite_frames
        sprite.position = _armed_sprite_position
        sprite.offset = _armed_sprite_offset
        sprite.scale = _armed_sprite_scale
    else:
        if _unarmed_sprite_frames == null:
            _unarmed_sprite_frames = _build_unarmed_sprite_frames()
        sprite.sprite_frames = _unarmed_sprite_frames
        sprite.position = _base_sprite_position
        sprite.scale = _base_sprite_scale
        if _uses_normalized_prisoner_frames:
            # prisn.tscn usa atlas normalizados y mantiene su offset de origen.
            sprite.offset = _base_sprite_offset
        else:
            # player.tscn conserva el sistema anterior de hojas 288x128.
            sprite.offset = _armed_sprite_offset + Vector2(
                0.0, _armed_sprite_position.y - _base_sprite_position.y
            )
    # Cambiar SpriteFrames conservando el nombre "idle" puede conservar el
    # fotograma/avance del conjunto anterior. Reinicia animación y estados.
    _action = PlayerAction.NORMAL
    _action_time_left = 0.0
    _action_total_time = 0.0
    _current_attack_animation = &""
    _current_attack_damage = 0.0
    _combo_step = 0
    _combo_queued = false
    _combo_queue_left = 0.0
    _combo_buffered_inputs = 0
    _current_attack_speed_multiplier = 1.0
    _attack_hit_targets.clear()
    _attack_subwindow_index = -1
    _attack_lunge_left = 0.0
    _jump_requested = false
    _climbing = false
    _active_climb_zone = null
    _drop_through_left = 0.0
    sprite.speed_scale = 1.0
    sprite.scale = _armed_sprite_scale if equipped else _base_sprite_scale
    sprite.stop()
    sprite.play(&"idle")
    sprite.frame = 0
    sprite.frame_progress = 0.0
    attack_hitbox.scale = Vector2.ONE if equipped else Vector2(0.65, 0.9)
    _update_attack_hitbox_position()


func _load_armed_sprite_frames() -> void:
    # prisn.tscn comparte el controlador, pero conserva el SpriteFrames sin arma.
    # Carga solo los frames del recurso original para cambiar de estado al recuperar.
    var player_scene := load("res://escenas/player.tscn") as PackedScene
    if player_scene == null:
        push_error("No se pudieron cargar las animaciones originales con espada.")
        return
    var visual_reference := player_scene.instantiate()
    var armed_sprite := visual_reference.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D
    if armed_sprite != null:
        _armed_sprite_frames = armed_sprite.sprite_frames
        _armed_sprite_offset = armed_sprite.offset
        _armed_sprite_position = armed_sprite.position
        _armed_sprite_scale = armed_sprite.scale
    visual_reference.free()


## La bola de fuego no está en el SpriteFrames de player.tscn: se añade al
## cargar para no tocar la escena mientras sea una prueba.
func _add_fireball_animation(frames: SpriteFrames) -> void:
    if frames == null or frames.has_animation(&"fireball"):
        return
    frames.add_animation(&"fireball")
    frames.set_animation_speed(&"fireball", fireball_fps)
    frames.set_animation_loop(&"fireball", false)
    for index in FIREBALL_FRAME_COUNT:
        var atlas := AtlasTexture.new()
        atlas.atlas = FIREBALL_SHEET
        atlas.region = Rect2(index * 288, 0, 288, 128)
        frames.add_frame(&"fireball", atlas)


func _build_unarmed_sprite_frames() -> SpriteFrames:
    var frames := SpriteFrames.new()
    frames.remove_animation(&"default")
    frames.add_animation(&"idle")
    frames.set_animation_speed(&"idle", 5.0)
    frames.set_animation_loop(&"idle", true)
    for index in 8:
        var atlas := AtlasTexture.new()
        atlas.atlas = UNARMED_IDLE_SHEET
        atlas.region = Rect2(index * 288, 0, 288, 128)
        frames.add_frame(&"idle", atlas)
    frames.add_animation(&"puch")
    frames.set_animation_speed(&"puch", 5.0)
    frames.set_animation_loop(&"puch", false)
    for index in 6:
        var atlas := AtlasTexture.new()
        atlas.atlas = UNARMED_PUNCH_SHEET
        atlas.region = Rect2(index * 288, 0, 288, 128)
        frames.add_frame(&"puch", atlas)
    frames.add_animation(&"run")
    frames.set_animation_speed(&"run", 8.0)
    frames.set_animation_loop(&"run", true)
    for index in 8:
        var atlas := AtlasTexture.new()
        atlas.atlas = UNARMED_RUN_SHEET
        atlas.region = Rect2(index * 288, 0, 288, 128)
        frames.add_frame(&"run", atlas)
    return frames


func _unhandled_input(event: InputEvent) -> void:
    if dead or controls_locked:
        return

    if event.is_action_pressed("attack"):
        request_attack()
    elif event.is_action_pressed("jump"):
        _jump_requested = true
    elif event.is_action_pressed("roll"):
        request_roll()
    elif event.is_action_pressed("interact"):
        print("[PLAYER_INTERACTION] E pressed player=%s scene=%s position=%s" % [get_path(), get_tree().current_scene.scene_file_path, global_position])
        if not _try_context_interaction():
            print("[PLAYER_INTERACTION] rejected reason=no_interactable_in_range")
            request_ultimate()
    elif event.is_action_pressed("potion"):
        drink_potion()
    elif event.is_action_pressed("fireball"):
        request_fireball()
    elif event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_R:
                if enable_debug_keys:
                    respawn_now()
            KEY_H:
                if enable_debug_keys:
                    take_damage(0.25)
            KEY_J:
                if enable_debug_keys:
                    take_damage(1.0)
            KEY_K:
                if enable_debug_keys:
                    die()


func _physics_process(delta: float) -> void:
    _update_damage_timers(delta)
    _update_drop_through(delta)
    _update_combat_timers(delta)
    _update_ledge_transition_timer(delta)

    if dead:
        return

    if controls_locked:
        _process_cinematic_movement(delta)
        var cinematic_velocity_before := velocity
        var cinematic_direction := signf(cinematic_velocity_before.x)
        move_and_slide()
        _log_blocked_horizontal_collisions(cinematic_direction, cinematic_velocity_before, cinematic_direction, "_process_cinematic_movement")
        _update_cinematic_animation()
        return

    _cleanup_climb_zones()
    _cleanup_ledge_transition_zones()
    _process_simple_ledge_input()
    _update_attack_hitbox_position()
    _update_defense_state()
    _try_cancel_attack_by_movement()

    if _action == PlayerAction.ROLL:
        _process_roll(delta)
    elif _action == PlayerAction.ATTACK:
        _process_attack_movement(delta)
    elif _action == PlayerAction.AIR_ATTACK:
        _process_air_attack_movement(delta)
    elif _action in [PlayerAction.ULTIMATE, PlayerAction.CAST]:
        _process_attack_movement(delta)
    elif _action == PlayerAction.HURT:
        _process_hurt_movement(delta)
    elif _action == PlayerAction.DEFEND:
        _process_defense_movement(delta)
    else:
        if _can_climb() and _has_climb_input():
            _climbing = true
        elif _climbing and not _can_climb():
            _climbing = false

        if _climbing:
            _process_climbing()
        else:
            _process_normal_movement(delta)

    var velocity_before_slide := velocity
    var horizontal_input := _get_horizontal_input()
    var requested_horizontal_direction := horizontal_input
    if is_zero_approx(requested_horizontal_direction):
        requested_horizontal_direction = signf(velocity_before_slide.x)
    move_and_slide()
    var movement_function := "_process_normal_movement"
    if _action == PlayerAction.ROLL:
        movement_function = "_process_roll"
    elif _action in [PlayerAction.ATTACK, PlayerAction.ULTIMATE, PlayerAction.CAST]:
        movement_function = "_process_attack_movement"
    elif _action == PlayerAction.AIR_ATTACK:
        movement_function = "_process_air_attack_movement"
    elif _action == PlayerAction.HURT:
        movement_function = "_process_hurt_movement"
    elif _action == PlayerAction.DEFEND:
        movement_function = "_process_defense_movement"
    elif _climbing:
        movement_function = "_process_climbing"
    _log_blocked_horizontal_collisions(requested_horizontal_direction, velocity_before_slide, horizontal_input, movement_function)

    if global_position.y > _fall_limit:
        die()
        return

    _update_action_state()
    _update_attack_damage_window()
    _update_fireball_release()

    var direction := _get_horizontal_input()
    _update_animation(direction)

    var state_text := "JUGANDO"
    if _climbing:
        state_text = "ESCALERA"
    elif _action != PlayerAction.NORMAL:
        state_text = _action_name()
    elif is_invulnerable():
        state_text = "INVULNERABLE"
    _update_hud(state_text)


func _update_fall_limit_from_map() -> void:
    # Cada mapa tiene su propio alto (Mundo 3 mide 1254); un límite fijo
    # mataba al Player sobre suelo real.
    var bounds := get_tree().get_first_node_in_group("map_bounds")
    if bounds == null:
        return
    var bottom: Variant = bounds.get("bottom")
    if bottom != null:
        _fall_limit = float(bottom) + fall_margin_below_map


func set_controls_locked(locked: bool) -> void:
    controls_locked = locked
    _cinematic_velocity = Vector2.ZERO
    _jump_requested = false
    _climbing = false
    if locked:
        if GameManager.has_sword and is_instance_valid(sprite):
            sprite.offset = _armed_sprite_offset
        _finish_action()
        velocity = Vector2.ZERO


func set_cinematic_velocity(new_velocity: Vector2) -> void:
    _cinematic_velocity = new_velocity


func _process_cinematic_movement(delta: float) -> void:
    velocity.x = _cinematic_velocity.x
    if is_on_floor():
        velocity.y = 0.0
    else:
        velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)


func _update_cinematic_animation() -> void:
    sprite.scale = _armed_sprite_scale if GameManager.has_sword else _base_sprite_scale
    sprite.speed_scale = 1.0
    if not GameManager.has_sword:
        if sprite.animation != &"idle" or not sprite.is_playing():
            sprite.play(&"idle")
        return
    if absf(velocity.x) > 1.0:
        sprite.flip_h = velocity.x < 0.0
        if sprite.animation != &"run" or not sprite.is_playing():
            sprite.play(&"run")
    else:
        if sprite.animation != &"idle" or not sprite.is_playing():
            sprite.play(&"idle")


func request_attack() -> void:
    if dead or _climbing:
        return

    if not GameManager.has_sword:
        if _action == PlayerAction.NORMAL and is_on_floor():
            _combo_step = 0
            _combo_queued = false
            _combo_buffered_inputs = 0
            _start_attack(&"puch", unarmed_attack_damage, PlayerAction.ATTACK)
        return

    if _action == PlayerAction.ATTACK:
        var remaining_steps := _remaining_combo_inputs()
        if remaining_steps > 0:
            # Guardamos pulsaciones reales, no solo un booleano. Asi, si el
            # jugador pulsa dos veces durante attack 1, quedan preparados
            # attack 2 Y attack 3 en vez de perderse la tercera pulsacion.
            _combo_buffered_inputs = mini(_combo_buffered_inputs + 1, remaining_steps)
            _combo_queued = _combo_buffered_inputs > 0
            _combo_queue_left = maxf(
                _combo_queue_left,
                _action_time_left + combo_queue_window + 0.25
            )
        return

    if _action not in [PlayerAction.NORMAL, PlayerAction.DEFEND]:
        return

    if _action == PlayerAction.DEFEND:
        _leave_guard_for_action()

    if not is_on_floor():
        if GameManager.has_ability("air_attack"):
            _start_attack(&"air attack", air_attack_damage, PlayerAction.AIR_ATTACK)
        return

    _combo_step = 1
    _combo_queued = false
    _combo_buffered_inputs = 0
    _start_attack(&"attack", attack_1_damage, PlayerAction.ATTACK)


func request_roll() -> void:
    if dead or not GameManager.has_sword or _climbing or not is_on_floor() or not GameManager.has_ability("roll"):
        return
    if _action == PlayerAction.ATTACK and movement_cancels_attacks:
        _finish_action()
    if _action not in [PlayerAction.NORMAL, PlayerAction.DEFEND]:
        return

    if _action == PlayerAction.DEFEND:
        _leave_guard_for_action()

    var input_dir := _get_horizontal_input()
    if not is_zero_approx(input_dir):
        _roll_direction = input_dir
    else:
        _roll_direction = -1.0 if sprite.flip_h else 1.0

    _action = PlayerAction.ROLL
    _action_total_time = _animation_duration(&"roll")
    _action_time_left = _action_total_time
    _invulnerability_left = maxf(_invulnerability_left, _action_total_time * 0.82)
    _enable_roll_enemy_passthrough()
    sprite.play(&"roll")


func _try_context_interaction() -> bool:
    var nearest: Node = null
    var nearest_distance := INF

    for node in get_tree().get_nodes_in_group("interactable"):
        if node == null or not node.has_method("can_interact") or not node.has_method("interact"):
            continue
        if not bool(node.call("can_interact", self)):
            continue
        if not (node is Node2D):
            continue

        var distance := global_position.distance_to((node as Node2D).global_position)
        if distance < nearest_distance:
            nearest_distance = distance
            nearest = node

    if nearest == null:
        return false

    print("[PLAYER_INTERACTION] selected target=%s distance=%.2f" % [nearest.get_path(), nearest_distance])
    var handled := bool(nearest.call("interact", self))
    print("[PLAYER_INTERACTION] result target=%s handled=%s" % [nearest.get_path(), handled])
    return handled


func _log_blocked_horizontal_collisions(
    requested_direction: float,
    velocity_before: Vector2,
    horizontal_input: float,
    movement_function: String
) -> void:
    if not debug_slide_collisions:
        return

    var scene := get_tree().current_scene
    if scene == null or scene.scene_file_path not in [
        "res://escenas/mapas/tiles_castillo.tscn",
        "res://escenas/mapas/tiles_castillo_combate.tscn",
    ]:
        _last_blocked_contact_signature = ""
        _armory_stuck_frames = 0
        _armory_block_reported = false
        return

    # Keep the temporary trace focused on the route from PuertaArmeria to the equipment stand.
    if global_position.x < 1180.0 or global_position.x > 1620.0 or global_position.y < 400.0 or global_position.y > 880.0:
        _last_blocked_contact_signature = ""
        _armory_stuck_frames = 0
        _armory_block_reported = false
        return

    var displacement := get_position_delta()
    if horizontal_input < 0.5 or requested_direction < 0.5 or absf(displacement.x) > 0.05:
        _last_blocked_contact_signature = ""
        _armory_stuck_frames = 0
        _armory_block_reported = false
        return
    _armory_stuck_frames += 1
    if _armory_stuck_frames < ARMORY_STUCK_FRAMES_TO_REPORT:
        return

    var contacts: Array[Dictionary] = []
    var signature_parts := PackedStringArray()
    for index in get_slide_collision_count():
        var collision := get_slide_collision(index)
        var collider := collision.get_collider() as Node
        if collider == null:
            continue
        var normal := collision.get_normal()
        var collider_rid := collision.get_collider_rid()

        var contact: Dictionary = {
            "collider": collider,
            "rid": collider_rid,
            "point": collision.get_position(),
            "normal": normal,
            "blocks_horizontal": normal.x * requested_direction < -0.5,
            "tile_details": "",
            "tile_key": "",
            "shape_details": "",
        }
        if collider is TileMapLayer:
            var layer := collider as TileMapLayer
            var cell := layer.get_coords_for_body_rid(collider_rid)
            var source_id := layer.get_cell_source_id(cell)
            var tileset_name := "<none>"
            if layer.tile_set != null:
                tileset_name = layer.tile_set.resource_path
                if tileset_name.is_empty():
                    tileset_name = layer.tile_set.resource_name
            contact["tile_details"] = " cell=%s source=%d atlas=%s alternative=%d tileset=%s" % [
                cell,
                source_id,
                layer.get_cell_atlas_coords(cell),
                layer.get_cell_alternative_tile(cell),
                tileset_name,
            ]
            contact["tile_key"] = str(cell)
        if collider is CollisionObject2D:
            var collision_object := collider as CollisionObject2D
            var shape_index := collision.get_collider_shape_index()
            var owner_id := collision_object.shape_find_owner(shape_index)
            var shape_details := " shape_index=%d" % shape_index
            if owner_id >= 0:
                var shape_owner := collision_object.shape_owner_get_owner(owner_id)
                if shape_owner is Node:
                    var shape_node := shape_owner as Node
                    shape_details += " shape_node=%s shape_type=%s" % [shape_node.get_path(), shape_node.get_class()]
                    if shape_node is CollisionShape2D and (shape_node as CollisionShape2D).shape != null:
                        shape_details += " resource=%s" % (shape_node as CollisionShape2D).shape.get_class()
            contact["shape_details"] = shape_details
        contacts.append(contact)
        signature_parts.append("%s|%s|%s|%s" % [collider.get_path(), contact["tile_key"], normal, contact["blocks_horizontal"]])

    var signature := ";".join(signature_parts) if not signature_parts.is_empty() else "NO_PHYSICAL_COLLISION"
    signature += "|action=%d|climbing=%s|controls_locked=%s|dead=%s|movement=%s" % [_action, _climbing, controls_locked, dead, movement_function]
    if _armory_block_reported:
        return
    _armory_block_reported = true
    _last_blocked_contact_signature = signature

    var action_name := _action_name() if _action != PlayerAction.NORMAL else "NORMAL"
    var horizontal_blocker_found := false
    for contact in contacts:
        if bool(contact["blocks_horizontal"]):
            horizontal_blocker_found = true
            break
    var cause := "COLLISION_CANDIDATE" if horizontal_blocker_found else "NO_HORIZONTAL_COLLISION"
    print("[BLOQUEO_ARMERIA] causa=%s escena=%s jugador=%s posición_global=%s entrada_horizontal=%.2f velocidad_objetivo_por_input=%.2f velocidad_horizontal_solicitada=%.2f velocidad_horizontal_después=%.2f movimiento_real=%s movimiento_función=%s acción=%s controls_locked=%s climbing=%s dead=%s suelo=%s pared=%s fotogramas_bloqueado=%d número_colisiones=%d" % [
        cause,
        scene.scene_file_path,
        get_path(),
        global_position,
        horizontal_input,
        horizontal_input * move_speed,
        velocity_before.x,
        velocity.x,
        displacement,
        movement_function,
        action_name,
        controls_locked,
        _climbing,
        dead,
        is_on_floor(),
        is_on_wall(),
        _armory_stuck_frames,
        get_slide_collision_count(),
    ])
    if not horizontal_blocker_found:
        print("[BLOQUEO_ARMERIA_ESTADO] No hay normal de colisión que se oponga al movimiento horizontal. Revisar la función/estado indicado, velocidad previa, controles bloqueados, escalada y lógica que modifica velocity antes de move_and_slide().")
    for contact in contacts:
        var collider := contact["collider"] as Node
        var contact_kind := "PARED_HORIZONTAL" if bool(contact["blocks_horizontal"]) else ("SUELO/TECHO" if absf((contact["normal"] as Vector2).x) < 0.5 else "CONTACTO_DIAGONAL")
        print("[BLOQUEO_ARMERIA_CONTACTO] tipo=%s objeto=%s clase=%s ruta=%s rid=%s punto=%s normal=%s bloquea_horizontal=%s%s%s" % [
            contact_kind,
            collider.name,
            collider.get_class(),
            collider.get_path(),
            contact["rid"],
            contact["point"],
            contact["normal"],
            contact["blocks_horizontal"],
            contact["tile_details"],
            contact["shape_details"],
        ])


func request_ultimate() -> void:
    if dead or not GameManager.has_sword or _climbing or not is_on_floor() or not GameManager.has_ability("ultimate"):
        return
    if _ultimate_cooldown_left > 0.0:
        return
    if _action not in [PlayerAction.NORMAL, PlayerAction.DEFEND]:
        return

    if _action == PlayerAction.DEFEND:
        _leave_guard_for_action()

    _ultimate_cooldown_left = 0.0 if DevMode.no_ultimate_cooldown else ultimate_cooldown
    _combo_step = 0
    _combo_queued = false
    _combo_buffered_inputs = 0
    _start_attack(&"attack ultimate", ultimate_damage, PlayerAction.ULTIMATE)


func request_fireball() -> void:
    var blocked_reason := ""
    if not fireball_enabled:
        blocked_reason = "desactivada en el inspector"
    elif dead:
        blocked_reason = "muerto"
    elif not GameManager.has_sword:
        blocked_reason = "sin espada (modo dev: Dar espada)"
    elif _climbing or not is_on_floor():
        blocked_reason = "no está en el suelo"
    elif _fireball_cooldown_left > 0.0:
        blocked_reason = "enfriamiento %.1fs" % _fireball_cooldown_left
    elif _action not in [PlayerAction.NORMAL, PlayerAction.DEFEND]:
        blocked_reason = "ocupado en %s" % _action_name()
    elif not sprite.sprite_frames.has_animation(&"fireball"):
        blocked_reason = "falta la animación"
    if blocked_reason != "":
        print("[BOLA_FUEGO] no sale: %s" % blocked_reason)
        return

    if _action == PlayerAction.DEFEND:
        _leave_guard_for_action()

    _fireball_cooldown_left = fireball_cooldown
    _fireball_released = false
    _combo_step = 0
    _combo_queued = false
    _combo_buffered_inputs = 0
    _action = PlayerAction.CAST
    _current_attack_animation = &"fireball"
    _current_attack_damage = 0.0
    _attack_lunge_left = 0.0
    sprite.speed_scale = 1.0
    _action_total_time = _animation_duration(&"fireball")
    _action_time_left = _action_total_time
    sprite.play(&"fireball")
    sprite.frame = 0
    sprite.frame_progress = 0.0


func _update_fireball_release() -> void:
    if _action != PlayerAction.CAST or _fireball_released:
        return
    if sprite.animation != &"fireball" or sprite.frame < fireball_release_frame:
        return

    _fireball_released = true
    var facing := -1.0 if sprite.flip_h else 1.0
    var fireball := FIREBALL_SCENE.instantiate() as UnderkingdomPlayerProjectile
    fireball.speed = fireball_speed
    get_parent().add_child(fireball)
    # El cuadro se voltea sobre el centro del sprite, no sobre el del Player.
    var sprite_center := sprite.position + sprite.offset
    fireball.setup(
        global_position + sprite_center + Vector2(fireball_spawn_offset.x * facing, fireball_spawn_offset.y),
        facing,
        fireball_damage
    )


## start_frame >= 0 arranca la animación en ese cuadro en vez del "start" de su
## perfil (el primer tajo repetido se salta la preparación).
func _start_attack(
    animation_name: StringName,
    damage: float,
    action_type: PlayerAction,
    start_frame: int = -1
) -> void:
    if not GameManager.has_sword and animation_name != &"puch":
        return
    var profile := _attack_profile(animation_name)
    var first_frame := int(profile.start) if start_frame < 0 else start_frame
    _attack_sequence_id += 1
    _action = action_type
    _current_attack_damage = damage
    _current_attack_animation = animation_name
    _attack_is_repeat = false
    _current_attack_speed_multiplier = _attack_speed_multiplier_for(animation_name)
    sprite.speed_scale = _current_attack_speed_multiplier
    _action_total_time = (
        _frames_duration(animation_name, first_frame, int(profile.end))
        / maxf(_current_attack_speed_multiplier, 0.01)
    )
    _action_time_left = _action_total_time
    _attack_held_direction = _get_horizontal_input()
    _attack_lunge_left = attack_lunge_time if bool(profile.get("lunge", false)) and is_on_floor() else 0.0

    _attack_hit_targets.clear()
    _attack_subwindow_index = -1
    attack_hitbox.scale = Vector2.ONE
    sprite.play(animation_name)
    sprite.frame = first_frame
    sprite.frame_progress = 0.0
    attack_started.emit(animation_name, damage)


func _start_combo_step(step: int) -> void:
    _combo_step = step
    _combo_queued = _combo_buffered_inputs > 0
    _combo_queue_left = 0.0

    match step:
        2:
            _start_attack(&"attack 2", attack_2_damage, PlayerAction.ATTACK)
        3:
            _start_attack(&"attack 3", attack_3_damage, PlayerAction.ATTACK)
        _:
            _finish_action()
            return

    # Si el jugador ya habia pulsado el siguiente ataque, conservamos ese
    # input durante esta nueva etapa para que el combo no se corte.
    if _combo_buffered_inputs > 0:
        _combo_queue_left = _action_time_left + combo_queue_window + 0.25


func _update_combat_timers(delta: float) -> void:
    if _ultimate_cooldown_left > 0.0:
        _ultimate_cooldown_left = maxf(_ultimate_cooldown_left - delta, 0.0)
    if _fireball_cooldown_left > 0.0:
        _fireball_cooldown_left = maxf(_fireball_cooldown_left - delta, 0.0)

    # La guardia solo se recarga después de pasar un tiempo fuera de DEFEND.
    if _action == PlayerAction.DEFEND:
        _defend_elapsed += delta
    else:
        _time_since_guard += delta
    if _block_push_left > 0.0:
        _block_push_left = maxf(_block_push_left - delta, 0.0)

    if _guard_recharge_left > 0.0 and _action != PlayerAction.DEFEND:
        _guard_recharge_left = maxf(_guard_recharge_left - delta, 0.0)
        if _guard_recharge_left <= 0.0:
            _guard_hits_remaining = guard_max_hits

    if _combo_queue_left > 0.0:
        _combo_queue_left = maxf(_combo_queue_left - delta, 0.0)
        if _combo_queue_left <= 0.0:
            _combo_queued = false
            _combo_buffered_inputs = 0

    if _action in [
        PlayerAction.ATTACK,
        PlayerAction.AIR_ATTACK,
        PlayerAction.ROLL,
        PlayerAction.ULTIMATE,
        PlayerAction.HURT,
        PlayerAction.CAST
    ]:
        _action_time_left = maxf(_action_time_left - delta, 0.0)


func _update_action_state() -> void:
    # Al aterrizar, el ataque aéreo termina en cuanto su golpe ya salió.
    if _action == PlayerAction.AIR_ATTACK and is_on_floor() and _attack_hits_done():
        _finish_action()
        return

    # Cancelamos solo los frames de recuperacion de attack 1 y attack 2.
    # El siguiente golpe puede arrancar antes de que termine toda la animacion,
    # siempre que el jugador ya lo haya dejado en el buffer.
    if (
        _action == PlayerAction.ATTACK
        and _remaining_combo_inputs() > 0
        and _combo_buffered_inputs > 0
        and _can_chain_combo_early()
    ):
        _consume_combo_buffer_and_start_next()
        return

    if _action_time_left > 0.0:
        return

    if _action == PlayerAction.ATTACK:
        if _combo_buffered_inputs > 0 and _remaining_combo_inputs() > 0:
            _consume_combo_buffer_and_start_next()
        else:
            _finish_action()
    elif _action in [
        PlayerAction.AIR_ATTACK,
        PlayerAction.ROLL,
        PlayerAction.ULTIMATE,
        PlayerAction.HURT,
        PlayerAction.CAST
    ]:
        _finish_action()


func _can_chain_combo_early() -> bool:
    if sprite.animation != _current_attack_animation:
        return false

    match _current_attack_animation:
        &"attack":
            var chain_frame := attack_1_repeat_chain_frame if _repeats_first_attack() else attack_1_chain_frame
            return sprite.frame >= maxi(chain_frame, _last_hit_frame() + 1)
        &"attack 2":
            return sprite.frame >= maxi(attack_2_chain_frame, _last_hit_frame() + 1)
        _:
            return false


func _try_cancel_attack_by_movement() -> void:
    if not movement_cancels_attacks:
        return
    if _action not in [PlayerAction.ATTACK, PlayerAction.AIR_ATTACK]:
        return

    var direction := _get_horizontal_input()
    if is_zero_approx(direction):
        _attack_held_direction = 0.0

    # Una dirección recién pulsada corta al instante. La que ya venías
    # sosteniendo al atacar solo corta cuando el golpe ya salió, para que
    # atacar corriendo no se cancele solo.
    var new_direction := not is_zero_approx(direction) and direction != _attack_held_direction
    var held_after_hits := not is_zero_approx(direction) and _attack_hits_done()
    var jump := _action == PlayerAction.ATTACK and _jump_requested and is_on_floor()

    if new_direction or held_after_hits or jump:
        # _jump_requested se conserva para que el salto ocurra este mismo cuadro.
        _finish_action()


func _attack_hits_done() -> bool:
    if sprite.animation != _current_attack_animation:
        return true
    return sprite.frame > _last_hit_frame()


func _last_hit_frame() -> int:
    var last := -1
    for hit in _attack_profile(_current_attack_animation).hits:
        last = maxi(last, (hit.frames as Vector2i).y)
    return last


func _consume_combo_buffer_and_start_next() -> void:
    if _combo_buffered_inputs <= 0 or _remaining_combo_inputs() <= 0:
        return

    _combo_buffered_inputs -= 1
    _combo_queued = _combo_buffered_inputs > 0
    if _repeats_first_attack():
        _start_attack(&"attack", attack_1_damage, PlayerAction.ATTACK, attack_1_repeat_frame)
        _attack_is_repeat = true
        return
    _start_combo_step(_combo_step + 1)


## Pulsaciones que se pueden guardar ahora para seguir atacando.
func _remaining_combo_inputs() -> int:
    if _repeats_first_attack():
        return 1
    return maxi(_max_combo_step() - _combo_step, 0)


## Sin la Ráfaga, el primer tajo se encadena consigo mismo: machacar el botón
## da tajos seguidos en vez de perder las pulsaciones.
func _repeats_first_attack() -> bool:
    return _max_combo_step() == 1 and _combo_step == 1


## Etapas del combo en suelo que el Player ya tiene (GameManager: combo_2,
## combo_3). Sin la Ráfaga, el Golpe final tampoco se encadena.
func _max_combo_step() -> int:
    if not GameManager.has_sword:
        return 1
    if not GameManager.has_ability("combo_2"):
        return 1
    return 3 if GameManager.has_ability("combo_3") else 2


func _finish_action() -> void:
    var previous_action := _action
    if previous_action == PlayerAction.ROLL:
        _disable_roll_enemy_passthrough()

    _action = PlayerAction.NORMAL
    _action_time_left = 0.0
    _action_total_time = 0.0
    _current_attack_damage = 0.0
    _current_attack_animation = &""
    _combo_step = 0
    _combo_queued = false
    _combo_queue_left = 0.0
    _combo_buffered_inputs = 0
    _attack_hit_targets.clear()
    _attack_subwindow_index = -1
    _current_attack_speed_multiplier = 1.0
    _attack_lunge_left = 0.0
    sprite.speed_scale = 1.0
    attack_hitbox.scale = Vector2.ONE
    _update_attack_hitbox_position()


func _update_defense_state() -> void:
    if not GameManager.has_sword:
        if _action == PlayerAction.DEFEND:
            _finish_action()
        return
    var wants_defense := Input.is_action_pressed("defend")

    if not wants_defense:
        _guard_requires_release = false

    if wants_defense:
        if _guard_requires_release:
            return
        if (
            _action == PlayerAction.NORMAL
            and is_on_floor()
            and not _climbing
            and _guard_hits_remaining > 0
        ):
            _action = PlayerAction.DEFEND
            _defend_elapsed = 0.0
            _parry_available = _time_since_guard >= parry_rearm_time
            _set_static_defense_pose()
        elif _action == PlayerAction.DEFEND:
            _set_static_defense_pose()
    elif _action == PlayerAction.DEFEND:
        _leave_guard_for_action()
        _finish_action()


func _process_normal_movement(delta: float) -> void:
    _restore_terrain_collision_if_needed()
    _try_start_drop_through()

    var direction := _get_horizontal_input()
    var target_speed := direction * move_speed
    var change_rate := acceleration if direction != 0.0 else deceleration
    velocity.x = move_toward(velocity.x, target_speed, change_rate * delta)

    if not is_on_floor():
        velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)

    if _jump_requested and is_on_floor():
        velocity.y = jump_velocity
    _jump_requested = false


func _process_attack_movement(delta: float) -> void:
    if _attack_lunge_left > 0.0:
        # Paso corto al soltar el tajo: el peso de la espada arrastra al Player.
        _attack_lunge_left = maxf(_attack_lunge_left - delta, 0.0)
        var facing := -1.0 if sprite.flip_h else 1.0
        velocity.x = facing * attack_lunge_distance / maxf(attack_lunge_time, 0.01)
    else:
        velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)
    if not is_on_floor():
        velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
    _jump_requested = false


func _process_air_attack_movement(delta: float) -> void:
    # Conserva el impulso horizontal del salto; solo la caída se suaviza un poco.
    velocity.y = minf(velocity.y + gravity * 0.65 * delta, max_fall_speed)
    _jump_requested = false


func _process_roll(delta: float) -> void:
    # Velocidad que cae al cuadrado hasta 0: v0 * (1 - t)^2 recorre v0 * T / 3,
    # así que v0 = 3 * distancia / duración.
    var total := maxf(_action_total_time, 0.01)
    var progress := clampf(1.0 - _action_time_left / total, 0.0, 1.0)
    var start_speed := 3.0 * roll_distance / total
    velocity.x = _roll_direction * start_speed * pow(1.0 - progress, 2.0)
    if not is_on_floor():
        velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
    _jump_requested = false


func _process_defense_movement(delta: float) -> void:
    # Tras un bloqueo el empuje se frena despacio (unos 15 px); si no, se
    # para en seco como siempre.
    var brake := deceleration * (0.3 if _block_push_left > 0.0 else 1.5)
    velocity.x = move_toward(velocity.x, 0.0, brake * delta)
    if not is_on_floor():
        velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
    _jump_requested = false


func _process_hurt_movement(delta: float) -> void:
    velocity.x = move_toward(velocity.x, 0.0, deceleration * 0.35 * delta)
    if not is_on_floor():
        velocity.y = minf(velocity.y + gravity * delta, max_fall_speed)
    _jump_requested = false


func _try_start_drop_through() -> void:
    if _drop_through_left > 0.0:
        return
    if not is_on_floor():
        return

    var wants_down := Input.is_action_pressed("move_down")
    if not wants_down:
        return

    set_collision_mask_value(one_way_collision_layer, false)
    _drop_through_left = drop_through_time
    floor_snap_length = 0.0
    velocity.y = maxf(velocity.y, drop_down_speed)


func _update_drop_through(delta: float) -> void:
    if _drop_through_left <= 0.0:
        return

    _drop_through_left = maxf(_drop_through_left - delta, 0.0)

    if _drop_through_left <= 0.0:
        set_collision_mask_value(one_way_collision_layer, true)
        floor_snap_length = _normal_floor_snap_length


func _apply_climb_collision_mode() -> void:
    var pass_through := false

    if _active_climb_zone != null:
        var value = _active_climb_zone.get("ignore_normal_terrain_while_climbing")
        if value != null:
            pass_through = bool(value)

    if pass_through and not _terrain_collision_temporarily_disabled:
        set_collision_mask_value(1, false)
        _terrain_collision_temporarily_disabled = true
    elif not pass_through:
        _restore_terrain_collision_if_needed()


func _restore_terrain_collision_if_needed() -> void:
    if _terrain_collision_temporarily_disabled:
        set_collision_mask_value(1, true)
        _terrain_collision_temporarily_disabled = false


func _process_climbing() -> void:
    _apply_climb_collision_mode()
    var horizontal := _get_horizontal_input()
    var vertical := 0.0

    if Input.is_action_pressed("move_up"):
        vertical -= 1.0
    if Input.is_action_pressed("move_down"):
        vertical += 1.0

    var axis := Vector2.DOWN
    var allow_horizontal := true
    if _active_climb_zone != null:
        var axis_value: Variant = _active_climb_zone.get("climb_axis")
        if typeof(axis_value) == TYPE_VECTOR2:
            var configured_axis: Vector2 = axis_value
            if not configured_axis.is_zero_approx():
                axis = configured_axis.normalized()
        var horizontal_value: Variant = _active_climb_zone.get("allow_horizontal_adjustment")
        if horizontal_value != null:
            allow_horizontal = bool(horizontal_value)

    # W/arriba se mueve contra el eje (sube); S/abajo a favor (baja).
    velocity = axis * vertical * climb_speed
    if allow_horizontal:
        velocity.x += horizontal * climb_horizontal_speed
    _jump_requested = false


func set_climb_zone(zone: Node, inside: bool) -> void:
    if inside:
        if not _climb_zones.has(zone):
            _climb_zones.append(zone)
        _active_climb_zone = zone
    else:
        _climb_zones.erase(zone)

        if _active_climb_zone == zone:
            _active_climb_zone = _climb_zones[0] if not _climb_zones.is_empty() else null

        if _climb_zones.is_empty():
            _climbing = false
            _restore_terrain_collision_if_needed()


func _cleanup_climb_zones() -> void:
    for zone in _climb_zones.duplicate():
        if not is_instance_valid(zone):
            _climb_zones.erase(zone)

    if _active_climb_zone != null and not is_instance_valid(_active_climb_zone):
        _active_climb_zone = null

    if _climb_zones.is_empty():
        _climbing = false
        _restore_terrain_collision_if_needed()
    elif _active_climb_zone == null:
        _active_climb_zone = _climb_zones[0]


func _can_climb() -> bool:
    return not _climb_zones.is_empty()


func _has_climb_input() -> bool:
    return (
        Input.is_action_pressed("move_up")
        or Input.is_action_pressed("move_down")
    )


func set_ledge_transition_zone(zone: Node, inside: bool) -> void:
    if inside:
        if not _ledge_transition_zones.has(zone):
            _ledge_transition_zones.append(zone)
        _active_ledge_transition_zone = zone
    else:
        _ledge_transition_zones.erase(zone)

        if _active_ledge_transition_zone == zone:
            _active_ledge_transition_zone = (
                _ledge_transition_zones[0]
                if not _ledge_transition_zones.is_empty()
                else null
            )


func _cleanup_ledge_transition_zones() -> void:
    for zone in _ledge_transition_zones.duplicate():
        if not is_instance_valid(zone):
            _ledge_transition_zones.erase(zone)

    if (
        _active_ledge_transition_zone != null
        and not is_instance_valid(_active_ledge_transition_zone)
    ):
        _active_ledge_transition_zone = null

    if _active_ledge_transition_zone == null and not _ledge_transition_zones.is_empty():
        _active_ledge_transition_zone = _ledge_transition_zones[0]


func _update_ledge_transition_timer(delta: float) -> void:
    if _ledge_transition_cooldown > 0.0:
        _ledge_transition_cooldown = maxf(_ledge_transition_cooldown - delta, 0.0)


func _process_simple_ledge_input() -> void:
    if _active_ledge_transition_zone == null:
        return
    if _ledge_transition_cooldown > 0.0:
        return
    if dead or _action != PlayerAction.NORMAL or _climbing:
        return
    # La transición de la reja solo se inicia desde una superficie.
    # Así W no vuelve a disparar otro impulso mientras el Player está en el aire.
    if not is_on_floor():
        return

    var wants_up := Input.is_action_pressed("move_up")
    var wants_down := Input.is_action_pressed("move_down")

    # SUBIR: un solo impulso físico; después actúan la gravedad y move_and_slide().
    if GameManager.has_sword and wants_up and _active_ledge_transition_zone.has_method("can_go_up"):
        if _active_ledge_transition_zone.call("can_go_up", self):
            velocity.y = float(
                _active_ledge_transition_zone.call("get_jump_velocity")
            )
            _jump_requested = false
            _ledge_transition_cooldown = 0.48
            return

    # BAJAR: ignorar temporalmente solo la capa One Way y caer.
    if wants_down and _active_ledge_transition_zone.has_method("can_go_down"):
        if _active_ledge_transition_zone.call("can_go_down", self):
            set_collision_mask_value(one_way_collision_layer, false)
            _drop_through_left = maxf(_drop_through_left, 0.32)
            floor_snap_length = 0.0
            velocity.y = float(
                _active_ledge_transition_zone.call("get_drop_velocity")
            )
            _jump_requested = false
            _ledge_transition_cooldown = 0.48

func _get_horizontal_input() -> float:
    var direction := 0.0
    if Input.is_action_pressed("move_left"):
        direction -= 1.0
    if Input.is_action_pressed("move_right"):
        direction += 1.0
    return direction


func _update_animation(direction: float) -> void:
    if GameManager.has_sword:
        # Los fotogramas ya comparten el mismo eje; conserva el offset base del nodo.
        sprite.offset = _armed_sprite_offset
    if _action != PlayerAction.NORMAL:
        return
    if _hurt_time_left > 0.0:
        return

    sprite.speed_scale = 1.0
    sprite.scale = _armed_sprite_scale if GameManager.has_sword else _base_sprite_scale

    if direction < 0.0:
        sprite.flip_h = true
    elif direction > 0.0:
        sprite.flip_h = false

    if not GameManager.has_sword:
        # prisn.tscn trae la animacion singular "escalera". El bloque desarmado
        # debe seleccionarla antes del retorno de idle/run o nunca se muestra.
        if _climbing and sprite.sprite_frames.has_animation(&"escalera"):
            sprite.position = _base_sprite_position
            sprite.offset = _base_sprite_offset
            sprite.scale = _base_sprite_scale
            if sprite.animation != &"escalera":
                sprite.play(&"escalera")
            if absf(velocity.y) > 1.0 or absf(velocity.x) > 1.0:
                if not sprite.is_playing():
                    sprite.play(&"escalera")
            else:
                sprite.pause()
            return
        # Los cuadros desarmados que arma el código fuera de prisn.tscn no traen "jump".
        if not is_on_floor() and sprite.sprite_frames.has_animation(&"jump"):
            if sprite.animation != &"jump":
                sprite.play(&"jump")
            elif velocity.y >= 0.0 and sprite.is_playing():
                # Conserva la pose aérea de caída hasta que la física confirme
                # el aterrizaje; la animación no modifica velocity.y.
                sprite.frame = mini(4, sprite.sprite_frames.get_frame_count(&"jump") - 1)
                sprite.pause()
            return
        var unarmed_animation: StringName = &"run" if absf(velocity.x) > 8.0 else &"idle"
        if sprite.animation != unarmed_animation or not sprite.is_playing():
            sprite.play(unarmed_animation)
        return

    # En escaleras, la animación propia (de espaldas). Ya viene angosta, así
    # que se dibuja a la escala normal; quieto en la escalera se congela.
    if _climbing:
        if sprite.animation != &"escaleras":
            sprite.play(&"escaleras")
        if absf(velocity.y) > 1.0 or absf(velocity.x) > 1.0:
            if not sprite.is_playing():
                sprite.play(&"escaleras")
        else:
            sprite.pause()
        return

    var wanted: StringName = &"idle"
    if not is_on_floor():
        wanted = &"jump up" if velocity.y < 0.0 else &"jump down"
    elif absf(velocity.x) > 8.0:
        wanted = &"run"

    if sprite.animation != wanted or not sprite.is_playing():
        sprite.play(wanted)


func _update_attack_hitbox_position() -> void:
    var facing := -1.0 if sprite.flip_h else 1.0
    if not GameManager.has_sword:
        attack_hitbox.position = Vector2(28.0 * facing, 26.0)
        attack_hitbox.scale = Vector2(0.65, 0.9)
        return
    attack_hitbox.position = Vector2(
        attack_hitbox_offset_x * facing,
        attack_hitbox_offset_y
    )


func _update_attack_damage_window() -> void:
    if (
        _action not in [PlayerAction.ATTACK, PlayerAction.AIR_ATTACK, PlayerAction.ULTIMATE]
        or _current_attack_animation == &""
        or sprite.animation != _current_attack_animation
    ):
        _reset_attack_hitbox()
        return

    var hits: Array = _attack_profile(_current_attack_animation).hits
    var index := -1
    for i in hits.size():
        var frames: Vector2i = hits[i].frames
        if sprite.frame >= frames.x and sprite.frame <= frames.y:
            index = i
            break
    if index < 0:
        _reset_attack_hitbox()
        return

    # Cada golpe es una ventana nueva: el mismo enemigo puede recibir todos
    # los golpes de una ráfaga, pero solo uno por ventana.
    if index != _attack_subwindow_index:
        _attack_subwindow_index = index
        _attack_hit_targets.clear()

    var hit: Dictionary = hits[index]
    var damage := _current_attack_damage * float(hit.ratio)
    var knockback := bool(hit.knockback) and not _attack_is_repeat
    var area := String(hit.area)
    var facing := -1.0 if sprite.flip_h else 1.0

    match area:
        "around":
            attack_hitbox.position = Vector2(0.0, attack_hitbox_offset_y)
            attack_hitbox.scale = Vector2(1.90, 1.35)
        "wide":
            _update_attack_hitbox_position()
            attack_hitbox.scale = Vector2(1.45, 1.20)
        "blast":
            attack_hitbox.position = Vector2(76.0 * facing, attack_hitbox_offset_y)
            attack_hitbox.scale = Vector2(1.85, 1.30)
        _:
            _update_attack_hitbox_position()
            attack_hitbox.scale = Vector2.ONE

    var connected := (
        _damage_around_targets(damage, knockback)
        if area == "around"
        else _damage_attack_overlaps(damage, knockback)
    )
    if connected:
        # El tajo repetido no aturde, pero se siente igual que el primero.
        _play_hit_impact(bool(hit.knockback), area == "blast")


## Hitstop y temblor al conectar con un enemigo: el peso de la espada se nota
## en el impacto, no en la espera.
func _play_hit_impact(knockback: bool, heavy: bool) -> void:
    if not knockback:
        UnderkingdomCombatFX.hit_stop(hit_stop_continuous_time, hit_stop_time_scale)
        return
    UnderkingdomCombatFX.hit_stop(hit_stop_heavy_time if heavy else hit_stop_time, hit_stop_time_scale)
    if camera != null:
        camera.shake(hit_shake_heavy_strength if heavy else hit_shake_strength, hit_shake_time)


func _reset_attack_hitbox() -> void:
    attack_hitbox.scale = Vector2.ONE
    _attack_subwindow_index = -1
    _update_attack_hitbox_position()


func _attack_profile(animation_name: StringName) -> Dictionary:
    if ATTACK_PROFILES.has(animation_name):
        return ATTACK_PROFILES[animation_name]

    # Animación sin perfil: un único golpe en la parte central.
    var frame_count := sprite.sprite_frames.get_frame_count(animation_name)
    var last := maxi(frame_count - 1, 0)
    var start_frame := int(floor(last * attack_active_start_ratio))
    var end_frame := maxi(start_frame, int(ceil(last * attack_active_end_ratio)))
    return {"start": 0, "end": last, "hits": [
        {"frames": Vector2i(start_frame, end_frame), "ratio": 1.0, "area": "front", "knockback": true},
    ]}


## Devuelve si algún enemigo recibió el golpe.
func _damage_around_targets(damage_amount: float, knockback: bool) -> bool:
    # Consulta física real centrada en el Player: detecta enemigos delante y
    # detrás con el mismo alcance, sin depender del origen del enemigo.
    var radius := attack_hitbox_offset_x + 41.0
    var hitbox_shape_node := attack_hitbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
    if hitbox_shape_node != null and hitbox_shape_node.shape is RectangleShape2D:
        var rect := hitbox_shape_node.shape as RectangleShape2D
        radius = attack_hitbox_offset_x + rect.size.x * 0.5

    var circle := CircleShape2D.new()
    circle.radius = radius

    var query := PhysicsShapeQueryParameters2D.new()
    query.shape = circle
    query.transform = Transform2D(0.0, global_position + Vector2(0.0, attack_hitbox_offset_y))
    query.collision_mask = attack_hitbox.collision_mask
    query.collide_with_bodies = true
    query.collide_with_areas = false
    query.exclude = [get_rid()]

    var connected := false
    for result in get_world_2d().direct_space_state.intersect_shape(query, 32):
        var target := result.get("collider") as Node
        if target == null or target == self:
            continue
        if not target.is_in_group("enemy") and not target.is_in_group("breakable"):
            continue
        connected = _damage_target_once(target, damage_amount, knockback) or connected
    return connected


## Devuelve si algún enemigo recibió el golpe.
func _damage_attack_overlaps(damage_amount: float, knockback: bool) -> bool:
    var connected := false
    for body in attack_hitbox.get_overlapping_bodies():
        if body == self:
            continue
        connected = _damage_target_once(body, damage_amount, knockback) or connected
    return connected


## Devuelve true si el objetivo es un enemigo y aceptó el daño (los rompibles
## no cuentan para el hitstop).
func _damage_target_once(body: Node, damage_amount: float, knockback: bool) -> bool:
    var body_id := body.get_instance_id()
    if _attack_hit_targets.has(body_id):
        return false

    # Solo consumimos el objetivo si el daño fue aceptado. Si el enemigo
    # estaba invulnerable, puede volver a intentarse durante la ventana.
    var accepted := (
        _try_damage_attack_target(body, damage_amount)
        if knockback
        else _try_damage_continuous_target(body, damage_amount)
    )
    if accepted:
        _attack_hit_targets.append(body_id)
        UnderkingdomCombatFX.hit_flash(body)
    return accepted and body.is_in_group("enemy")


func _try_damage_attack_target(body: Node, damage_amount: float = -1.0) -> bool:
    var result: Variant = null
    var resolved_damage := _current_attack_damage if damage_amount < 0.0 else damage_amount
    var health_before := _enemy_health_value(body)

    if body.has_method("take_player_attack_from"):
        result = body.call(
            "take_player_attack_from",
            global_position,
            resolved_damage,
            _current_attack_animation,
            _attack_sequence_id
        )
    elif body.has_method("take_damage_from"):
        result = body.call("take_damage_from", global_position, resolved_damage)
    elif body.has_method("take_damage"):
        result = body.call("take_damage", resolved_damage)
    else:
        return false

    var accepted := bool(result) if typeof(result) == TYPE_BOOL else true
    if accepted:
        _register_actual_damage_for_lifesteal(body, health_before)
    return accepted


func _try_damage_continuous_target(body: Node, damage_amount: float) -> bool:
    var result: Variant = null
    var health_before := _enemy_health_value(body)

    if body.has_method("take_player_continuous_attack_from"):
        result = body.call(
            "take_player_continuous_attack_from",
            global_position,
            damage_amount,
            _current_attack_animation,
            _attack_sequence_id
        )
    elif body.has_method("take_continuous_damage_from"):
        result = body.call("take_continuous_damage_from", global_position, damage_amount)
    else:
        return _try_damage_attack_target(body, damage_amount)

    var accepted := bool(result) if typeof(result) == TYPE_BOOL else true
    if accepted:
        _register_actual_damage_for_lifesteal(body, health_before)
    return accepted


func _enemy_health_value(body: Node) -> float:
    if not body.is_in_group("enemy"):
        return -1.0
    var value: Variant = body.get("current_health")
    if value == null:
        return -1.0
    return float(value)


func _register_actual_damage_for_lifesteal(body: Node, health_before: float) -> void:
    if health_before < 0.0 or not body.is_in_group("enemy"):
        return

    var value: Variant = body.get("current_health")
    if value == null:
        return

    var actual_damage := maxf(health_before - float(value), 0.0)
    _register_lifesteal_damage(actual_damage)


func _register_lifesteal_damage(actual_damage: float) -> void:
    if not is_lifesteal_active() or actual_damage <= 0.0 or dead:
        return

    # No se guarda curación mientras la vida está llena; hay que combatir
    # estando herido para aprovechar el robo de vida.
    if current_health >= max_health:
        _lifesteal_damage_bank = 0.0
        return

    var multiplier := 1.0
    if _current_attack_animation == &"attack ultimate":
        multiplier = ultimate_lifesteal_multiplier

    _lifesteal_damage_bank += actual_damage * multiplier
    var requirement := maxf(lifesteal_damage_required, 0.01)

    while _lifesteal_damage_bank >= requirement and current_health < max_health:
        _lifesteal_damage_bank -= requirement
        heal(lifesteal_heal_amount)
        UnderkingdomCombatFX.heal(self, sprite)

    if current_health >= max_health:
        _lifesteal_damage_bank = 0.0


func _attack_speed_multiplier_for(animation_name: StringName) -> float:
    var multiplier := 1.0

    # Las animaciones del pack van lentas (9-10 fps); el combo y el ataque
    # aéreo se aceleran un poco incluso con vida normal.
    if animation_name == &"attack":
        multiplier *= maxf(attack_1_speed_multiplier, 1.0)
    elif animation_name in [&"attack 2", &"attack 3"]:
        multiplier *= maxf(combo_base_speed_multiplier, 1.0)
    elif animation_name == &"air attack":
        multiplier *= maxf(air_attack_speed_multiplier, 1.0)
    elif animation_name == &"puch":
        multiplier *= maxf(unarmed_attack_speed_multiplier, 1.0)

    if is_adrenaline_active():
        if animation_name != &"attack ultimate" or adrenaline_affects_ultimate:
            multiplier *= maxf(adrenaline_attack_speed_multiplier, 1.0)

    return multiplier


func is_adrenaline_active() -> bool:
    return (
        adrenaline_enabled
        and GameManager.has_ability("adrenaline")
        and max_health > 0.0
        and current_health <= max_health * adrenaline_health_ratio
    )


func is_lifesteal_active() -> bool:
    return lifesteal_enabled and GameManager.has_ability("lifesteal")


## 0.0 = recién usada, 1.0 = lista. La usa el HUD.
func get_ultimate_ready_ratio() -> float:
    if ultimate_cooldown <= 0.0:
        return 1.0
    return 1.0 - clampf(_ultimate_cooldown_left / ultimate_cooldown, 0.0, 1.0)


func get_ultimate_cooldown_left() -> float:
    return _ultimate_cooldown_left


## Daño acumulado hacia la próxima curación del robo de vida.
func get_lifesteal_progress() -> float:
    return _lifesteal_damage_bank


func set_ultimate_cooldown_progress(ready_ratio: float) -> void:
    var remaining_ratio := 1.0 - clampf(ready_ratio, 0.0, 1.0)
    _ultimate_cooldown_left = ultimate_cooldown * remaining_ratio


func _animation_duration(animation_name: StringName) -> float:
    if not sprite.sprite_frames.has_animation(animation_name):
        return 0.20

    var fps := sprite.sprite_frames.get_animation_speed(animation_name)
    if fps <= 0.0:
        return 0.20

    var duration := 0.0
    var frame_count := sprite.sprite_frames.get_frame_count(animation_name)

    for frame_index in range(frame_count):
        duration += sprite.sprite_frames.get_frame_duration(animation_name, frame_index) / fps

    return maxf(duration, 0.08)


func _frames_duration(animation_name: StringName, from_frame: int, to_frame: int) -> float:
    if not sprite.sprite_frames.has_animation(animation_name):
        return 0.20
    var fps := sprite.sprite_frames.get_animation_speed(animation_name)
    if fps <= 0.0:
        return 0.20
    var last := sprite.sprite_frames.get_frame_count(animation_name) - 1
    var duration := 0.0
    for frame_index in range(clampi(from_frame, 0, last), clampi(to_frame, 0, last) + 1):
        duration += sprite.sprite_frames.get_frame_duration(animation_name, frame_index) / fps
    return maxf(duration, 0.08)


func _is_flurry_active() -> bool:
    # La ráfaga de attack 2 (cuadros 8-16) no se interrumpe al recibir daño.
    return (
        _action == PlayerAction.ATTACK
        and _current_attack_animation == &"attack 2"
        and sprite.animation == &"attack 2"
        and sprite.frame <= 16
    )


func _hurt_animation_name() -> StringName:
    var wanted: StringName = &"take hit" if GameManager.has_sword else &"takehit"
    return wanted if sprite.sprite_frames.has_animation(wanted) else &"idle"


func take_damage(
    amount: float,
    source_global_position: Vector2 = Vector2.ZERO,
    apply_knockback: bool = false
) -> bool:
    if dead or amount <= 0.0 or is_invulnerable():
        return false

    if _action == PlayerAction.DEFEND:
        # Parry: el golpe llegó justo después de cubrirse. No gasta guardia y
        # aturde al atacante (solo golpes de un enemigo, con origen).
        if (
            _parry_available
            and _defend_elapsed <= parry_window
            and apply_knockback
            and GameManager.has_ability("parry")
        ):
            _perform_parry(source_global_position)
            return true

        # La guardia bloquea por completo hasta tres impactos. El tercer golpe
        # también queda bloqueado, pero rompe la guardia y deja al Player
        # vulnerable durante una breve recuperación.
        _block_guard_hit()
        if _action == PlayerAction.DEFEND and apply_knockback:
            var away := signf(global_position.x - source_global_position.x)
            if not is_zero_approx(away):
                velocity.x = away * block_pushback
                _block_push_left = 0.25
        return true

    # Modo dev: el golpe se recibe (animación, empuje, invulnerabilidad) pero
    # no quita vida.
    if not DevMode.infinite_health:
        current_health = maxf(current_health - amount, 0.0)
    damaged.emit(amount)
    health_changed.emit(current_health, max_health)

    if current_health <= 0.0:
        die()
        return true

    # Durante la ráfaga de attack 2 el Player NO es invulnerable: pierde vida
    # normalmente, pero el golpe no interrumpe la ráfaga ni cambia la animación
    # a take hit. Conservamos la invulnerabilidad breve posterior para evitar
    # que una sola Hitbox enemiga vacíe toda la vida en un frame.
    if _is_flurry_active():
        _invulnerability_left = invulnerability_time
        _blink_accumulator = 0.0
        _blink_visible = true
        _update_hud("DAÑO -%.2f (RÁFAGA)" % amount)
        return true

    _invulnerability_left = invulnerability_time
    _hurt_time_left = hurt_animation_time
    _blink_accumulator = 0.0
    _blink_visible = true
    _combo_step = 0
    _combo_queued = false
    _combo_buffered_inputs = 0

    if apply_knockback:
        _apply_knockback(source_global_position)

    _action = PlayerAction.HURT
    _current_attack_speed_multiplier = 1.0
    sprite.speed_scale = 1.0
    var hurt_animation := _hurt_animation_name()
    _action_total_time = maxf(_animation_duration(hurt_animation), hurt_animation_time)
    _action_time_left = _action_total_time
    sprite.play(hurt_animation)
    _update_hud("DAÑO -%.2f" % amount)
    return true


func take_damage_from(source_global_position: Vector2, amount: float) -> bool:
    return take_damage(amount, source_global_position, true)


func _apply_knockback(source_global_position: Vector2) -> void:
    var horizontal_direction := signf(global_position.x - source_global_position.x)

    if is_zero_approx(horizontal_direction):
        horizontal_direction = -1.0 if not sprite.flip_h else 1.0

    velocity.x = horizontal_direction * knockback_horizontal
    velocity.y = knockback_vertical


func is_invulnerable() -> bool:
    return cinematic_invulnerable or _invulnerability_left > 0.0 or _action == PlayerAction.ULTIMATE


## Colgado de una escalera. Lo usan los jefes para saber si el Player está
## quieto en el aire (no saltando) y vale la pena ir a buscarlo.
func is_climbing() -> bool:
    return _climbing


func _update_damage_timers(delta: float) -> void:
    if _hurt_time_left > 0.0:
        _hurt_time_left = maxf(_hurt_time_left - delta, 0.0)

    if _invulnerability_left <= 0.0:
        _restore_sprite_visibility()
        return

    _invulnerability_left = maxf(_invulnerability_left - delta, 0.0)

    if blink_while_invulnerable:
        _blink_accumulator += delta
        if _blink_accumulator >= 0.08:
            _blink_accumulator = 0.0
            _blink_visible = not _blink_visible
            sprite.modulate.a = 1.0 if _blink_visible else 0.35

    if _invulnerability_left <= 0.0:
        _restore_sprite_visibility()


func _restore_sprite_visibility() -> void:
    _blink_visible = true
    _blink_accumulator = 0.0
    if is_instance_valid(sprite):
        sprite.modulate.a = 1.0


func _leave_guard_for_action() -> void:
    _time_since_guard = 0.0
    if _guard_hits_remaining < guard_max_hits:
        _guard_recharge_left = maxf(_guard_recharge_left, guard_recharge_delay)


func _set_static_defense_pose() -> void:
    if not sprite.sprite_frames.has_animation(&"defende"):
        return
    sprite.speed_scale = 1.0
    if sprite.animation != &"defende":
        sprite.play(&"defende")
    # La pose mostrada por el usuario corresponde al frame 5. La dejamos
    # completamente estática mientras Q/clic derecho permanezcan presionados.
    var frame_count := sprite.sprite_frames.get_frame_count(&"defende")
    sprite.frame = clampi(5, 0, maxi(frame_count - 1, 0))
    sprite.frame_progress = 0.0
    sprite.pause()


func _perform_parry(source_global_position: Vector2) -> void:
    _parry_available = false
    var attacker := _find_attacker(source_global_position)
    if attacker != null and attacker.has_method("receive_parry"):
        attacker.call("receive_parry", parry_stun_time)
    UnderkingdomCombatFX.parry(self, sprite)
    _update_hud("PARRY")


func _find_attacker(source_global_position: Vector2) -> Node:
    # Los enemigos envían su propia posición como origen del golpe.
    for node in get_tree().get_nodes_in_group("enemy"):
        if node is Node2D and (node as Node2D).global_position.distance_to(source_global_position) < 2.0:
            return node
    return null


func _block_guard_hit() -> void:
    _guard_hits_remaining = maxi(_guard_hits_remaining - 1, 0)
    _guard_recharge_left = maxf(_guard_recharge_left, guard_recharge_delay)

    if _guard_hits_remaining > 0:
        UnderkingdomCombatFX.block_spark(self, sprite)
        _update_hud("BLOQUEO %d/%d" % [_guard_hits_remaining, guard_max_hits])
        return

    # Guard Break: el impacto se bloquea, pero la guardia termina y el Player
    # queda brevemente aturdido. No pierde vida por el golpe que rompió la guardia.
    _guard_requires_release = true
    _action = PlayerAction.HURT
    _action_total_time = guard_break_stun_time
    _action_time_left = guard_break_stun_time
    _hurt_time_left = guard_break_stun_time
    velocity.x = 0.0
    sprite.play(_hurt_animation_name())
    UnderkingdomCombatFX.guard_break(self, sprite)
    _update_hud("GUARD BREAK")


func _enable_roll_enemy_passthrough() -> void:
    _disable_roll_enemy_passthrough()
    for node in get_tree().get_nodes_in_group("enemy"):
        if node is PhysicsBody2D and node != self:
            var body := node as PhysicsBody2D
            add_collision_exception_with(body)
            body.add_collision_exception_with(self)
            _roll_collision_exceptions.append(body)


func _disable_roll_enemy_passthrough() -> void:
    for body in _roll_collision_exceptions:
        if is_instance_valid(body):
            remove_collision_exception_with(body)
            body.remove_collision_exception_with(self)
    _roll_collision_exceptions.clear()


func heal(amount: float) -> void:
    if dead or amount <= 0.0:
        return

    current_health = minf(current_health + amount, max_health)
    health_changed.emit(current_health, max_health)
    _update_hud("CURACIÓN")


## Toma una poción del inventario. No se gasta con la vida llena.
func drink_potion() -> bool:
    if dead or current_health >= max_health:
        return false
    if not DevMode.infinite_potions and not GameManager.use_potion():
        return false
    heal(potion_heal_amount)
    UnderkingdomCombatFX.heal(self, sprite)
    return true


func die() -> void:
    if dead or cinematic_invulnerable:
        return
    # Modo dev: los vacíos y las kill zones devuelven al último punto de
    # reaparición sin recargar el mapa.
    if DevMode.infinite_health:
        respawn_now()
        return

    dead = true
    velocity = Vector2.ZERO
    current_health = 0.0
    _invulnerability_left = 0.0
    _lifesteal_damage_bank = 0.0
    _current_attack_speed_multiplier = 1.0
    sprite.speed_scale = 1.0
    _disable_roll_enemy_passthrough()
    _action = PlayerAction.NORMAL
    _restore_sprite_visibility()
    if GameManager.has_sword:
        sprite.offset = _armed_sprite_offset

    health_changed.emit(current_health, max_health)
    died.emit()

    sprite.play(&"death" if sprite.sprite_frames.has_animation(&"death") else &"idle")
    _update_hud("MUERTO — reapareciendo...")

    # No cortar la muerte: esperamos como mínimo la duración completa de la
    # animación antes de reaparecer. respawn_delay solo actúa como mínimo.
    var death_wait := maxf(_animation_duration(&"death"), respawn_delay)
    await get_tree().create_timer(death_wait).timeout

    if not is_inside_tree():
        return
    if reload_map_on_death:
        GameManager.respawn_after_death()
    else:
        respawn_now()


func kill() -> void:
    die()


func respawn_now() -> void:
    global_position = spawn_position
    velocity = Vector2.ZERO
    current_health = max_health
    dead = false

    _jump_requested = false
    _hurt_time_left = 0.0
    _invulnerability_left = 0.0
    _drop_through_left = 0.0
    _ultimate_cooldown_left = 0.0
    _lifesteal_damage_bank = 0.0
    _current_attack_speed_multiplier = 1.0
    sprite.speed_scale = 1.0
    _guard_hits_remaining = guard_max_hits
    _guard_recharge_left = 0.0
    _guard_requires_release = false
    _parry_available = false
    _time_since_guard = 99.0
    _block_push_left = 0.0
    _disable_roll_enemy_passthrough()
    _ledge_transition_cooldown = 0.0
    set_collision_mask_value(one_way_collision_layer, true)
    set_collision_mask_value(1, true)
    _terrain_collision_temporarily_disabled = false
    floor_snap_length = _normal_floor_snap_length
    _restore_sprite_visibility()
    _finish_action()

    sprite.play(&"idle")
    health_changed.emit(current_health, max_health)
    respawned.emit()
    _update_hud("REAPARECIDO")


func set_spawn_point(new_position: Vector2) -> void:
    spawn_position = new_position
    GameManager.set_respawn_point(new_position)


func _action_name() -> String:
    match _action:
        PlayerAction.ATTACK:
            return "ATAQUE %d" % _combo_step
        PlayerAction.AIR_ATTACK:
            return "ATAQUE AÉREO"
        PlayerAction.ROLL:
            return "ROLL"
        PlayerAction.DEFEND:
            return "DEFENSA"
        PlayerAction.ULTIMATE:
            return "ULTIMATE"
        PlayerAction.HURT:
            return "DAÑO"
        PlayerAction.CAST:
            return "BOLA DE FUEGO"
        _:
            return "JUGANDO"


func _update_hud(state: String) -> void:
    if not info_label or not show_debug_hud:
        return

    var ult_text := "LISTA"
    if _ultimate_cooldown_left > 0.0:
        ult_text = "%.1fs" % _ultimate_cooldown_left

    var adrenaline_text := "ACTIVA" if is_adrenaline_active() else "normal"
    info_label.text = (
        "PRUEBA PLAYER — %s\n" % state
        + "Vida: %.2f / %.2f   Ultimate: %s   Adrenalina: %s\n" % [current_health, max_health, ult_text, adrenaline_text]
        + "Robo de vida: %.2f / %.2f daño\n" % [_lifesteal_damage_bank, lifesteal_damage_required]
        + "A/D: mover  ESPACIO/W/↑: saltar  F/Z o CLICK: atacar\n"
        + "Q o CLICK DER.: defender  SHIFT: roll  E: ultimate  X: bola de fuego\n"
        + "H: daño 1/4  J: daño 1 corazón  K: morir  R: reaparecer"
    )
