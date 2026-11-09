# UnderKingdom

Plataformero de acción 2D en Godot 4.7 (GDScript), pixel art. Repo de Armando Che; colaboradores trabajan en ramas propias. Responder en español.

## Mapas en uso (leer primero)

- **La estructura del juego a partir de ahora son los niveles con tiles (`escenas/mapas/tiles_*`).** Todo trabajo nuevo de mapas, progresión, jefes y ruta va ahí.
- **Mapas aparte, por el momento sin uso:** `mundo_1.tscn` y los demás mapas hechos a mano (`primer_boss_mundo_1`, `mundo_2`, `mundo_3`, `ruina`, `profundidades`, `jefe_final`, ejemplos y arenas de prueba).
  - No se borran ni se modifican salvo que se pida.
  - No se toman como referencia de diseño.
  - No se conectan con la ruta de tiles.
- **Lore y diseño: el juego se recorre bajando**, de la tierra a los abismos y al infierno, al estilo de Terraria.
  - Cada mundo es un mapa para explorar al estilo Hollow Knight: zonas, atajos, checkpoints, enemigos repartidos y una sala de jefe.
  - La sala del jefe se cierra al entrar. Hoy, al vencerlo cae una llave, y esa llave abre la puerta al mundo siguiente, que está en la parte más profunda del mapa. En el macro mapa (abajo) la llave solo abre algunas transiciones; las demás se abren con una habilidad, sellos, un puzle o un derrumbe.
  - Los enemigos cambian conforme se baja: personas y bichos comunes arriba, criaturas y esqueletos en medio (el Aprendis, mago de fuego con calavera, cuenta como esqueleto), demonios al fondo. Cada mundo usa solo los de su profundidad (tabla en `docs/P33_ENEMIGOS_POR_PROFUNDIDAD.md`); no mezclar enemigos de otro nivel. Excepción: el infierno, la prueba final, mezcla los más duros de todas las profundidades (P46).
- **Cinemática inicial:** "Nueva partida" empieza en `escenas/cinematica/cinematica_inicial.tscn` (ilustraciones de `assets/cinematica/` sobre una pista de narración), que sale a la prisión. Tiempos de cada imagen en `slides`, en su `.gd`; detalle en `docs/P41_CINEMATICA_INICIAL.md`.
- **Prólogo (de la v4 de Armando):** tras la cinemática inicial sigue la de la prisión (`prologo_prision/camara_sellado_alma.tscn`), que sale al calabozo con tiles.
- **Calabozo:** tramo entre la prisión y el castillo (`tiles_calabozo_combate.tscn`, Player `prisn.tscn` por la opción `jugador:` del constructor). Tras un tramo lineal con dos ratas, el prisionero avisa de que son demasiados y señala un hueco. Una reja corta la sala y obliga a bajar por ese conducto, una zona honda con ratas y murciélagos que acaba en el cadáver de un preso con la espada oxidada y su atuendo (`escenas/objetos/espada_oxidada.tscn`). Con ella se vence al carcelero (`scripts/combat/jailer_key_drop.gd`), que suelta la llave de la salida. Con la espada, la armería del castillo ya no se activa. Sin espada se corre y se salta menos y cada golpe quita 0.25 más (`unarmed_*` en `player.gd`). Detalle en `docs/P42_CALABOZO_INICIAL.md`. Desde la 0.04.049 el protagonista empieza sin espada (`escenas/prisn.tscn`: camina, salta y da puñetazos, no rueda). En esa versión la recuperaba venciendo al `Guardia6` del castillo (`scripts/items/prison_guard_mission.gd`, `sword_recovery.gd`; estado `has_sword` / `sword_*` en `GameManager`). El calabozo y el castillo hechos a mano de `escenas/mapas/prologo/` se borraron en esa versión. Detalle en `docs/P39_INTEGRACION_V4.md`.
- **Primer mundo, el castillo:** se juega desde `tiles_castillo_combate.tscn`, que hereda de `tiles_castillo.tscn`. Tileset propio `castillo` (ladrillo morado de Raou), enemigo Guardia (`G`) y jefe el Rey Caído (`escenas/jefes/rey_caido.tscn`) en la sala del trono, con las mismas coordenadas que la sala del cementerio. Da la reliquia de rodar. Detalle en `docs/P40_CASTILLO_CON_TILES.md`.
- **Segundo mundo, el cementerio:** se juega desde `tiles_cementerio_combate.tscn`, que hereda de la escena generada `tiles_cementerio.tscn`.
  - Trazado y coordenadas: `mapas_texto/tiles_cementerio.txt` y `docs/CHANGELOG_0.04.047.md`, sección "Cementerio con tiles".
  - Es el modelo para los mundos siguientes.
- **Tercer mundo, las minas:** se juega desde `tiles_mineria_combate.tscn`, que hereda de `tiles_mineria.tscn`. Su jefe es el Caballero de la Reina (`escenas/jefes/caballero_reina.tscn`). Trazado en `mapas_texto/tiles_mineria.txt` y en el changelog, sección "Minas con tiles".
- **Cuarto mundo, la mazmorra:** se juega desde `tiles_mazmorra_combate.tscn`, que hereda de `tiles_mazmorra.tscn`. Su jefa es la Reina (`escenas/jefes/reina_jefe.tscn`), en la cámara del fondo a la derecha. Sigue siendo un calco: no baja como los primeros. Detalle en `docs/P34_ENEMIGOS_DE_LOS_PAQUETES.md`.
- **Mundos 5 a 7:** la ruina (Guardián de hielo, `escenas/jefes/guardian_hielo.tscn`), las profundidades (Demon Slime, `demon_slime_jefe.tscn`) y el infierno (Cthulhu, `cthulhu_jefe.tscn`, jefe final sin llave) se juegan desde su escena `_combate`. Los tres jefes usan `scripts/bosses/simple_boss.gd`. Siguen siendo calcos: la sala es una cámara que ya existía, cerrada con trampillas y rejas, sin tocar colisiones. Detalle en `docs/P34_ENEMIGOS_DE_LOS_PAQUETES.md`.
- **Ruta actual:** cinemática inicial → prisión → `tiles_calabozo` → `tiles_castillo` → `tiles_cementerio` → `tiles_mineria` → `tiles_mazmorra` → `tiles_ruina` → `tiles_profundidades` → `tiles_jefe`, cada uno por su escena `_combate`. Desde la mazmorra, los mapas todavía no siguen la idea de bajar (ver `TASK.md`). `tiles_casa` quedó fuera de la ruta.
- **Macro mapa, el plan para rehacer las zonas (`docs/P46_MACRO_MAPA.md`):** es la idea con la que se van a crear los mapas reales del juego, zona por zona.
  - **Es el objetivo, no el estado actual.** Lo descrito arriba ("Ruta actual" y cada mundo) es lo que hay hoy. Una zona solo cambia al rehacerla, y entonces sigue el plan: posición, lado de entrada y salida, cómo se abre la salida y atajos.
  - En resumen: castillo y cementerio en la superficie, uno al lado del otro; el cementerio baja a su cripta, la cripta a las minas, las minas siguen de lado a la mazmorra, y desde ahí se baja a la ruina, las profundidades y el infierno.
  - Salidas: `[L1]` llave del carcelero, `[H2]` rodar bajo la reja del trono, `[S3]` tres tumbas sello del cementerio (la última la guarda el Capitán), `[L4]` llave del Caballero, `[!5]` derrumbe tras la Reina, `[P6]` derretir el hielo con la llama eterna (antorcha que se encuentra en la ruina), `[S7]` altares más el Demon Slime. Atajos `:B:` a `:F:`, que se abren desde abajo.
  - Decidido (sección 6 de P46): el castillo deja la llave `castillo_rey` y sale solo rodando por `[H2]`; el Capitán deja su llave y guarda la tercera tumba sello; `[P6]` se abre con la llama eterna. Se aplica al rehacer cada zona.
  - **Forma de trabajo con el plan** (detalle en la sección 9 de P46):
    - Claude dibuja el ASCII de cada zona por separado, a escala real (un carácter = una pieza de 16 px), con las letras del constructor. Lo guarda en `mapas_texto/macro/zonas/<zona>.txt`.
    - Con ese ASCII aprobado se genera el nivel real, igual que el castillo y el cementerio: constructor y escena `_combate`. Al generarlo, el archivo pasa a ser `mapas_texto/tiles_<zona>.txt`, y su ruta se cambia en `zonas.txt`.
    - No generar el nivel de una zona sin su ASCII, ni dibujar una zona sin que se pida.
  - **Progreso del personaje** (sección 10 de P46): empieza desnudo (E0) y encuentra atuendos con su arma al bajar. E1 son los harapos con la espada oxidada (calabozo); E2 el soldado (castillo), E3 el caballero de la cripta con la Agilidad (cementerio) y E4 el abrigo (ruina), los tres opcionales; E5 el Fire Knight (profundidades), la versión final.
    - **Siempre que se trabaje en una zona** (ASCII, nivel, enemigos, jefe, dificultad), mirar su fila en la tabla "Desbloqueos por zona": con qué llega el jugador, qué se consigue allí (colocarlo en el ASCII) y qué pide su salida.
    - Un reto obligatorio solo puede pedir lo que el jugador tiene al llegar. Nunca pide un atuendo opcional ni una mejora de la tienda.
    - El arte de los atuendos se hace con IA, como los harapos, siguiendo la receta de esa sección.
    - Si cambia un desbloqueo (un jefe da otra habilidad, un atuendo cambia de sitio), actualizar esa tabla.
  - **Conexiones entre zonas:** la fuente de verdad es `mapas_texto/macro/conexiones.txt` (lado, posición y ancho de cada apertura). La posición de cada zona en el mundo está en `mapas_texto/macro/zonas.txt`.
    - Antes de dibujar o cambiar el ASCII de una zona, leer las dos tablas. Las aperturas hacia zonas ya hechas se copian tal cual; las nuevas se apuntan primero en la tabla.
    - Toda apertura del borde de una zona tiene que estar en la tabla.
    - Al terminar, correr `python3 herramientas/macro_mapa/verificar_mundo.py` (con `--unir <archivo>` saca el mapa del mundo unido). Una zona no se da por hecha con errores.
  - Si un cambio se aparta del plan, actualizar primero el documento y su dibujo (`herramientas/macro_mapa/macro_mapa.py`). El avance zona por zona se marca en `TASK.md`, "Macro mapa".
- **Zona de pruebas (`escenas/mapas/zona_pruebas_combate.tscn`):** aquí se prueba siempre todo sprite, animación o enemigo nuevo antes de llevarlo a un mapa de la ruta.
  - Abrir esa escena y pulsar F6. Hereda de `zona_pruebas.tscn`, generada desde `mapas_texto/zona_pruebas.txt`.
  - Lo que se añada para probar (un enemigo sin letra, un sprite suelto) va en la `_combate`, en `Enemigos` u `Objetos`; un enemigo con letra va en el `.txt`.
  - El Player es `prisn.tscn` y sale sin espada. Con espada: Modo dev (tecla º), "Dar espada". Para volver a sin espada, reiniciar con F6. Teclas de prueba: R reaparecer, H daño de ¼, J daño de 1, K morir.
  - No forma parte de la ruta y nada lleva a ella: no tiene salidas. La regla de enemigos por profundidad no aplica aquí.
  - Detalle en `docs/P43_ZONA_DE_PRUEBAS.md`.
- **Cómo se monta un mundo:**
  - El trazado se dibuja en el PNG y la escena base la genera el constructor; no se edita a mano.
  - Jefe, puertas y llave van en una escena que hereda de la base. Así se puede regenerar sin perderlos.
  - Piezas a reutilizar:
    - `scripts/combat/boss_arena.gd`: sala de jefe, con `Puertas`, `Atajos`, `PuntosJefe` y `PuntoLlave`;
    - `scripts/environment/locked_door.gd`: puerta con llave; con `require_interact` se abre con E, y `open_effect` (`CANDLES`, `MELT`) y `piece_tint` cambian su dibujo (velas, hielo; P57);
    - `scripts/environment/arena_barrier.gd`: puertas y trampillas; con `open_on_encounter`, se abre cuando `GameManager` marca ese encuentro, o empieza abierta si ya estaba marcado (P49);
    - `scripts/environment/roll_gate.gd`: reja baja que solo se pasa rodando (hereda de `arena_barrier.gd`; se pone en la escena `_combate` con la colisión y las piezas; P52);
    - `scripts/environment/encounter_visibility.gd`: componente hijo que muestra u oculta su nodo según `show_when_encounter` / `hide_when_encounter` (sin colisión ni proceso mientras está oculto; P53);
    - `scripts/combat/wave_arena.gd`: arena cerrada con oleadas (coliseo y salón del infierno, coliseo de ceniza). Como `boss_arena.gd` (`Activador`, `Puertas`, `Atajos`, `UI/Aviso`) más `Oleadas/<n>/*` con los enemigos colocados, fuera del árbol hasta su oleada; 1.5 s entre oleadas (`wave_delay`), y al vencer la última abre y marca `encounter_id`. Al morir se reinicia entera (P67);
    - `escenas/objetos/palanca.tscn`: palanca que se tira con E y marca su `encounter_id` (`lever.gd`; P49);
    - `escenas/objetos/objeto_lore.tscn`: objeto que se lee con E y abre un diálogo JSON (acta, diario, restos); marca `lore_<lore_id>` en `completed_encounters` y se puede releer (`lore_object.gd`, hereda de `npc.gd`; P50);
    - `escenas/items/mejora_encontrada.tscn`: mejora que se recoge en el mapa y suma a una estadística (empuñadura del alcaide, +0.25 de daño en tajos; amuleto, pociones). Tabla `GameManager.FOUND_UPGRADE_DEFINITIONS`, se guarda como `found_upgrades` y se lee con `get_found_upgrade_bonus(stat)` (`found_upgrade_pickup.gd`; P51);
    - `escenas/objetos/sello.tscn`: sello de un contador (`seal_group`, `seal_id`, `seal_total`; con E o con `listen_encounter`). Al activarse todos los del grupo se abren las barreras con `open_on_seal_group` (`arena_barrier.gd`). Se guarda en `completed_encounters` como `sello:<grupo>:<id>` (`seal.gd`; P55);
    - `escenas/items/fragmento_vida.tscn`: fragmento de vida (`fragment_id` único por partida); 4 dan +1 corazón de vida máxima (tope 6) y llenan la vida. `GameManager.grant_life_fragment`, se guarda como `life_fragments` (`life_fragment_pickup.gd`; P54);
    - `escenas/objetos/rompible_selectivo.tscn`: rompible que solo acepta un tipo de golpe (`accepted_hit`: tajo ascendente con Golpe final, o Ultimate); los demás sacan chispa y "RESISTE EL GOLPE" (`selective_breakable.gd`, hereda de `breakable_object.gd`; P56);
    - `escenas/objetos/pared_agrietada.tscn`: pared falsa que se rompe a golpes y se recuerda (`breakable_object.gd`; raíz `AnimatableBody2D`, porque la AttackHitbox no detecta `StaticBody2D`; P48);
    - `escenas/objetos/ascensor.tscn`: cabina del ascensor minero (`:C:`); una por escena, con E viaja con fundido al spawn de su gemela (`target_scene_path`, `target_spawn_id`, `arrival_spawn_id`) y con `requires_encounter` dice "NO HAY CORRIENTE" hasta que se marque ese encuentro (`mine_elevator.gd`; P60);
    - `escenas/sistemas/fuego_infernal.tscn`: franja de fuego (`width_tiles`, `height_tiles`, origen arriba a la izquierda) que sin la resistencia `infernal_fire` del atuendo E5 quita 0.5 y empuja hacia el lado de entrada, y con E5 no hace nada; no es `burn_zone` (`infernal_fire.gd`; P61);
    - `escenas/jefes/crystal_mauler.tscn`: Crystal Mauler con IA (jefe opcional de la gruta de cristal; `simple_boss.gd`, 16 de vida, tres tajos y `sp_atk` en fase 2; P62). `boss_mina.tscn` sigue siendo el sprite viejo de `mundo_2`;
    - `escenas/items/llama_eterna.tscn`: llama eterna de la ruina; da la llave `antorcha` (`eternal_flame_pickup.gd`, hereda de `ability_pickup.gd`). Con ella una `locked_door` con `require_interact` y `MELT` derrite el hielo de `[P6]`, y `scripts/environment/dark_zone.gd` (rectángulo en piezas, origen arriba a la izquierda) pasa de un halo de 20 px a una luz de 5 piezas en el Player (P65);
    - dash en el aire (`air_dash`, P66): habilidad del Player, no escena. Shift pulsado en el aire (con espada) da 112 px en 0.18 s, sin gravedad ni invulnerabilidad, una vez por salto (`PlayerAction.AIR_DASH`, `air_dash_distance`/`air_dash_time`); se da con `ability_reward` o reliquia (`ability_id` `air_dash`);
    - `scripts/environment/collapse_sequence.gd`: suelo que se hunde y huida del derrumbe (`[!5]`); arranca con `trigger_encounter` (la sala de la Reina), sella `sealed_barriers`, hunde un suelo propio (`floor_width_tiles`) y suelta escombros de 0.5 en los `Marker2D` de `Escombros` hasta entrar en `exit_area_path`; guarda `collapse_id` y `collapse_id_huida` en `completed_encounters` (`falling_rubble.gd`; P64);
    - atuendos en `GameManager` (`OUTFIT_DEFINITIONS`, `outfits_found`, `grant_outfit`, `get_outfit_id()`; rasgos con `get_outfit_*` y `has_outfit_resistance`; P59): el de más nivel es el que se lleva y los rasgos se combinan entre todos los encontrados; su aspecto con espada es un `SpriteFrames` aparte en `OUTFIT_DEFINITIONS.sprite_frames` (`escenas/atuendos/`), con lo que le falte tomado del atuendo anterior (P68);
    - en `GameManager`, las llaves genéricas (`grant_key` / `has_key`) y `completed_encounters`.
  - Los jefes se reutilizan por su `.tscn`. El Capitán va con `counts_as_world1_boss = false`. Si un jefe necesita otros valores o su `BossHealthBar`, se le hace una escena heredada en `escenas/jefes/`, como `caballero_reina.tscn`.
  - Las salidas se cambian en el `.txt` del mapa y, para no regenerar, solo en la línea `target_scene_path` del `.tscn`. Apuntan a la escena `_combate` cuando el mapa la tiene.
  - La llave y el progreso de Mundo 1 (`world1_*`) son del mapa viejo: no usarlos en los mapas nuevos.

## Reglas del proyecto

- Las colisiones sólidas de los mapas que ya se validaron jugando no se redibujan ni se eliminan. Si un cambio las afecta, preguntar antes.
- No tocar los ajustes que quitaron el temblor al caminar salvo que se pida: smoothing de la Camera2D (desactivado, proceso en física), pixel snapping 2D, `floor_snap_length` (4) y `safe_margin` (0.02) del Player.
- La vida se mide en cuartos de corazón: 4 corazones al empezar, 5 con la mejora de vida máxima de la tienda (un solo nivel, P47) y 6 con los 4 fragmentos de vida (P54); 0.25 es el daño mínimo. Toda curación y todo daño van en múltiplos de 0.25.
- Colores de las marcas en los mapas: verde = plataforma one-way, rojo/rosado = kill zone, blanco = burn zone, azul = transición al mapa siguiente, morado = transición al mapa anterior, amarillo = puerta interna.
- Las zonas que dependen de marcas visuales las coloca una persona en el editor o pasa coordenadas; no inferir su posición por la forma o el color de una colisión.
- (Mapa viejo) `PuertaJefeM1Bloqueo`, `PasoPuertaWS` y `OneWayPasoPuertaWS` de Mundo 1 no se mueven ni se modifican (secuencia Capitán → llave → reja).
- Pixel art: filtro nearest, resolución base 480x270 con escalado entero, sprites a escala entera (1 o 2). No usar escalas no enteras ni estirar sprites.
- Texto: lo viste el tema global `escenas/ui/tema_underkingdom.tres` (Pixel Operator 8 y, para títulos, Jacquard 12, en `fuentes/`). Solo tamaños 8 o 16 (Jacquard: 21 o 42); otros deforman la letra. Para cambiar estilo, usar sus variaciones (`Titulo`, `Encabezado`, `TextoTenue`, `BotonMenu`…) en vez de overrides. Detalle en `docs/P37_MENUS_Y_TIPOGRAFIA.md`.

## Estructura

- `escenas/mapas/tiles_*`: los mapas en uso. Cada uno se genera con el constructor y tiene un nodo `SistemasMapa` (MapBounds, spawns, escaleras, checkpoints, transiciones). Los que llevan jefe o puertas tienen además una escena heredada, como `tiles_cementerio_combate.tscn`.
- `escenas/mapas/` (mapas viejos, sin uso por ahora): mundo_1, primer_boss_mundo_1, mundo_2, mundo_3, ruina, profundidades, jefe_final. Cada uno es un PNG de `fondos/` cortado en tiles de 16 px más colisiones dibujadas a mano.
- `escenas/menu/`: menú principal y menú de pausa (autoload `PauseMenu`, `scripts/ui/pause_menu_*.gd`, flecha de selección `scripts/ui/menu_selector.gd`; pestañas de estadísticas, llaves y mejoras compradas con monedas, definidas en `GameManager.UPGRADE_DEFINITIONS`). "Nueva partida" llama a `GameManager.reset_for_new_game()` y crea un perfil en una de las 3 ranuras de `user://saves`: toda variable de progreso nueva se reinicia en `reset_for_new_game` y se guarda en `_make_save_data` / `_restore_game_state` (si cambia el formato, subir `SAVE_FORMAT_VERSION`).
- `escenas/enemigos/`, `escenas/jefes/`, `escenas/player.tscn`, `escenas/sistemas/` (one-way, kill zone, burn zone, climb zone, transición, spawn point), `escenas/items/`, `escenas/ui/`.
- `scripts/`: `player/player.gd`, `combat/enemy_base.gd` (base de todo enemigo con IA), `bosses/captain_boss.gd`, `core/game_manager.gd` (autoload `GameManager`), `ui/` (HUD, barra de jefe, barra de enemigo), `fx/combat_fx.gd`, `transitions/`, `environment/`, `camera/`.
- `docs/`: historial de cada etapa (P1…P30). Es la fuente de verdad de lo decidido y lo pendiente; documentar etapas nuevas con el mismo formato.
- Niveles con tiles: `mapas_texto/<nivel>.txt` (opciones) + `<nivel>.png` (un píxel = una pieza) o mapa de letras, y `herramientas/constructor_mapas/construir_mapa.tscn` genera la escena; guía, colores y letras en `mapas_texto/LEYENDA.md`; cada tileset se define en `herramientas/constructor_mapas/tilesets/<nombre>.gd` (hoy `mazmorra`, CC0 en `assets_prueba/dungeon_platformer/`, `cementerio`, que le suma piezas de Gothicvania Cemetery, y `castillo`, que le suma el muro de ladrillo morado de Raou y decorados de castillo). El constructor deduce la colisión de cada pieza por la opacidad de sus esquinas: un tileset nuevo solo debe usar piezas macizas en los bloques para no cambiar colisiones ya validadas. Nunca sobrescribe mapas hechos a mano.

## Combate (resumen)

- Con espada hay dos tajos que se alternan sin fin en cada pulsación, al estilo de Hollow Knight: `attack` (descendente) y `attack 2` (ascendente), de una misma tira de 6 cuadros. `ATTACK_PROFILES` en `player.gd` define sus ventanas de golpe. Solo se guarda una pulsación y el siguiente tajo sale al acabar el anterior.
- Golpes intermedios de una ráfaga usan `take_continuous_damage_from` (sin empuje ni invulnerabilidad); el último usa `take_damage_from` (empuja).
- Tocar a un enemigo también hace daño: `contact_damage` en `enemy_base.gd` (0.25, jefes 0.5), con `take_contact_damage_from` en el Player. No cuenta si el enemigo ataca o está aturdido, ni si el Player se cubre, rueda o ataca. Detalle en `docs/P44_DANO_POR_CONTACTO.md`.
- Los enemigos deben estar en la capa de colisión 3 (valor 4, `collision_layer = 5`): la AttackHitbox del Player solo detecta esa capa.
- Las habilidades del Player (roll, etapas del combo, ataque aéreo, parry, Ultimate, robo de vida, adrenalina) se desbloquean con `GameManager.unlock_ability` y se consultan con `has_ability`. Solo bloquean en una partida empezada con "Nueva partida"; al abrir un mapa directo, el Player tiene todo. Una habilidad nueva se añade a `ABILITY_DEFINITIONS`. Se dan con una reliquia (`escenas/items/reliquia_habilidad.tscn`) o con `ability_reward` de `boss_arena.gd`. Nada necesario para avanzar se vende en la tienda. Detalle en `docs/P35_DESBLOQUEO_DE_HABILIDADES.md`.
- El tajo descendente repetido no aturde (solo el primero de la cadena empuja) para que machacar no bloquee al enemigo. Ráfaga (`combo_2`) acelera los dos tajos y Golpe final (`combo_3`) hace más fuerte el ascendente; ya no son etapas de combo. Al conectar, `UnderkingdomCombatFX.hit_stop` y `shake()` de la cámara (solo `offset`) dan peso al golpe. Ajustes en la categoría "Impacto" del Player; detalle en `docs/P36_PESO_DEL_GOLPE.md`.

## Validar cambios

- Arranque sin errores: `godot --headless --quit-after 120` desde la raíz del proyecto. Abre el menú principal (`escenas/menu/menu_principal.tscn`), que es la escena principal.
- La cinemática inicial, donde arranca "Nueva partida": `godot --headless res://escenas/cinematica/cinematica_inicial.tscn --quit-after 120`. Al cortarla con audio sonando, Godot avisa de que quedó en uso `narracion_reina.mp3` al salir: viene del cierre forzado, no de la escena.
- La prisión, que va después: `godot --headless res://escenas/mapas/prologo_prision/camara_sellado_alma.tscn --quit-after 120`.
- El castillo: `godot --headless res://escenas/mapas/tiles_castillo_combate.tscn --quit-after 120`.
- El cementerio: `godot --headless res://escenas/mapas/tiles_cementerio_combate.tscn --quit-after 120`.
- La zona de pruebas: `godot --headless res://escenas/mapas/zona_pruebas_combate.tscn --quit-after 120`. Es donde se prueban los sprites y enemigos nuevos; con ventana, F6 en esa escena.
- Mundo 1, el mapa viejo: `godot --headless res://escenas/mapas/mundo_1.tscn --quit-after 120`. Comprobarlo cuando se toquen scripts compartidos (Player, enemigos, GameManager, Capitán).
- Un mapa concreto: `godot --headless res://escenas/mapas/<mapa>.tscn --quit-after 60`.
- Tras crear un script con `class_name` nuevo, correr `godot --headless --import` para actualizar la caché de clases.
- `godot --check-only --script <archivo>` da un falso "Identifier not found: GameManager" en scripts que usan el autoload; no usarlo como prueba.
- Para probar lógica sin ventana: una escena temporal con un script que instancia lo necesario, simula entradas con `Input.parse_input_event` y hace `print`; borrarla al terminar.

## Forma de trabajo

- Un commit por cambio que funcione. No hacer push sin que se pida.
- Al editar un `.tscn`, avisar cuál para que se recargue en el editor sin guardar encima.
- Armando ha pasado versiones en ZIP: nunca extraer una versión encima de la carpeta de trabajo; traerla a una rama aparte y fusionar.
- Aplica siempre Static Typing (var speed: float = 200.0, func take_damage(amount: int) -> void:)
