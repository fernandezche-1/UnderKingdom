# P42 - Calabozo inicial: a puño hasta la espada oxidada

- El protagonista sale de la prisión desnudo y sin arma. Antes llegaba así al castillo y la espada solo se recuperaba en la armería.
- Ahora, entre la prisión y el castillo, hay un tramo corto y lineal, el **calabozo**:
  - se pelea a puñetazos contra un carcelero;
  - el carcelero suelta la primera arma, una **espada oxidada**;
  - con ella se abre la reja de la salida y se entra armado al castillo.
- Ruta: cinemática inicial → prisión → **calabozo** → castillo → cementerio…

## 1. El mapa

- `mapas_texto/tiles_calabozo.txt` (mapa de letras, 96 x 18 piezas, tileset `castillo`) genera `escenas/mapas/tiles_calabozo.tscn`. Se juega desde `tiles_calabozo_combate.tscn`.
- **Sin saltos**: el Player sin espada no salta ni rueda. Todo es suelo corrido y la bajada es una rampa de tres piezas (x 34-36).
- Tramos:
  1. Pasillo de celdas (x 2-33), con el inicio en (4, 9).
  2. Rampa de bajada.
  3. Checkpoint en (41, 12).
  4. Sala del carcelero (x 37-87).
  5. Reja en la columna 88, filas 10-12, bajo un muro que baja del techo.
  6. Salida azul en la columna 95, filas 10-12, a `tiles_castillo_combate.tscn#SpawnInicio`.
- Opción nueva del constructor, `jugador:`, para elegir la escena del Player. El calabozo usa `res://escenas/prisn.tscn`, el Player del prólogo. Por defecto sigue `player.tscn`.
- La prisión (`camara_sellado_alma.tscn`) sale ahora al calabozo. Solo cambió su `target_scene_path`.

## 2. El carcelero

- `escenas/enemigos/carcelero.tscn` hereda de `esqueleto_lanza.tscn` (arte Skeleton) y cambia su script por `scripts/combat/jailer_sword_drop.gd`.
- Pensado para ganarle a puño, donde cada puño quita 0.25:
  - 2 corazones de vida, es decir, 8 puñetazos;
  - sin escudo;
  - quita 0.25 cada 1.8 s;
  - es lento (patrulla a 20, persigue a 42).
- Al cargar el mapa arranca la misión de la espada (`start_sword_mission`). Al terminar su muerte:
  - `mark_encounter_completed("calabozo_carcelero_derrotado")` y `mark_sword_guard_defeated()`;
  - abre la reja (`exit_gate`, una `arena_barrier`);
  - suelta `espada_oxidada.tscn` donde cayó.
- Si se vuelve al mapa con el carcelero ya vencido, no aparece, la reja queda abierta y la espada vuelve a estar ahí si no se recogió.
- Se pone a mano en la escena `_combate` (es único, sin letra del constructor).

### Primeros enemigos

Se pusieron a mano en `tiles_calabozo_combate.tscn` para ver cómo reaccionan; no tienen letra del constructor. Son los primeros del juego, y el esqueleto en este mapa es una excepción pedida a la regla de profundidad de P33.

| Enemigo | Escena | Dónde | Vida | Puños | Ataque |
|---|---|---|---|---|---|
| Rata | `enemigos/rata.tscn` | pasillo, x 300 | 0.5 | 2 | mordisco, 0.25 cada 1.6 s |
| Murciélago grande | `enemigos/murcielago_grande.tscn` | pasillo, x 470 | 1 | 4 | embestida (`lunge_enemy.gd`), 0.25 cada 1.8 s |
| Slime | `enemigos/slime.tscn` | entrada de la sala, x 840 | 0.75 | 3 | escupitajo, 0.25 cada 2 s |
| Esqueleto | `enemigos/esqueleto_lanza.tscn` (como carcelero) | fondo de la sala, x 1128 | 2 | 8 | lanza, 0.25 cada 1.8 s |

- El puñetazo no llega al ras del suelo: le faltan unos 12 px. Por eso rata y slime tienen 18 px de colisión, aunque se vean bajitos. Si se reduce, dejan de recibir golpes.
- Escala 1 en todos. El arte está en `assets_prueba/esqueleto_lanza/` y `assets_prueba/monster_creatures_2/`, cada uno con su `ORIGEN.txt`.
- Las hojas del Skeleton tienen cuadros de ancho distinto. `esqueleto_lanza.png` las une en celdas de 80x40 con el cuerpo al centro.

## 3. La espada oxidada

- `escenas/objetos/espada_oxidada.tscn` hereda de `espada_recuperable.tscn`: la misma espada, teñida de óxido, con "E - TOMAR ESPADA OXIDADA".
- `sword_recovery.gd` exporta el aviso del HUD (`notice_title`, `notice_text`); aquí dice "Espada oxidada / No es gran cosa... pero corta.".
- Usa `GameManager.recover_sword()`: `has_sword = true` y el Player pasa a tener espada.
- **Guardado:** `_restore_game_state` solo devolvía la espada si venía de la armería. Ahora también la devuelve si el guardado tiene el guardia vencido y la misión completa. No hay campos nuevos ni cambia `SAVE_FORMAT_VERSION`.

## 4. La armería del castillo

- Se queda como estaba, pero con la espada oxidada ya no se activa, porque pide `not has_sword`.
- La idea es que la espada y la armadura buenas se consigan más adelante. Cuando se muevan, hará falta un nivel de arma (por ejemplo `weapon_tier`) con daño propio.

## Verificación

- Arrancan sin errores el menú, el calabozo, la prisión, el castillo y Mundo 1. La prisión y Mundo 1 dan los avisos de siempre (P39).
- Prueba sin ventana, desde una partida nueva:
  - el carcelero cae al suelo y empieza con 2 de vida y la reja cerrada;
  - cae con 8 golpes de 0.25;
  - aparece una espada oxidada, la reja se abre y queda `sword_guard_defeated`;
  - al recogerla, `has_sword` y la misión quedan en verdadero;
  - tras reiniciar y restaurar el guardado, `has_sword` sigue en verdadero.

## Pendiente

- Arte de la espada oxidada (hoy, espada teñida).
- Jugarlo con ventana y ajustar la vida y el ataque de los enemigos del calabozo.
- Confirmar la licencia de los paquetes Skeleton y Monsters Creatures Fantasy 2.
- Decidir dónde va la espada buena con armadura y qué da de más.
