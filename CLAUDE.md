# UnderKingdom

Plataformero de acción 2D en Godot 4.7 (GDScript), pixel art. Repo de Armando Che; colaboradores trabajan en ramas propias. Responder en español.

## El juego que se construye (leer primero)

- **Diseño: el juego se recorre bajando**, de la tierra a los abismos y al infierno, al estilo de Terraria.
  - Cada mundo es un mapa para explorar al estilo Hollow Knight: zonas, atajos, checkpoints, enemigos repartidos y una sala de jefe que se cierra al entrar.
  - Los enemigos cambian conforme se baja: personas y bichos comunes arriba; criaturas y esqueletos en medio (el Aprendis, mago de fuego con calavera, cuenta como esqueleto); demonios al fondo.
  - Cada mundo usa solo los de su profundidad (tabla en `documentacion/desarrollo/P33_ENEMIGOS_POR_PROFUNDIDAD.md`); no se mezclan con los de otro nivel. Excepción: el infierno, la prueba final, mezcla los más duros de todas las profundidades (P46).
  - Un enemigo no se repite entre zonas: los que ya salieron más arriba se quitan al vestir cada zona (P33, 2026-11-12).
- **Se construye en tres fases** (`TASK.md`, con el estado, las casillas y las plantillas de prompt de cada paso):
  1. **Fase 1, los ASCII:** hecha. Cada zona está dibujada a escala real en `mapas/fuentes/macro/zonas/<zona>.txt`.
  2. **Fase 2, las piezas en Godot:** hecha, salvo el arte de los atuendos E2-E4. Las piezas están en "Cómo se monta una zona", abajo, y cada una tiene su sala en la galería de la zona de pruebas.
  3. **Fase 3, generar cada zona:** en curso. Primero la estructura, en dos partes (generar la base y montar la `_combate`), y se juega. Después se viste con arte y enemigos nuevos (P73).
- **Macro mapa (`documentacion/desarrollo/P46_MACRO_MAPA.md`), el plan de cada zona:** posición, lado de entrada y de salida, cómo se abre la salida y atajos.
  - **El mundo:**
    - castillo y cementerio en la superficie, uno al lado del otro;
    - el cementerio baja a su cripta y la cripta a las minas;
    - las minas siguen de lado a la mazmorra;
    - desde la mazmorra se baja a la ruina, las profundidades y el infierno.
  - **Salidas:**
    - `[L1]` llave del carcelero;
    - `[H2]` rodar bajo la reja del trono;
    - `[S3]` tres tumbas sello del cementerio (la última la guarda el Capitán);
    - `[L4]` llave del Caballero;
    - `[!5]` derrumbe tras la Reina;
    - `[P6]` derretir el hielo con la llama eterna (antorcha que se encuentra en la ruina);
    - `[S7]` altares más el Demon Slime.

    Los atajos `:B:` a `:F:` se abren desde abajo.
  - **Decidido** (sección 6 de P46):
    - el castillo deja la llave `castillo_rey` y sale solo rodando por `[H2]`;
    - el Capitán ya no da llave: guarda la tercera tumba sello y da la Ráfaga;
    - `[P6]` se abre con la llama eterna.
  - **Forma de trabajo** (sección 9 de P46):
    - un ASCII por zona, a escala real (un carácter = una pieza de 16 px), con las letras del constructor;
    - al generarlo pasa a `mapas/fuentes/tng/tiles_<zona>.txt` y su ruta se cambia en `zonas.txt`;
    - no se genera una zona sin su ASCII, ni se dibuja una zona sin que se pida.
  - **Progreso del personaje** (sección 10 de P46). Empieza desnudo (E0) y encuentra atuendos con su arma al bajar:
    - E1: los harapos con la espada oxidada (calabozo);
    - E2: el soldado (castillo), opcional;
    - E3: el caballero de la cripta, con la Agilidad (cementerio), opcional;
    - E4: el abrigo (ruina), opcional;
    - E5: el Fire Knight (profundidades), la versión final.
  - **Siempre que se trabaje en una zona** (ASCII, nivel, enemigos, jefe, dificultad), mirar su fila en la tabla "Desbloqueos por zona": con qué llega el jugador, qué consigue allí y qué pide su salida.
    - Un reto obligatorio solo puede pedir lo que el jugador tiene al llegar. Nunca pide un atuendo opcional ni una mejora de la tienda.
    - Si cambia un desbloqueo, se actualiza esa tabla.
    - El arte de los atuendos se hace con IA, con la receta de esa sección.
  - **Conexiones entre zonas:**
    - la fuente de verdad es `mapas/fuentes/macro/conexiones.txt` (lado, posición y ancho de cada apertura) y la posición de cada zona está en `mapas/fuentes/macro/zonas.txt`;
    - antes de tocar el ASCII de una zona se leen las dos tablas, y toda apertura del borde tiene que estar en ellas;
    - al terminar se corre `python3 herramientas/macro_mapa/verificar_mundo.py` (`--unir <archivo>` saca el mundo unido). Una zona no se da por hecha con errores.
  - Si un cambio se aparta del plan, primero se actualizan el documento y su dibujo (`herramientas/macro_mapa/macro_mapa.py`).
- **Lo que no se rehace:**
  - "Nueva partida" empieza en la cinemática inicial (`narrativa/cinematicas/cinematica_inicial.tscn`, P41).
  - Sigue la cinemática de la prisión (`mapas/tog/prologo_prision/camara_sellado_alma.tscn`), que sale al calabozo.
  - El protagonista empieza sin espada: `personajes/jugador/prisn.tscn`, que se pone con la opción `jugador:` del constructor. Sin espada corre y salta menos y recibe 0.25 más por golpe (`unarmed_*` en `player.gd`). La espada oxidada (`objetos/entorno/espada_oxidada.tscn`) da los harapos y la espada.
- **El juego anterior (v1)**, apartado en `archivo/` desde P72 (`archivo/README.md`):
  - La ruta activa usa los niveles de Fase 3. Los niveles de v1 están en `mapas/tng/historicos/tiles_v1/`. No se toman como referencia ni se arreglan.
  - Al generar una zona se siguen los pasos de "Al generar cada zona, además" de `TASK.md`: salidas que llegan desde zonas viejas, `GameManager.CASTLE_SCENE_PATH` / `CEMETERY_SCENE_PATH` y `debug_slide_collisions` de `player.gd`.
  - La clave de guardado `"res://escenas/mapas/tiles_castillo.tscn|PuertaArmeria"` es un id, no una ruta: no se cambia.
  - Los mapas hechos a mano (`mapas/tog/historicos/mapas_viejos/`, entre ellos `mundo_1`) no se usan, no se modifican salvo que se pida y no se conectan con la ruta. Tampoco sus scripts (`world1_*`, `story_hidden_actor`…).
- **Zona de pruebas (`mapas/tog/pruebas/zona_pruebas_combate.tscn`):** aquí se prueba todo sprite, animación, enemigo o pieza nueva antes de llevarlo a una zona (P43).
  - Se abre esa escena y se pulsa F6. Hereda de `zona_pruebas.tscn`, generada desde `mapas/fuentes/tog/pruebas/zona_pruebas.txt`.
  - Un enemigo con letra va en el `.txt`; lo que no tiene letra va en la `_combate`, en `Enemigos` u `Objetos`.
  - **Galería (P71):** se llega bajando por la escalera junto al spawn (las bocas van tapadas con "===" y se bajan con S). Tiene un cuarto por pieza, en el orden de la ruta, con un cartel; el piso D tiene un cuarto por tileset nuevo, con una muestra que el constructor genera con `muestra: si` (P73). Con el D lleno, las piezas de las minas y la mazmorra (enemigos y tileset) van en el piso E, las de la ruina, en el F, y las de las profundidades y las zonas siguientes, en el G, el de abajo. Se genera con `herramientas/zona_pruebas/galeria.py`: una pieza nueva se añade en ese script, no a mano.
  - El Player es `prisn.tscn`, sin espada. Para tenerla: Modo dev (tecla º), "Dar espada"; para quitarla, F6. Teclas: R reaparecer, H daño de ¼, J daño de 1, K morir.
  - No tiene salidas ni forma parte de la ruta. La regla de enemigos por profundidad no aplica aquí.

## Cómo se monta una zona

- La escena base la genera el constructor a partir de `mapas/fuentes/tng/tiles_<zona>.txt`, en `mapas/tng/tiles_<zona>.tscn`. No se edita a mano.
- Jefe, puertas, llaves, objetos y luces van en `tiles_<zona>_combate.tscn`, que hereda de la base. Así se puede regenerar la base sin perderlos.
- Las salidas se cambian en el `.txt` o, para no regenerar, solo en la línea `target_scene_path` del `.tscn`. Si el mapa tiene `_combate`, apuntan a ella.
- **Vestir una zona** (P73): primero se genera y se juega con el arte de hoy. Después, en tres pasos:
  1. ficha aprobada en `documentacion/desarrollo/P73_VESTIR_ZONAS.md`;
  2. piezas probadas en la galería;
  3. cabecera y letras nuevas en el `.txt` y regeneración de la base, comprobando que las celdas sólidas no cambian.
- **Piezas a reutilizar** (el detalle de cada una está en su etapa):
  - `sistemas/combate/boss_arena.gd`: sala de jefe con `Puertas`, `Atajos`, `PuntosJefe`, `PuntoLlave` y `ability_reward`.
  - `sistemas/combate/wave_arena.gd`: arena con oleadas (`Oleadas/<n>/*`); al vencer la última marca `encounter_id`, y al morir el jugador se reinicia (P67).
  - `sistemas/entorno/arena_barrier.gd`: puertas, rejas y trampillas, que se abren con `open_on_encounter` (P49) o con `open_on_seal_group` (P55).
  - `sistemas/entorno/roll_gate.gd`: reja baja que solo se pasa rodando (P52).
  - `sistemas/entorno/locked_door.gd`: puerta con llave; con `require_interact`, `open_effect` (`CANDLES`, `MELT`) y `piece_tint` sirve de velas o de hielo (P57).
  - `sistemas/entorno/encounter_visibility.gd`: muestra u oculta su nodo padre según un encuentro (P53).
  - `sistemas/entorno/collapse_sequence.gd`: suelo que se hunde y huida con escombros, para `[!5]` (P64).
  - `sistemas/entorno/dark_zone.gd`: zona oscura que se ilumina con la llama eterna (P65).
  - `sistemas/entorno/clima_nieve.tscn` (`snow_area.gd`): escarcha, nieve que cae o ventisca en un rectángulo, sin arte y sin pintarse sobre la roca (P73, ruina). `sistemas/entorno/map_ambience.gd`: luz ambiente y luces de los decorados.
  - `objetos/entorno/palanca.tscn`: palanca que marca un `encounter_id` (P49).
  - `objetos/entorno/sello.tscn`: sello de un contador (`seal_group`, `seal_id`, `seal_total`) (P55).
  - `objetos/entorno/objeto_lore.tscn`: lore que se lee con E, con un diálogo en JSON (P50).
  - `objetos/entorno/pared_agrietada.tscn`: pared falsa que se rompe a golpes (P48); `pared_agrietada_profundidades.tscn` la hereda con la roca de las profundidades.
  - `objetos/entorno/rompible_selectivo.tscn`: solo se rompe con el tajo ascendente con Golpe final o con la Ultimate (P56).
  - `objetos/entorno/ascensor.tscn`: ascensor minero (`:C:`), con `requires_encounter` (P60).
  - `objetos/entorno/atuendo.tscn`: atuendo que se recoge (`outfit_id`) (P69); de él hereda la espada oxidada.
  - `objetos/recogibles/mejora_encontrada.tscn`: mejora del mapa (`FOUND_UPGRADE_DEFINITIONS`) (P51, P58).
  - `objetos/recogibles/fragmento_vida.tscn`: fragmento de vida; 4 dan un corazón (P54).
  - `objetos/recogibles/llama_eterna.tscn`: llama eterna, que da la llave `antorcha` (P65).
  - `objetos/recogibles/reliquia_habilidad.tscn`: reliquia que da una habilidad (P35).
  - `sistemas/entorno/fuego_infernal.tscn`: fuego que solo se cruza con E5 (P61).
  - Dash en el aire (`air_dash`, P66): es una habilidad del Player, no una escena. Se da con `ability_reward` o con una reliquia.
  - En `GameManager`:
    - llaves (`grant_key` / `has_key`);
    - `completed_encounters`;
    - habilidades (`unlock_ability` / `has_ability`, `ABILITY_DEFINITIONS`);
    - atuendos (`OUTFIT_DEFINITIONS`, `grant_outfit`; P59, P68).
- **Jefes** (se reutilizan por su `.tscn` en `personajes/jefes/`). Si uno necesita otros valores o su `BossHealthBar`, se le hace una escena heredada ahí, como `caballero_reina.tscn`.

  | Zona | Jefe | Escena |
  |---|---|---|
  | Calabozo | carcelero | `personajes/enemigos/carcelero.tscn` (`jailer_key_drop.gd`) |
  | Castillo | Rey Caído | `rey_caido.tscn` |
  | Cementerio | Capitán | `capitan.tscn`, con `counts_as_world1_boss = false` |
  | Minas | Caballero de la Reina | `caballero_reina.tscn` |
  | Minas (gruta de cristal) | Crystal Mauler | `crystal_mauler.tscn` |
  | Mazmorra | Reina | `reina_jefe.tscn` |
  | Ruina | Guardián de hielo | `guardian_hielo.tscn` |
  | Profundidades | Demon Slime | `demon_slime_jefe.tscn` |
  | Profundidades (altares) | Pesadilla de ceniza, Diablillo mayor, Bestia infernal mayor | `pesadilla_ceniza.tscn`, `diablillo_mayor.tscn`, `bestia_mayor.tscn` (heredan de sus enemigos) |
  | Infierno | Cthulhu | `cthulhu_jefe.tscn` |

  Scripts:
  - el Capitán usa `personajes/jefes/captain_boss.gd`;
  - la Reina, `queen_boss.gd`;
  - el Rey, el Mauler, el Guardián, el Demon Slime y Cthulhu, `simple_boss.gd`.

## Reglas del proyecto

- Las colisiones sólidas de las zonas que ya se validaron jugando no se redibujan ni se eliminan. Si un cambio las afecta, hay que preguntar antes.
- No tocar los ajustes que quitaron el temblor al caminar, salvo que se pida:
  - smoothing de la Camera2D desactivado, con proceso en física;
  - pixel snapping 2D;
  - `floor_snap_length` (4) y `safe_margin` (0.02) del Player.
- La vida se mide en cuartos de corazón; 0.25 es el daño mínimo, y todo daño y toda curación van en múltiplos de 0.25.
  - 4 corazones al empezar;
  - 5 con la mejora de vida máxima de la tienda (un solo nivel, P47);
  - 6 con los 4 fragmentos de vida (P54).
- Colores de las marcas en los mapas:
  - verde: plataforma one-way;
  - rojo o rosado: kill zone;
  - blanco: burn zone;
  - azul: transición al mapa siguiente;
  - morado: transición al mapa anterior;
  - amarillo: puerta interna.
- Las zonas que dependen de marcas visuales las coloca una persona en el editor, o pasa sus coordenadas. No inferir su posición por la forma o el color de una colisión.
- Pixel art: filtro nearest y resolución base 480x270 con escalado entero. Sprites a escala entera (1 o 2), sin escalas no enteras ni sprites estirados.
- Texto: lo viste el tema global `interfaces/tema_underkingdom.tres`, con Pixel Operator 8 y, para títulos, Jacquard 12 (en `graficos/tipografias/`).
  - Solo tamaños 8 o 16 (Jacquard: 21 o 42); otros deforman la letra.
  - Para cambiar el estilo se usan sus variaciones (`Titulo`, `Encabezado`, `TextoTenue`, `BotonMenu`…), no overrides.
  - Detalle en `documentacion/desarrollo/P37_MENUS_Y_TIPOGRAFIA.md`.

## Estructura

La estructura vigente y el inventario de traslados están en [ORGANIZACION.md](ORGANIZACION.md).
El historial de la organización anterior está en [P72](documentacion/desarrollo/P72_ORGANIZACION_REPO.md).

- `mapas/tng/` contiene las bases generadas `tiles_<zona>.tscn` y sus escenas `_combate`.
- `mapas/tog/` contiene el prólogo, los fondos de escena y la zona de pruebas. Las versiones históricas están bajo `historicos/` en cada familia.
- `mapas/fuentes/` contiene los ASCII en `tng/` y `tog/`, la paleta, `LEYENDA.md` y las tablas `macro/zonas.txt` y `macro/conexiones.txt`.
- `herramientas/constructor_mapas/` contiene el constructor, las definiciones de baldosas y los generadores de atlas gráficos. La colisión de cada pieza se deduce de la opacidad de sus esquinas.
- `herramientas/macro_mapa/`, `herramientas/fotogramas/` y `herramientas/zona_pruebas/` contienen el verificador, las herramientas de animación y el generador de la galería.
- `personajes/` contiene las escenas y el código del jugador, enemigos, jefes y NPC. `objetos/` contiene el equipo, los recogibles y las piezas interactivas del entorno.
- `sistemas/` contiene el núcleo, cámara, combate, efectos, entorno, proyectiles y transiciones. Cada nivel conserva su nodo `SistemasMapa` con MapBounds, spawns, escaleras, checkpoints y transiciones.
- `interfaces/` contiene los menús, el HUD, las barras, la caja de diálogo y el tema. `PauseMenu` coordina las pestañas de estadísticas, llaves, mejoras y equipo.
- `narrativa/` contiene las cinemáticas y los JSON de diálogos y lore. `audio/narracion/` contiene la voz de la introducción.
- `graficos/` contiene arte del protagonista y del mundo, texturas de interfaz, tipografías y paquetes de terceros. Conserva las licencias y el `ORIGEN.txt` de cada paquete.
- `archivo/` conserva el soporte de los mapas históricos. `rd/` contiene los recursos de reserva sin referencia de ejecución comprobada y conserva su `.gdignore`.
- `documentacion/desarrollo/` contiene una etapa por archivo. `documentacion/historial/` conserva los sistemas reemplazados, los changelogs y las decisiones de Fase 2.

«Nueva partida» reinicia el progreso con `GameManager.reset_for_new_game()` y crea un perfil en una de las tres ranuras de `user://saves`. Toda variable nueva de progreso se reinicia allí y se guarda en `_make_save_data` y `_restore_game_state`. Si cambia el formato, se sube `SAVE_FORMAT_VERSION`.

## Combate (resumen)

- Con espada hay dos tajos que se alternan sin fin, uno por pulsación, al estilo de Hollow Knight: `attack` (descendente) y `attack 2` (ascendente).
  - Salen de una misma tira de 6 cuadros, y `ATTACK_PROFILES` en `player.gd` define sus ventanas de golpe.
  - Solo se guarda una pulsación: el siguiente tajo sale al acabar el anterior.
- Los golpes intermedios de una ráfaga usan `take_continuous_damage_from`, sin empuje ni invulnerabilidad. El último usa `take_damage_from`, que empuja.
- Tocar a un enemigo también hace daño: `contact_damage` en `enemy_base.gd` (0.25; jefes, 0.5), que el Player recibe con `take_contact_damage_from` (P44).
  - No cuenta si el enemigo ataca o está aturdido.
  - Tampoco si el Player se cubre, rueda o ataca.
- Los enemigos van en la capa de colisión 3 (valor 4, `collision_layer = 5`): la AttackHitbox del Player solo detecta esa capa.
- Las habilidades del Player se desbloquean con `GameManager.unlock_ability` y se consultan con `has_ability` (P35). Son rodar, las etapas del combo, el ataque aéreo, el parry, la Ultimate, el robo de vida, la adrenalina y el dash en el aire.
  - Solo bloquean en una partida empezada con "Nueva partida"; al abrir un mapa directo, el Player las tiene todas.
  - Una habilidad nueva se añade a `ABILITY_DEFINITIONS`.
  - Nada necesario para avanzar se vende en la tienda.
- El tajo descendente repetido no aturde (solo empuja el primero de la cadena), para que machacar no bloquee al enemigo.
- Ráfaga (`combo_2`) acelera los dos tajos y Golpe final (`combo_3`) hace más fuerte el ascendente.
- Al conectar un golpe, `UnderkingdomCombatFX.hit_stop` y `shake()` de la cámara (solo mueve el `offset`) le dan peso. Sus ajustes están en la categoría "Impacto" del Player (P36).

## Validar cambios

- Arranque sin errores: `godot --headless --quit-after 120` desde la raíz del proyecto. Abre el menú principal, que es la escena principal.
- La cinemática inicial: `godot --headless res://narrativa/cinematicas/cinematica_inicial.tscn --quit-after 120`. El aviso de que quedó en uso `narracion_reina.mp3` al salir viene del cierre forzado, no de la escena.
- La prisión: `godot --headless res://mapas/tog/prologo_prision/camara_sellado_alma.tscn --quit-after 120`.
- Una zona de la Fase 3: `godot --headless res://mapas/tng/tiles_<zona>_combate.tscn --quit-after 120`.
- La zona de pruebas: `godot --headless res://mapas/tog/pruebas/zona_pruebas_combate.tscn --quit-after 120`.
- Al tocar un script compartido (Player, enemigos, `GameManager`, jefes), se arrancan la zona de pruebas y las zonas ya generadas en la Fase 3.
- Al tocar un ASCII, una conexión o un `tiles_<zona>.txt`: `python3 herramientas/macro_mapa/verificar_mundo.py`, con 0 errores. Después se regenera el Atlas con `datos_atlas.py`.
- Tras crear un script con `class_name` nuevo, se corre `godot --headless --import` para actualizar la caché de clases.
- `godot --check-only --script <archivo>` da un falso "Identifier not found: GameManager" en los scripts que usan el autoload: no sirve como prueba.
- Para probar lógica sin ventana: una escena temporal con un script que instancia lo necesario, simula entradas con `Input.parse_input_event` y hace `print`. Se borra al terminar.

## Forma de trabajo

- Un commit por cambio que funcione. No hacer push sin que se pida.
- Al editar un `.tscn`, avisar cuál, para que se recargue en el editor sin guardar encima.
- Si llega una versión en ZIP (Armando dejó de mandarlas el 2026-11-08), no se extrae encima de la carpeta de trabajo: se trae a una rama aparte y se fusiona.
- Siempre con static typing (`var speed: float = 200.0`, `func take_damage(amount: int) -> void:`).
