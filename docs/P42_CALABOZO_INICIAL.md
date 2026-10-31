# P42 - Calabozo inicial: a puño hasta la espada oxidada

- El protagonista sale de la prisión desnudo y sin arma. Antes llegaba así al castillo y la espada solo se recuperaba en la armería.
- Ahora, entre la prisión y el castillo, está el **calabozo**:
  - un primer tramo lineal y tranquilo, con dos ratas, enseña a pelear a puño;
  - al pasar a la zona dura, el prisionero dice que son demasiados y señala el hueco del suelo;
  - desnudo es peligroso pelear, y conviene esquivar;
  - la reja interior corta el paso y obliga a ir por el conducto;
  - en el conducto está el cadáver de otro preso con la primera arma, una **espada oxidada**;
  - con ella se vence al carcelero, que suelta la llave de la salida.
- Ruta: cinemática inicial → prisión → **calabozo** → castillo → cementerio…

## 1. El mapa

- `mapas_texto/tiles_calabozo.txt` (mapa de letras, 136 x 24 piezas, tileset `castillo`) genera `escenas/mapas/tiles_calabozo.tscn`. Se juega desde `tiles_calabozo_combate.tscn`.
- Tramos:
  1. Tramo lineal (x 2-40), con el inicio en (4, 9), dos ratas y checkpoint en (38, 9).
  2. Paso bajo (x 41-42), de 3 piezas de alto, que separa las dos zonas.
  3. Entrada al conducto: escalera en la columna 56, en un hueco de 3 piezas en el suelo, antes de los enemigos.
  4. Pasillo de celdas con enemigos (x 58-73).
  5. Rampa de bajada (x 74-76) y checkpoint en (81, 12).
  6. Sala izquierda (x 77-101), con cofre en (98, 12).
  7. Reja interior en la columna 102, filas 10-12, bajo un muro.
  8. Conducto (filas 17-19, x 54-108), sin enemigos.
  9. Cámara del preso (x 86-92), con la espada y un checkpoint en (90, 19).
  10. Reja del conducto en la columna 94.
  11. Salida del conducto: escalera en la columna 106.
  12. Sala del carcelero (x 103-127).
  13. Reja de la salida en la columna 128, filas 10-12, bajo un muro.
  14. Salida azul en la columna 135, filas 10-12, a `tiles_castillo_combate.tscn#SpawnInicio`.
- El tramo lineal se añadió a la izquierda en el mismo mapa, para caminarlo sin carga. Todo lo colocado a mano se movió 640 px.
- El conducto queda a más de 90 px por debajo de la sala, fuera del alcance vertical de los enemigos de suelo.
- **Escaleras que cruzan un piso:** el hueco es de 3 piezas, `.H.`. Con `=H=` no se baja: el Player mide 20 px, más que la pieza de 16, y las plataformas lo frenan. Al llegar arriba hay que pulsar hacia un lado para salir al suelo.
- Sin espada, el hueco se salta corriendo.
- Los enemigos no caen por los huecos porque tienen `avoid_ledges`.
- Opción nueva del constructor, `jugador:`, para elegir la escena del Player. El calabozo usa `res://escenas/prisn.tscn`, el Player del prólogo. Por defecto sigue `player.tscn`.
- La prisión (`camara_sellado_alma.tscn`) sale ahora al calabozo. Solo cambió su `target_scene_path`.

### Las rejas

Las tres son `locked_door.gd`, a mano en la escena `_combate`.

| Reja | Posición | Se abre con | Para qué |
|---|---|---|---|
| `RejaInterior` | (1640, 184) | espada (`requires_sword`) | corta la sala; armado es un atajo para volver a por los enemigos esquivados |
| `RejaConducto` | (1512, 296) | espada (`requires_sword`) | impide llegar al carcelero sin recoger la espada |
| `RejaSalida` | (2056, 184) | llave `calabozo_salida` | salida al castillo |

### El aviso del prisionero

- `SistemasMapa/Cinematicas/AvisoConducto` es un `cinematic_controller.gd` con activación `ON_VISIBLE`. Enfoca `PuntoConducto`, un `Marker2D` sobre el hueco, y se dispara al quedar a 150 px, unos 755 de x.
- El texto está en `dialogues/calabozo_aviso_conducto.json`. Sale una vez por partida (`cinematic_id = "calabozo_aviso_conducto"`) y es invulnerable mientras dura.
- La descripción del objetivo cambió a "Busca un arma: a puños no llegarás lejos.", porque hablaba de la llave de la armería.
- Sin ventana, `VisibleOnScreenNotifier2D` no se dispara: el aviso solo se puede probar con pantalla.

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
| Rata | `enemigos/rata.tscn` | tramo lineal, x 300 y 500 | 1.25 | 5 | mordisco, 0.75 cada 1.6 s |
| Rata | `enemigos/rata.tscn` | pasillo, x 940 y 1120 | 1.25 | 5 | mordisco, 0.75 cada 1.6 s |
| Murciélago grande | `enemigos/murcielago_grande.tscn` | pasillo, x 1030 | 1 | 4 | embestida (`lunge_enemy.gd`), 0.75 cada 1.8 s |
| Slime | `enemigos/slime.tscn` | pasillo, x 1200 | 0.75 | 3 | escupitajo, 0.75 cada 2 s |
| Rata | `enemigos/rata.tscn` | sala izquierda, x 1380 | 1.25 | 5 | mordisco, 0.75 cada 1.6 s |
| Slime | `enemigos/slime.tscn` | sala izquierda, x 1480 | 0.75 | 3 | escupitajo, 0.75 cada 2 s |

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
  - la llave reaparece al recargar si no se recogió;
  - las ratas no caen al perseguir por el borde del hueco, y el hueco se salta corriendo;
  - las dos escaleras se suben y se bajan.
- Con ventana, el aviso se dispara solo a unos 755 de x y dice sus dos líneas. El Player recupera el control y la cámara.

## Pendiente

- Arte de la espada oxidada (hoy, espada teñida).
- Arte del preso muerto (hoy, cadáver de Skeleton).
- Jugarlo con ventana y ajustar velocidad, salto, vida y ataque de los enemigos del calabozo, y ver si el conducto se encuentra sin ayuda.
- Jugar la prisión con la velocidad y el salto reducidos.
- Confirmar la licencia de los paquetes Skeleton y Monsters Creatures Fantasy 2.
- Decidir dónde va la espada buena con armadura y qué da de más.

## Sprites nuevos con espada

- Lo que se ve al recoger la espada era el Fire Knight de prueba. Se sustituye animación por animación, en el `SpriteFrames` de `escenas/player.tscn`; las que no tienen tira todavía siguen siendo del caballero.
- **Hecho:** `idle` (8 cuadros, 5 fps) y `run` (8 cuadros, 14 fps), en `Elementals_fire_knight_FREE_v1.1/espada/`, con `original_ia.png` al lado, como las tiras del prisionero.
- **Cómo se procesa una tira:** `python3 herramientas/sprites/tira_ia_a_hoja.py original_ia.png hoja.png --cuadros 8 --factor 2`. `--factor` es la altura de la figura en la tira entre 120 (la tira de `idle` mide 238 px). Quita el magenta y su halo, fija los pies entre cuadros, reduce con una paleta común y quita el ruido de color entre cuadros.
- **Animaciones con movimiento** (`run`; también servirá para saltar): se añade `--movimiento`. Alinear por los pies las rompería, así que cada cuadro conserva su altura en la tira y se centra por la cabeza y el torso, para que no se desplace de lado. No se estabiliza el color. El torso de `run` queda a 1 px del de `idle`, y el cambio de una a otra no salta.
- **Reducción:** cada píxel toma un color de la paleta, no un promedio, y los bloques con al menos un 30 % de oscuro toman el oscuro, para que el contorno no se emborrone. Los que apenas cambian de tono entre cuadros toman su color habitual: la primera `idle` cambiaba cerca del 70 % de los píxeles en cada cuadro.
- **Borde:** la silueta se suaviza con un vecindario de 5x5, se quitan los restos sueltos (eslabones de cadena que quedan separados) y su perfil se repinta de 1 px con un color oscuro fijo. Antes la mitad de los píxeles del borde conservaba tinte morado del fondo y el contorno salía dentado. Sacar los píxeles siguiendo la cuadrícula del dibujo (unos 4.17 px en la tira) deja buen borde, pero pierde la espada y el cinturón: no encaja igual en todo el cuadro.
- **Resolución:** las hojas son de 864x384 por cuadro, con el pie en la fila 380 y el centro en la columna 432, y se dibujan a escala 1/3. Así la figura mide 40 px como la caja de colisión y da el detalle del prisionero, que usa hojas grandes a escala 0.18. A 40 px y escala 1 los píxeles medían el triple que los del prisionero y el personaje se veía borroso. Es una excepción a los sprites de escala entera, la misma del prisionero.
- Cada animación con hoja nueva se añade a `ARMED_ANIMATION_SCALES` en `player.gd`; las del caballero siguen a escala 1 y el pie cae en el mismo punto en ambas.
- `prisn.tscn` tiene la colisión en otro sitio que `player.tscn`: `_load_armed_sprite_frames` lleva el sprite armado a los pies de la caja de cada escena.
