# P42 - Calabozo inicial: a puño hasta la espada oxidada

- El protagonista sale de la prisión desnudo y sin arma. Antes llegaba así al castillo y la espada solo se recuperaba en la armería.
- Ahora, entre la prisión y el castillo, está el **calabozo**:
  - desnudo es peligroso pelear, y conviene esquivar;
  - la reja interior corta el paso y obliga a ir por el conducto;
  - en el conducto está el cadáver de otro preso con la primera arma, una **espada oxidada**;
  - con ella se vence al carcelero, que suelta la llave de la salida.
- Ruta: cinemática inicial → prisión → **calabozo** → castillo → cementerio…

## 1. El mapa

- `mapas_texto/tiles_calabozo.txt` (mapa de letras, 96 x 24 piezas, tileset `castillo`) genera `escenas/mapas/tiles_calabozo.tscn`. Se juega desde `tiles_calabozo_combate.tscn`.
- Tramos:
  1. Pasillo de celdas (x 2-33), con el inicio en (4, 9).
  2. Entrada al conducto: escalera en la columna 28, en un hueco de 3 piezas en el suelo.
  3. Rampa de bajada (x 34-36) y checkpoint en (41, 12).
  4. Sala izquierda (x 37-61), con cofre en (58, 12).
  5. Reja interior en la columna 62, filas 10-12, bajo un muro.
  6. Conducto (filas 17-19, x 25-68), sin enemigos.
  7. Cámara del preso (x 46-52), con la espada y un checkpoint en (50, 19).
  8. Reja del conducto en la columna 54.
  9. Salida del conducto: escalera en la columna 66.
  10. Sala del carcelero (x 63-87).
  11. Reja de la salida en la columna 88, filas 10-12, bajo un muro.
  12. Salida azul en la columna 95, filas 10-12, a `tiles_castillo_combate.tscn#SpawnInicio`.
- Las filas 18-23 se añadieron al final para no mover nada de lo ya colocado.
- El conducto queda a más de 90 px por debajo de la sala, fuera del alcance vertical de los enemigos de suelo.
- **Escaleras que cruzan un piso:** el hueco es de 3 piezas, `.H.`. Con `=H=` no se baja: el Player mide 20 px, más que la pieza de 16, y las plataformas lo frenan.
- Los enemigos no caen por los huecos porque tienen `avoid_ledges`.
- Opción nueva del constructor, `jugador:`, para elegir la escena del Player. El calabozo usa `res://escenas/prisn.tscn`, el Player del prólogo. Por defecto sigue `player.tscn`.
- La prisión (`camara_sellado_alma.tscn`) sale ahora al calabozo. Solo cambió su `target_scene_path`.

### Las rejas

Las tres son `locked_door.gd`, a mano en la escena `_combate`.

| Reja | Posición | Se abre con | Para qué |
|---|---|---|---|
| `RejaInterior` | (1000, 184) | espada (`requires_sword`) | corta la sala; armado es un atajo para volver a por los enemigos esquivados |
| `RejaConducto` | (872, 296) | espada (`requires_sword`) | impide llegar al carcelero sin recoger la espada |
| `RejaSalida` | (1416, 184) | llave `calabozo_salida` | salida al castillo |

## 2. Sin espada

Exportados en `player.gd`, categoría "Combate". Valen en todo el juego mientras `has_sword` sea falso, no solo aquí:

| Ajuste | Sin espada | Con espada |
|---|---|---|
| `unarmed_move_speed` | 130 | 230 (`move_speed`) |
| `unarmed_jump_velocity` | -380, unos 50 px | -560, unos 104 px |
| `unarmed_extra_damage_taken` | +0.25 a cada golpe | nada |

- Los enemigos siguen en 0.75: desnudo quitan 1 corazón y armado, 0.75.
- Con 4 corazones se aguantan 3 golpes y el cuarto mata.

## 3. El carcelero

- `escenas/enemigos/carcelero.tscn` hereda de `esqueleto_lanza.tscn` (arte Skeleton) y cambia su script por `scripts/combat/jailer_key_drop.gd`.
- Es la primera pelea con espada:
  - 4 corazones de vida, es decir, 8 tajos de 0.5;
  - sin escudo;
  - quita 0.75 cada 1.8 s;
  - es lento (patrulla a 20, persigue a 42).
- Al cargar el mapa arranca la misión de la espada (`start_sword_mission`), sin la cual la espada no se muestra.
- Al terminar su muerte:
  - `mark_encounter_completed("calabozo_carcelero_derrotado")` y `mark_sword_guard_defeated()`;
  - suelta la llave `calabozo_salida` donde cayó.
- Si se vuelve al mapa con el carcelero ya vencido, no aparece y la llave vuelve a estar ahí si no se recogió.
- Se pone a mano en la escena `_combate` (es único, sin letra del constructor).

### Primeros enemigos

Se pusieron a mano en `tiles_calabozo_combate.tscn` para ver cómo reaccionan; no tienen letra del constructor. Son los primeros del juego, y el esqueleto en este mapa es una excepción pedida a la regla de profundidad de P33.

| Enemigo | Escena | Dónde | Vida | Puños | Ataque |
|---|---|---|---|---|---|
| Rata | `enemigos/rata.tscn` | pasillo, x 300 | 1.25 | 5 | mordisco, 0.75 cada 1.6 s |
| Murciélago grande | `enemigos/murcielago_grande.tscn` | pasillo, x 390 | 1 | 4 | embestida (`lunge_enemy.gd`), 0.75 cada 1.8 s |
| Rata | `enemigos/rata.tscn` | sala izquierda, x 740 | 1.25 | 5 | mordisco, 0.75 cada 1.6 s |
| Slime | `enemigos/slime.tscn` | sala izquierda, x 840 | 0.75 | 3 | escupitajo, 0.75 cada 2 s |

- El puñetazo no llega al ras del suelo: le faltan unos 12 px. Por eso rata y slime tienen 18 px de colisión, aunque se vean bajitos. Si se reduce, dejan de recibir golpes.
- **Sin bloqueo por machacar:** cada golpe cancelaba el ataque y aturdía, y el puñetazo se repite cada 0.5 s, así que nunca llegaban a pegar. `enemy_base.gd` tiene dos opciones nuevas, apagadas por defecto y activas en estos enemigos y el carcelero:
  - `attack_ignores_hits`: los golpes quitan vida durante su ataque, sin interrumpirlo;
  - `stun_immunity_time` (1 s aquí): tras aturdirse, los golpes no lo aturden ni lo empujan durante ese tiempo, contado desde que termina el aturdimiento.
- La rata subió a 5 puños a pedido, tras jugarlo: con menos moría muy pronto. Machacando sin esquivar muerde dos veces.
- Todos quitan 0.75, también el carcelero, que se distingue por su vida y su lanza.
- Escala 1 en todos. El arte está en `assets_prueba/esqueleto_lanza/` y `assets_prueba/monster_creatures_2/`, cada uno con su `ORIGEN.txt`.
- Las hojas del Skeleton tienen cuadros de ancho distinto. `esqueleto_lanza.png` las une en celdas de 80x40 con el cuerpo al centro.

## 4. La espada oxidada

- `escenas/objetos/espada_oxidada.tscn` hereda de `espada_recuperable.tscn`: la misma espada, teñida de óxido, con "E - TOMAR ESPADA OXIDADA".
- `sword_recovery.gd` exporta el aviso del HUD (`notice_title`, `notice_text`); aquí dice "Espada oxidada / No es gran cosa... pero corta.".
- Está colocada a mano en la cámara del preso, junto a `PresoMuerto`, el último cuadro de la muerte del Skeleton como cadáver provisional.
- `requires_guard_defeated = false`: `sword_recovery.gd` lo pasa a `GameManager.recover_sword(player, requires_guard)`, porque aquí no hay que vencer a nadie. Por defecto sigue pidiendo el guardia.
- `has_sword = true` y el Player pasa a tener espada.
- **Guardado:** `_restore_game_state` devuelve la espada si viene de la armería o si la misión está completa. No hay campos nuevos ni cambia `SAVE_FORMAT_VERSION`.

## 5. La armería del castillo

- Se queda como estaba, pero con la espada oxidada ya no se activa, porque pide `not has_sword`.
- La idea es que la espada y la armadura buenas se consigan más adelante. Cuando se muevan, hará falta un nivel de arma (por ejemplo `weapon_tier`) con daño propio.

## Verificación

- Arrancan sin errores nuevos el menú, la cinemática, la prisión, el calabozo, el castillo y Mundo 1.
- Prueba sin ventana, desde una partida nueva:
  - sin espada: unos 130 de velocidad, 51 px de salto y 1 corazón por un golpe de 0.75;
  - la reja interior y la del conducto no abren sin espada;
  - se baja y se sube por la escalera de entrada, y se sube por la de salida;
  - la espada se recoge sin vencer a nadie y se conserva al guardar y restaurar;
  - con espada, un golpe de 0.75 quita 0.75 y las dos rejas se abren;
  - el carcelero cae con 8 golpes de 0.5 y suelta la llave;
  - la reja de la salida sigue cerrada sin llave y abre con ella;
  - la llave reaparece al recargar si no se recogió.

## Pendiente

- Arte de la espada oxidada (hoy, espada teñida).
- Arte del preso muerto (hoy, cadáver de Skeleton).
- Jugarlo con ventana y ajustar velocidad, salto, vida y ataque de los enemigos del calabozo, y ver si el conducto se encuentra sin ayuda.
- Jugar la prisión con la velocidad y el salto reducidos.
- Confirmar la licencia de los paquetes Skeleton y Monsters Creatures Fantasy 2.
- Decidir dónde va la espada buena con armadura y qué da de más.
