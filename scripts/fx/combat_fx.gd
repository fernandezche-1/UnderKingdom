extends RefCounted
class_name UnderkingdomCombatFX

## Efectos visuales de combate (impacto, muerte, bloqueo, Guard Break, curación).
## Usa self_modulate para no pisar el parpadeo de invulnerabilidad ni el aviso
## de Ultimate, que trabajan sobre modulate.

const BLOCK_COLOR := Color(1.0, 1.0, 0.85)
const GUARD_BREAK_COLOR := Color(1.0, 0.72, 0.2)
const HEAL_COLOR := Color(0.45, 1.0, 0.5)
const HIT_COLOR := Color(1.0, 0.45, 0.4)
const PARRY_COLOR := Color(0.6, 0.95, 1.0)

## Efectos con sprites de los paquetes: hoja horizontal, ancho y alto de cada
## cuadro y cuadros por segundo. Se reproducen una vez y se borran solos.
const SPRITE_FX := {
    &"impacto": ["res://assets_prueba/gothicvania/efectos/impacto.png", 31, 32, 18.0],
    &"muerte": ["res://assets_prueba/gothicvania/efectos/muerte_enemigo.png", 48, 48, 14.0],
    &"recoger": ["res://assets_prueba/super_grotto/recoger.png", 16, 16, 16.0],
    &"explosion_suelo": ["res://assets_prueba/gothicvania/efectos/explosion_suelo.png", 112, 128, 14.0],
}

static var _sprite_frames_cache: Dictionary = {}
## Hitstop en curso: cuál es el último (cada uno suma 1) y cuándo termina
## (Time.get_ticks_msec).
static var _hit_stop_serial: int = 0
static var _hit_stop_active: bool = false
static var _hit_stop_until_msec: int = 0


## Hitstop: frena todo el juego (Engine.time_scale) durante duration segundos
## reales. Si ya hay uno más largo en curso, se queda ese. El temporizador es
## del SceneTree, así que la velocidad vuelve a 1 aunque el Player desaparezca
## o se cambie de mapa entretanto.
static func hit_stop(duration: float, time_scale: float = 0.05) -> void:
    var tree := Engine.get_main_loop() as SceneTree
    if duration <= 0.0 or tree == null:
        return
    var until := Time.get_ticks_msec() + int(duration * 1000.0)
    if _hit_stop_active and until <= _hit_stop_until_msec:
        return
    _hit_stop_active = true
    _hit_stop_until_msec = until
    _hit_stop_serial += 1
    var serial := _hit_stop_serial
    Engine.time_scale = clampf(time_scale, 0.0, 1.0)
    # Solo el último temporizador devuelve la velocidad: uno anterior que
    # termine antes no corta el hitstop que lo sustituyó.
    tree.create_timer(duration, true, false, true).timeout.connect(func() -> void:
        if serial == _hit_stop_serial:
            _hit_stop_active = false
            Engine.time_scale = 1.0
    )


## Destello corto y chispa en el enemigo que recibe un golpe del Player.
static func hit_flash(body: Node) -> void:
    if body == null:
        return
    _flash(body.get("sprite") as CanvasItem, HIT_COLOR, 0.12)
    if body is Node2D:
        play_sprite(body as Node2D, &"impacto", _body_center(body as Node2D))


## Explosión al morir, para enemigos sin animación de muerte.
static func death_puff(body: Node2D) -> void:
    play_sprite(body, &"muerte", _body_center(body))


## Destello al recoger una moneda o una poción.
static func pickup_sparkle(item: Node2D) -> void:
    play_sprite(item, &"recoger", item.global_position)


## Reproduce una vez un efecto de SPRITE_FX centrado en global_pos. Se cuelga
## de la escena, no de quien lo pide: así sobrevive si este desaparece.
static func play_sprite(source: Node2D, fx_name: StringName, global_pos: Vector2) -> void:
    if not is_instance_valid(source) or not source.is_inside_tree():
        return
    var frames := _sprite_frames(fx_name)
    if frames == null:
        return
    var fx := AnimatedSprite2D.new()
    fx.sprite_frames = frames
    fx.z_index = 20
    var host := source.get_tree().current_scene
    if host == null:
        host = source.get_parent()
    host.add_child(fx)
    fx.global_position = global_pos.round()
    fx.animation_finished.connect(fx.queue_free)
    fx.play(&"fx")


static func _sprite_frames(fx_name: StringName) -> SpriteFrames:
    if _sprite_frames_cache.has(fx_name):
        return _sprite_frames_cache[fx_name]
    if not SPRITE_FX.has(fx_name):
        return null
    var data: Array = SPRITE_FX[fx_name]
    var sheet := load(data[0]) as Texture2D
    if sheet == null:
        return null
    var frames := SpriteFrames.new()
    frames.remove_animation(&"default")
    frames.add_animation(&"fx")
    frames.set_animation_loop(&"fx", false)
    frames.set_animation_speed(&"fx", data[3])
    var frame_size := Vector2i(data[1], data[2])
    for i in floori(float(sheet.get_width()) / frame_size.x):
        var atlas := AtlasTexture.new()
        atlas.atlas = sheet
        atlas.region = Rect2(Vector2(i * frame_size.x, 0), Vector2(frame_size))
        frames.add_frame(&"fx", atlas)
    _sprite_frames_cache[fx_name] = frames
    return frames


## Nube oscura al aparecer un enemigo de oleada o un jefe de arena.
static func spawn_puff(body: Node2D) -> void:
    _burst(body, Color(0.45, 0.35, 0.6), 18, 60.0, 180.0, 0.5, Vector2(0.0, -40.0))


## Parry: destello frío más fuerte que un bloqueo normal.
static func parry(body: Node2D, sprite: CanvasItem) -> void:
    _burst(body, PARRY_COLOR, 14, 110.0, 180.0, 0.35, Vector2.ZERO)
    _flash(sprite, PARRY_COLOR, 0.25)


static func block_spark(body: Node2D, sprite: CanvasItem) -> void:
    _burst(body, BLOCK_COLOR, 6, 45.0, 180.0, 0.25, Vector2(0.0, 120.0))
    _flash(sprite, BLOCK_COLOR, 0.12)


static func guard_break(body: Node2D, sprite: CanvasItem) -> void:
    _burst(body, GUARD_BREAK_COLOR, 18, 90.0, 180.0, 0.5, Vector2(0.0, 160.0))
    _flash(sprite, GUARD_BREAK_COLOR, 0.35)


static func heal(body: Node2D, sprite: CanvasItem) -> void:
    # Partículas que suben despacio, como un brillo de curación.
    _burst(body, HEAL_COLOR, 10, 28.0, 50.0, 0.6, Vector2(0.0, -40.0))
    _flash(sprite, HEAL_COLOR, 0.3)


static func _burst(
    body: Node2D,
    color: Color,
    amount: int,
    speed: float,
    spread_degrees: float,
    lifetime: float,
    particle_gravity: Vector2
) -> void:
    if not is_instance_valid(body) or not body.is_inside_tree():
        return

    var particles := CPUParticles2D.new()
    particles.one_shot = true
    particles.emitting = false
    particles.amount = amount
    particles.lifetime = lifetime
    particles.explosiveness = 1.0
    particles.direction = Vector2.UP
    particles.spread = spread_degrees
    particles.initial_velocity_min = speed * 0.5
    particles.initial_velocity_max = speed
    particles.gravity = particle_gravity
    particles.scale_amount_min = 1.0
    particles.scale_amount_max = 2.0
    particles.z_index = 20

    var ramp := Gradient.new()
    ramp.set_color(0, color)
    ramp.set_color(1, Color(color, 0.0))
    particles.color_ramp = ramp

    # Se cuelga de la escena, no del personaje: así sobrevive si este muere.
    var host := body.get_tree().current_scene
    if host == null:
        host = body.get_parent()
    host.add_child(particles)
    particles.global_position = _body_center(body)
    particles.finished.connect(particles.queue_free)
    particles.emitting = true


static func _flash(sprite: CanvasItem, color: Color, duration: float) -> void:
    if not is_instance_valid(sprite):
        return
    sprite.self_modulate = color
    var tween := sprite.create_tween()
    tween.tween_property(sprite, "self_modulate", Color.WHITE, duration)


static func _body_center(body: Node2D) -> Vector2:
    var shape := body.get_node_or_null("CollisionShape2D") as Node2D
    if shape != null:
        return shape.global_position
    return body.global_position
