# P52 - Reja baja que solo se pasa rodando

- Primera pieza del paso del castillo en la Fase 2 de `TASK.md`: la reja de `[H2]` (columna 104, filas 66-69 del castillo, bajo el trono) y las tres del pasillo del filo del infierno.
- Pieza: `scripts/environment/roll_gate.gd` (`UnderkingdomRollGate`), que hereda de `arena_barrier.gd`. No tiene escena propia: se coloca como las demás barreras, un `StaticBody2D` con el script, su `CollisionShape2D` (16 de ancho, alto múltiplo de 16) y las piezas del tileset del nivel.
- Decisiones de `docs/historial/FASE2_DECISIONES.md` que aplica: K1, K2 y G4.
- Toca el Player en una sola función: `is_rolling()`, que dice si la acción actual es la rodada.

## 1. Comportamiento (K1)

- Empieza cerrada (`start_closed` por defecto) y la colisión es la de una barrera normal: bloquea al Player y a los enemigos.
- Mientras el Player rueda, la reja y el Player se ignoran (excepción de colisión en las dos direcciones, como el paso a través de enemigos al rodar). Los enemigos nunca la cruzan: no tienen excepción.
- Si la rodada acaba con el Player dentro de la reja, se le empuja al lado por el que llegó (`push_margin` de separación) y se anula su velocidad en x. El lado se recuerda en cada cuadro en que el Player no la toca.
- `process_physics_priority` -10: la reja decide antes que el Player en cada cuadro, así la excepción ya vale el cuadro en que empieza la rodada y se quita antes de que el Player se mueva al acabarla.
- Con `open_on_encounter` (heredado) también se puede abrir del todo; abierta, no hay colisión ni excepciones.
- K2: no aplica. Sin espada no se rueda, y Rodar se consigue en el castillo antes de la reja.
- No guarda estado: es una pieza fija.

| Propiedad | Valor | Qué hace |
|---|---|---|
| `push_margin` | 1.0 | px de separación al empujar al Player fuera de la reja |
| las de `arena_barrier.gd` | | `piece_start`, `piece_middle`, `piece_end`, `fade_time`, `open_on_encounter` |

## 2. Alto de la reja

- En los mapas reales la reja ocupa todo el pasillo (4 piezas: filas 66-69, o las del pasillo del filo) y el techo impide saltarla. El salto del Player llega a unas 4,3 piezas (P45, sección 4), así que una reja de 4 en campo abierto se saltaría.
- En la zona de pruebas no hay techo: la reja mide 6 piezas.

## 3. Arte provisional

- Las piezas de la columna del tileset `castillo` (tope, medio, base), las mismas de las puertas con llave del castillo.
- **Pendiente:** arte propio de reja (barrotes bajos, con un hueco que se vea por debajo) y, si se quiere, un sonido al pasar.

## 4. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Objetos`: `RejaBaja` en `(248, 272)`, columna 15, filas 14-19, en el pasillo de inicio entre el cofre y la armadura.
- **Cierra:** caminando hacia la derecha desde el inicio, el Player se detiene contra la reja. Saltando tampoco la pasa.
- **Abre:** con espada (Modo dev, "Dar espada"), rodando (Shift) contra la reja la cruza.
- Para ver el empuje: rodar tan cerca de la reja que la rodada acabe dentro es difícil a mano; se comprobó por código.

## 5. Pruebas

- Escena temporal sin ventana (borrada al terminar), con el Player con espada:
  - sin rodar, 90 cuadros pulsando derecha: se queda en x 229 (la reja ocupa 240-256);
  - **abre:** rodando desde x 229, acaba en x 321, al otro lado;
  - rodada que acaba dentro (se fuerza `x = 248` y se termina la acción): empujado al lado de entrada, x 228 desde la izquierda y x 266 desde la derecha.
- Arrancan sin errores el juego, la zona de pruebas y `mundo_1` (el aviso de SpawnPoint ya salía antes).
