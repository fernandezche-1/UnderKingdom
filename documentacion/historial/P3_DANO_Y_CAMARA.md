# Underkingdom — P3: daño del Player y límites de cámara

## Implementado

### Daño del Player
- Vida máxima: 4 corazones.
- Daño mínimo de prueba: 0.25 corazón.
- Invulnerabilidad breve después de recibir daño.
- Parpadeo visual durante invulnerabilidad.
- Soporte para knockback cuando el daño proviene de una fuente.
- Animación `take hit`.
- Muerte al llegar a 0.
- Respawn al punto inicial.

### Controles temporales de prueba
- H = 0.25 corazón de daño.
- J = 1 corazón de daño.
- K = muerte instantánea.
- R = respawn manual.

### Cámara
La Camera2D ahora forma parte de `player.tscn`, por lo que el mismo Player
podrá utilizarla en cualquier mapa.

Cada mapa principal tiene un nodo:

`SistemasMapa/MapBounds`

Sus dimensiones coinciden con el PNG base del mapa.

La cámara lee esos límites automáticamente y no debe enseñar el exterior gris
cuando el Player llega a un borde.

Mapas configurados:
- Mundo 1: 1672 × 941
- Primer boss Mundo 1: 1672 × 941
- Mundo 2: 1672 × 941
- Mundo 3: 1254 × 1254
- Ruina: 1672 × 941
- Profundidades: 1672 × 941
- Jefe final: 1672 × 941

## Pendiente inmediato
- Escaleras/rampas.
- One Way verdes.
- KillZones rojo/rosado concretas.
- BurnZones blancas concretas.
