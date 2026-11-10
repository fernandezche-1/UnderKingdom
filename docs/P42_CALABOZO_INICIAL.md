# P42 - Calabozo inicial: a puño hasta la espada oxidada

- El protagonista sale de la prisión desnudo y sin arma. Antes llegaba así al castillo y la espada solo se recuperaba en la armería.
- Ahora, entre la prisión y el castillo, está el **calabozo**:
  - un primer tramo lineal y tranquilo, con dos ratas, enseña a pelear a puño;
  - al pasar a la zona dura, el prisionero dice que son demasiados y señala el hueco del suelo;
  - desnudo es peligroso pelear, y conviene esquivar;
  - la reja interior corta el paso y obliga a ir por el conducto;
  - el conducto baja hasta una zona honda con ratas y murciélagos;
  - al fondo está el cadáver de otro preso con la primera arma, una **espada oxidada**, y su atuendo. El prisionero lo comenta;
  - con ella se vence al carcelero, que suelta la llave de la salida.
- Ruta: cinemática inicial → prisión → **calabozo** → castillo → cementerio…

## 1. El mapa

- `archivo/tiles_v1/mapas_texto/tiles_calabozo.txt` (mapa de letras, 136 x 46 piezas, tileset `castillo`) genera `archivo/tiles_v1/escenas/tiles_calabozo.tscn`. Se juega desde `tiles_calabozo_combate.tscn`.
- Tramos:
  1. Tramo lineal (x 2-40), con el inicio en (4, 9), dos ratas y checkpoint en (38, 9).
  2. Paso bajo (x 41-42), de 3 piezas de alto, que separa las dos zonas.
  3. Entrada a la zona honda: escalera en la columna 56, filas 10-37, en un hueco de 3 piezas en el suelo, antes de los enemigos.
  4. Pasillo de celdas con enemigos (x 58-73).
  5. Rampa de bajada (x 74-76) y checkpoint en (81, 12).
  6. Sala izquierda (x 77-101), con cofre en (98, 12).
  7. Reja interior en la columna 102, filas 10-12, bajo un muro.
  8. Cueva de llegada (x 53-70, filas 32-37), con checkpoint en (59, 37), rata y murciélago.
  9. Rampa de bajada (x 71-73).
  10. Sala larga (x 74-89, filas 35-40), con dos ratas, un murciélago y dos plataformas a 48 px del suelo para esquivar.
  11. Paso bajo (x 90-92, filas 38-40).
  12. Cámara del preso (x 93-103), con checkpoint en (94, 40), la espada y el atuendo.
  13. Reja del conducto en la columna 104, filas 38-40.
  14. Salida: escalera en la columna 106, filas 13-40.
  15. Sala del carcelero (x 103-127).
  16. Reja de la salida en la columna 128, filas 10-12, bajo un muro.
  17. Salida azul en la columna 135, filas 10-12, a `tiles_castillo_combate.tscn#SpawnInicio`.
- El tramo lineal se añadió a la izquierda en el mismo mapa, para caminarlo sin carga. Todo lo colocado a mano se movió 640 px.
- **Zona honda:** sustituye al conducto antiguo (filas 17-19, x 54-108, sin enemigos), que quedó relleno. Las filas 0-12 no cambiaron ni un tile. Son unas 18 filas más de escalera (de 160 a 448 px) y unas 47 columnas de recorrido, antes 32.
- Las salas miden 6 piezas de alto o más, como el pasillo de arriba, para saltar a las ratas: el salto sin espada es de 50 px y pide esa altura. Donde se pelea no hay tramos de 3 piezas.
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
| `RejaConducto` | (1672, 632) | espada (`requires_sword`) | impide llegar al carcelero sin recoger la espada |
| `RejaSalida` | (2056, 184) | llave `calabozo_salida` | salida al castillo |

### El aviso del prisionero

- `SistemasMapa/Cinematicas/AvisoConducto` es un `cinematic_controller.gd` con activación `ON_VISIBLE`. Enfoca `PuntoConducto`, un `Marker2D` sobre el hueco, y se dispara al quedar a 150 px, unos 755 de x.
- El texto está en `dialogues/calabozo_aviso_conducto.json`. Sale una vez por partida (`cinematic_id = "calabozo_aviso_conducto"`) y es invulnerable mientras dura.
- La descripción del objetivo cambió a "Busca un arma: a puños no llegarás lejos.", porque hablaba de la llave de la armería.
- Sin ventana, `VisibleOnScreenNotifier2D` no se dispara: el aviso solo se puede probar con pantalla.

### El hallazgo del preso

- `SistemasMapa/Cinematicas/HallazgoPreso` funciona igual que el aviso: enfoca `PuntoPreso` y se dispara al quedar a 80 px, unos 1473 de x, al salir del paso bajo.
- El texto está en `dialogues/calabozo_preso_atuendo.json`.

## 2. Sin espada

Exportados en `player.gd`, categoría "Combate". Valen en todo el juego mientras `has_sword` sea falso, no solo aquí:

| Ajuste | Sin espada | Con espada |
|---|---|---|
| `unarmed_move_speed` | 130 | 170 (`move_speed`); 230 con Agilidad |
| `unarmed_jump_velocity` | -380, unos 50 px | -470, unos 74 px (`jump_velocity`); -560, unos 104 px, con Agilidad |
| `unarmed_extra_damage_taken` | +0.25 a cada golpe | nada |

- Los valores con espada y con Agilidad son de P45.

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
| Rata | `enemigos/rata.tscn` | zona honda, x 1072, 1248 y 1400 | 1.25 | 5 | mordisco, 0.75 cada 1.6 s |
| Murciélago grande | `enemigos/murcielago_grande.tscn` | zona honda, x 1000 y 1336 | 1 | 4 | embestida (`lunge_enemy.gd`), 0.75 cada 1.8 s |

- El puñetazo no llega al ras del suelo: le faltan unos 12 px. Por eso rata y slime tienen 18 px de colisión, aunque se vean bajitos. Si se reduce, dejan de recibir golpes.
- **Sin bloqueo por machacar:** cada golpe cancelaba el ataque y aturdía, y el puñetazo se repite cada 0.5 s, así que nunca llegaban a pegar. `enemy_base.gd` tiene dos opciones nuevas, apagadas por defecto y activas en estos enemigos y el carcelero:
  - `attack_ignores_hits`: los golpes quitan vida durante su ataque, sin interrumpirlo;
  - `stun_immunity_time` (1 s aquí): tras aturdirse, los golpes no lo aturden ni lo empujan durante ese tiempo, contado desde que termina el aturdimiento.
- La rata subió a 5 puños a pedido, tras jugarlo: con menos moría muy pronto. Machacando sin esquivar muerde dos veces.
- Todos quitan 0.75, también el carcelero, que se distingue por su vida y su lanza.
- Escala 1 en todos. El arte está en `assets_prueba/esqueleto_lanza/` y `assets_prueba/monster_creatures_2/`, cada uno con su `ORIGEN.txt`.
- Las hojas del Skeleton tienen cuadros de ancho distinto. `esqueleto_lanza.png` las une en celdas de 80x40 con el cuerpo al centro.

## 4. La espada oxidada

- `escenas/objetos/espada_oxidada.tscn` hereda de `espada_recuperable.tscn`: la misma espada, teñida de óxido, con "E - TOMAR ESPADA OXIDADA". Desde P69 hereda de `escenas/objetos/atuendo.tscn` (`outfit_id` `harapos`), con el mismo dibujo y textos.
- `sword_recovery.gd` exporta el aviso del HUD (`notice_title`, `notice_text`); aquí dice "Espada oxidada / No es gran cosa... pero corta.".
- Está colocada a mano en la cámara del preso, clavada junto a `PresoMuerto`, el último cuadro de la muerte del Skeleton como cadáver provisional.
- **Atuendo:** `assets/personajes/atuendo_preso.png`, una túnica doblada de 22x10 px hecha a mano con la paleta del sprite armado. Es hijo del `Sprite2D` de la espada: se desvanece con ella y desaparece al recogerla. Por eso el tinte de óxido pasó a `self_modulate`. Se recoge todo con una pulsación, y es lo que explica que el Player cambie de aspecto.
- **Distancia a la reja:** `locked_door.gd` abre al entrar en su detector, a 20 px de cada lado. La espada queda a 100 px de la reja: si se recogiera dentro del detector, no abriría hasta salir y volver.
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
- Zona honda, simulada con el Player real, sin enemigos en el recorrido:
  - se baja hasta la cueva y se llega caminando a la reja, que no abre sin espada;
  - el hallazgo se dispara solo con ventana, a unos 1473 de x, y devuelve el control;
  - espada y atuendo se recogen juntos, la reja abre y se sube a la sala del carcelero;
  - desde el pie se sube por la escalera de entrada, con y sin espada, y arriba se sale al suelo por los dos lados.
- Las ratas y murciélagos nuevos patrullan sin caer ni atravesar paredes. La dificultad de la zona honda a puños sigue sin probar jugando.

## Pendiente

- Arte de la espada oxidada (hoy, espada teñida).
- Arte definitivo del atuendo (hoy, túnica provisional).
- Arte del preso muerto (hoy, cadáver de Skeleton).
- Jugarlo con ventana y ajustar velocidad, salto, vida y ataque de los enemigos del calabozo, y ver si el conducto se encuentra sin ayuda.
- Jugar la prisión con la velocidad y el salto reducidos.
- Confirmar la licencia de los paquetes Skeleton y Monsters Creatures Fantasy 2.
- Decidir dónde va la espada buena con armadura y qué da de más.

## Sprites nuevos con espada

- Lo que se ve al recoger la espada era el Fire Knight de prueba. Se sustituye animación por animación, en el `SpriteFrames` de `escenas/player.tscn`; las que no tienen tira todavía siguen siendo del caballero.
- **Hecho:** `idle` (8 cuadros, 5 fps), `run` (8 cuadros, 14 fps) `jump up` / `jump down` (una tira de 6 cuadros) y `attack` / `attack 2` (otra de 6 cuadros) y `air attack` (5 cuadros de una tira de 6) `take hit` (4 cuadros, 8 fps) `death` (6 cuadros, 9 fps) y `escaleras` (6 cuadros, 10 fps), en `Elementals_fire_knight_FREE_v1.1/espada/`, con `original_ia.png` al lado, como las tiras del prisionero.
- **Cómo se procesa una tira:** `python3 herramientas/sprites/tira_ia_a_hoja.py original_ia.png hoja.png --cuadros 8 --factor 2`. `--factor` es la altura de la figura en la tira entre 120 (la tira de `idle` mide 238 px). Quita el magenta y su halo, fija los pies entre cuadros, reduce con una paleta común y quita el ruido de color entre cuadros.
- **Animaciones con movimiento** (`run`, salto): se añade `--movimiento`. Alinear por los pies las rompería, así que cada cuadro conserva su altura en la tira y se centra por la cabeza y el torso, para que no se desplace de lado. No se estabiliza el color. El torso de `run` queda a 1 px del de `idle`, y el cambio de una a otra no salta.
- **Salto:** se procesa con `--cuadros 6 --movimiento --aire --en-suelo 0`. La tira dibuja la subida, pero esa ya la hace la física: con `--aire` todos los cuadros comparten la altura de la cabeza y son las piernas las que suben, y `--en-suelo 0` deja el cuadro agachado sobre sus pies. `jump up` usa los cuadros 0-3 a 12 fps y `jump down` los cuadros 3 y 5 a 6 fps. Ninguna va en bucle: `_update_animation` deja que se queden en su último cuadro hasta cambiar. El cuadro 4 sigue en la hoja, sin usar, porque la IA lo dibujó sin espada y parpadeaba a media caída. La figura mide hasta 44 px, por las piernas estiradas; cabeza y torso miden lo mismo que en `idle`.
- **Ataque:** se procesa con `--cuadros 6 --separar`. La espada estirada invade la casilla vecina, así que cada figura se recorta por su silueta y se alinea por los pies. `attack` usa los cuadros 0-2 (tajo descendente) y `attack 2` los cuadros 3-5 (ascendente), con el golpe en el cuadro central de cada una.
- **Tajos alternos:** cada pulsación da el tajo siguiente, sin fin y desde que se tiene la espada. Cada tajo dura unos 0.32 s (0.26 s con la Ráfaga), bastante más que los 0.2 s pensados al principio: a 0.5 de daño, eso daría 2.5 veces el daño por segundo con el que se ajustaron los enemigos. Ahora son unos 1.6 por segundo, antes 1 sin la Ráfaga. Se ajusta con el `speed` de las animaciones en `player.tscn`.
- **Daño:** los dos tajos hacen 0.5. La Ráfaga multiplica su velocidad por `rafaga_speed_multiplier` (1.2). El Golpe final sube el ascendente a `attack_3_damage` (1.0) con el impacto pesado. Se quitaron `attack 3`, la ráfaga giratoria y su resistencia a interrupciones: ahora cualquier golpe recibido corta el tajo.
- **Alcance:** los tajos usan el área `sword`, ajustada con `sword_hitbox_offset_x` y `sword_hitbox_scale_x`. La hoja llega a unos 24 px del centro y la caja a 45; la del caballero llegaba a 93. Se deja algo por delante de la hoja porque los enemigos se ajustaron a ese alcance. La física ve la caja un tick después de moverla, así que `_reset_attack_hitbox` la coloca antes del cuadro del golpe.
- **Ataque aéreo:** se procesa con `--cuadros 6 --separar --movimiento --fila-pies 361`. En el aire los pies cambian y la espada desvía la media, así que se centra por la mediana de las columnas del torso. `--fila-pies 361` deja la cabeza a la altura de la del salto, y el cambio de una a otra no da brinco. Se usan los cuadros 1-5 a 8 fps (0.35 s con `air_attack_speed_multiplier`), con el golpe en los dos centrales y área `sword`. El cuadro 0 sigue en la hoja, sin usar, porque la tira corta la punta de la espada contra el borde; el cuadro 1 también es preparación y sale completo. Si el ataque acaba en plena subida, `jump up` sigue en su último cuadro y no vuelve a la pose agachada.
- **Recibir golpe:** se procesa con `--cuadros 4 --separar --pies-centrados`. La postura de los pies cambia tanto que buscar su encaje entre cuadros los despegaba 3 px del suelo y los desplazaba de lado, así que se deja el centrado por pies de `--separar`. No va en bucle y dura 0.5 s; antes eran 0.55 s en bucle. Ese tiempo marca el aturdimiento, porque `take_damage` lo toma de la duración de la animación.
- **Muerte:** se procesa con `--cuadros 6 --separar --pies-centrados --escala 5 --factor 8`. La tira mide 205 px de alto y la figura unos 197, menos que las demás: `--escala 5` la amplía sin mezclar colores y `--factor 8` la baja a los 123 px de siempre, con la misma cabeza y torso. La primera tira de 7 cuadros se descartó y esta la sustituye. Si la figura mide otra cosa, se elige el par de enteros que dé unos 120 px. El último cuadro dura 8 veces más para que el total sea 1.44 s, como la muerte anterior: `die()` espera la animación antes de reaparecer, y sin eso apenas se vería el cuerpo tendido. La espada toca el cuerpo en todos los cuadros, así que la limpieza del borde no la quita. No va en bucle.
- **Escalera:** se procesa con `--cuadros 6 --movimiento`. Cada figura cabe en su casilla y la cabeza oscila 7 px de hoja, unos 2 en pantalla. Los 5 fps de la tira vieja eran para 12 cuadros: con 6 van a 10 fps y el ciclo sigue durando 0.6 s frente a 2.4 s de antes, más acorde con los 150 px/s de `climb_speed`. La defensa se deja con el caballero por ahora: no se considera necesaria al empezar el juego.
- **Reducción:** cada píxel toma un color de la paleta, no un promedio, y los bloques con al menos un 30 % de oscuro toman el oscuro, para que el contorno no se emborrone. Los que apenas cambian de tono entre cuadros toman su color habitual: la primera `idle` cambiaba cerca del 70 % de los píxeles en cada cuadro.
- **Borde:** la silueta se suaviza con un vecindario de 5x5, se quitan los restos sueltos (eslabones de cadena que quedan separados) y su perfil se repinta de 1 px con un color oscuro fijo. Antes la mitad de los píxeles del borde conservaba tinte morado del fondo y el contorno salía dentado. Sacar los píxeles siguiendo la cuadrícula del dibujo (unos 4.17 px en la tira) deja buen borde, pero pierde la espada y el cinturón: no encaja igual en todo el cuadro.
- **Resolución:** las hojas son de 864x384 por cuadro, con el pie en la fila 380 y el centro en la columna 432, y se dibujan a escala 1/3. Así la figura mide 40 px como la caja de colisión y da el detalle del prisionero, que usa hojas grandes a escala 0.18. A 40 px y escala 1 los píxeles medían el triple que los del prisionero y el personaje se veía borroso. Es una excepción a los sprites de escala entera, la misma del prisionero.
- Cada animación con hoja nueva se añade a `ARMED_ANIMATION_SCALES` en `player.gd`; las del caballero siguen a escala 1 y el pie cae en el mismo punto en ambas.
- `prisn.tscn` tiene la colisión en otro sitio que `player.tscn`: `_load_armed_sprite_frames` lleva el sprite armado a los pies de la caja de cada escena.
