extends RefCounted
class_name UnderkingdomCombatFX

## Efectos visuales sencillos de combate (bloqueo, Guard Break, curación).
## Usa self_modulate para no pisar el parpadeo de invulnerabilidad ni el aviso
## de Ultimate, que trabajan sobre modulate.

const BLOCK_COLOR := Color(1.0, 1.0, 0.85)
const GUARD_BREAK_COLOR := Color(1.0, 0.72, 0.2)
const HEAL_COLOR := Color(0.45, 1.0, 0.5)
const HIT_COLOR := Color(1.0, 0.45, 0.4)
const PARRY_COLOR := Color(0.6, 0.95, 1.0)


## Destello corto en el enemigo que recibe un golpe del Player.
static func hit_flash(body: Node) -> void:
    if body == null:
        return
    _flash(body.get("sprite") as CanvasItem, HIT_COLOR, 0.12)


## Nube al morir, para enemigos sin animación de muerte.
static func death_puff(body: Node2D) -> void:
    _burst(body, Color(0.75, 0.7, 0.8), 16, 50.0, 180.0, 0.55, Vector2(0.0, -30.0))


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
