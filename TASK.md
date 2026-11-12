# Macro mapa: rehacer el mundo desde cero

- **Plan:** `docs/P46_MACRO_MAPA.md` (dibujo, ruta, atajos, decisiones y desbloqueos por zona). La forma de trabajo está en su sección 9.
- **Puertas hacia atrás:** el punto 1 de `mapas_texto/macro/sugerencias_exploracion.txt`, ideas 1 a 9, con sitio, llave, premio, vuelta y coste de cada una.
- **Lo que hay hoy en Godot no cuenta:** los niveles `tiles_*` y sus escenas `_combate` se descartan mientras dure la fase ASCII. No se usan como referencia ni se arreglan; cada zona se genera de nuevo desde su ASCII en la Fase 3. Desde P72 están apartados en `archivo/tiles_v1/` (la ruta aún corre por ahí) y `escenas/mapas/` queda libre para la Fase 3.

Las tres fases:
1. **Fase 1, los ASCII:** cada zona dibujada a escala real, con sus puertas hacia atrás. Hecha (2026-11-08): las puertas y, tras el cierre, el dash y los secretos variados (pasos 8 a 11).
2. **Fase 2, piezas en Godot:** lo que las zonas necesitan y todavía no existe, probado en la zona de pruebas.
3. **Fase 3, generar cada zona:** constructor y escena `_combate`, zona por zona.

---

## Fase 1: puertas hacia atrás en los ASCII

**Un paso está hecho cuando:**
- el ASCII de la zona y sus comentarios de cabecera están al día;
- la simulación de saltos confirma tres cosas:
  - la puerta no se alcanza sin su llave;
  - desde dentro se vuelve;
  - el camino obligatorio no cambia;
- `python3 herramientas/macro_mapa/verificar_mundo.py` da 0 errores;
- están actualizados P46 (estado en la sección 9, tabla de la sección 10), el punto 1 de las sugerencias y esta lista;
- el Atlas está regenerado con `herramientas/macro_mapa/datos_atlas.py` y vuelto a publicar en su misma URL;
- hay un commit, sin push.

**Plantilla de prompt** (cambiar `<zona>`, `<ideas>` y lo que se quiera añadir en `<notas>`):

```
Tarea: Fase 1 de TASK.md, paso de <zona>. Dibuja en su ASCII las puertas
hacia atrás <ideas> del punto 1 de mapas_texto/macro/sugerencias_exploracion.txt.

Antes de dibujar, lee:
- docs/P46_MACRO_MAPA.md, secciones 6, 9 y 10;
- mapas_texto/macro/conexiones.txt y zonas.txt;
- el ASCII de la zona (mapas_texto/macro/zonas/<zona>.txt), sobre todo su
  cabecera de comentarios;
- las ideas por su número en las sugerencias (sitio, llave, premio, vuelta).

Cómo trabajar:
- Enséñame primero un recorte del ASCII con regla de columnas, antes y
  después, y espera a que lo apruebe.
- Respeta las reglas de escaleras de mapas_texto/LEYENDA.md y no rompas
  nada del camino obligatorio.
- No toques escenas ni .tscn: lo que vive en la _combate (puertas, objetos,
  NPC) solo se describe en los comentarios.
- Los textos de lore van como marcador (P46, sección 6).
<notas>

Al terminar, cumple el criterio de "hecho" de la Fase 1 de TASK.md: simulación
de saltos, verificador, P46, sugerencias, TASK.md, Atlas y un commit sin push.
Si algo no cuadra con lo que encuentres en los archivos, dímelo antes de seguir.
Responde en español.
```

**Pasos, en orden** (una sesión cada uno):
- [x] 0. Decisiones de las puertas (P46, sección 6), atajo `:B:` (columnas 100-102 del mundo) y calabozo rehecho como zona tutorial (`mapas_texto/macro/zonas/calabozo.txt`, 100 x 52). Incluye la idea 1, el depósito del alcaide, y la llave del alcaide en la torre de la mazmorra.
- [x] 1. **Castillo:** ideas 2 (aposentos de la Reina, x 62-74, filas 11-18, al este de la capilla) y 3 (el castillo sin hechizo). La 3 no cambia el trazado: los sitios de los soldados y del Capitán, en (68, 62), van en los comentarios.
- [x] 2. **Cementerio:** ideas 4 (estatua de la Reina, cueva x 112-118, filas 12-17, tras el hueco de la columna 111) y 5 (cripta de la primera reina, x 62-74, filas 29-34, con escalera nueva en la columna 68, losa en la fila 35 y puerta de velas en la columna 65).
- [x] 3. **Minas:** idea 6 (gruta de cristal, x 132-147, filas 64-77, tras la boca de la columna 131 y el pasillo del fuego, con checkpoint en (142, 55) y salida por la escalera 139). El Crystal Mauler cabe en 16 x 14 a escala 1, justo.
- [x] 4. **Mazmorra y profundidades:** idea 7 (pozo de los condenados). `:F:` en `conexiones.txt` (mazmorra abajo 88, profundidades arriba 18; túnel de 80 piezas). Trampilla en el suelo de la huida (x 88-90, fila 84) con escalera en la columna 89; pozo x 18-20 con escalera en la 19 hasta la galería, palanca en (23, 25) y, al pie, los restos de los condenados y la página II. En el dibujo del macro mapa la ruina empieza más a la derecha para que `:F:` no la cruce.
- [x] 5. **Ruina:** idea 8 (hielo negro, cámara x 114-130, filas 52-58, al este de la antesala, con la puerta en la columna 113, abierta en el ASCII, y `key_id` `profundidades_ascua`; página III en (117, 58) y fragmento 3/4 en (125, 55), sobre la repisa de la fila 56).
- [x] 6. **Profundidades e infierno:** idea 9 (rey encadenado: jaula x 44-48, filas 16-19, en el techo de la galería de los condenados, con la rejilla de la fila 20 en la `_combate`; el rey, con el sprite del Rey Caído, en (46, 19); con `infierno_animas_liberadas`, su alma en (46, 25) y el fragmento 4/4 en (44, 25)).
  - El santuario ya no nombra al Mauler: va el segundo demonslime.
  - El coliseo del infierno marca `infierno_animas_liberadas` al vencer su última oleada.
  - La sala del Demon Slime lleva el `PuntoLlave` de la ascua (`profundidades_ascua`) hacia (100, 78).
- [x] 7. **Cierre:** tabla "Desbloqueos por zona" de P46 repasada contra los ASCII, verificador con 0 errores, Atlas regenerado y el punto 1 de las sugerencias marcado como hecho.
  - En la mazmorra se quitó el cofre de la torre, en (73, 21): ahí va la llave del alcaide, como ya decía el plan.
  - En la tabla: el calabozo marca su puerta como dibujada, la salida de la ruina pide también al Guardián y las profundidades llegan con la llama eterna.

**Añadido tras el cierre (2026-11-08): el dash y los secretos** (puntos 2 y 4 de las sugerencias). El Guardián da el dash en el aire; los secretos de la Agilidad clonados se reparten en tipos distintos. Una zona por paso, con el recorte de antes y después aprobado y el mismo criterio de "hecho":
- [x] 8. **Ruina:** secreto del dash en el fondo este de la galería baja (pasillo x 131-138, filas 44-47, foso de 6 en x 133-138, cámara x 139-148 con el cofre en (147, 47)).
- [x] 9. **Mazmorra:** el secreto de la torre pasa a ser del dash (pasillo desde la columna 109, filas 18-21, foso de 6 en x 109-114, nicho x 115-117 con el cofre en (117, 21)).
- [x] 10. **Profundidades:** el secreto de la galería pasa a ser una pared falsa (columna 8, filas 23-25; sala x 4-7, filas 21-25, con el cofre en (5, 25)).
- [x] 11. **Minas:** un tercer sitio del dash, al fondo de la galería de los mineros (pasillo x 35-42, filas 53-56, foso de 6 en x 37-42, nicho x 43-45 con el cofre en (45, 56)); junto a `:D:` no cabía. El escalón de la Agilidad se queda.

**Fuera de esta fase:** los puntos 5 (premios: siguen siendo cofres), 6 (monedas), 7 (mapa del jugador) y 8 (NPC que baja) de las sugerencias, y la idea 10, que sigue en reserva.

---

## Fase 2: piezas en Godot

Cada pieza se prueba en la zona de pruebas (`escenas/mapas/zona_pruebas_combate.tscn`) y se documenta en una etapa nueva de `docs/`. Si toca el Player o el `GameManager`, se comprueban también las zonas ya generadas en la Fase 3.

**Una pieza está hecha cuando:**
- funciona en la zona de pruebas, montada en `zona_pruebas_combate.tscn` (o en el `.txt` si lleva letra), con un caso que muestre que cierra y otro que muestre que abre;
- se probó sin ventana con una escena temporal que simula entradas e imprime el resultado, y esa escena se borró;
- arrancan sin errores el juego (`godot --headless --quit-after 120`) y la zona de pruebas, y también las zonas ya generadas en la Fase 3 si se tocó el Player, un enemigo, el `GameManager` o un jefe;
- si guarda estado, se reinicia en `reset_for_new_game`, se guarda en `_make_save_data` / `_restore_game_state` y se sube `SAVE_FORMAT_VERSION`;
- hay una etapa nueva en `docs/` (la siguiente libre es P74), con el formato de las demás, y está al día lo que la nombra: P46 (secciones 5 y 10), CLAUDE.md si cambia una regla o una pieza a reutilizar, y esta lista;
- hay un commit, sin push.

**Plantilla de prompt** (cambiar `<pieza>`, `<zona>` y lo que se quiera añadir en `<notas>`):

```
Tarea: Fase 2 de TASK.md, paso de <zona>: la pieza "<pieza>".

Antes de escribir código, lee:
- CLAUDE.md (reglas del proyecto, combate, validar cambios);
- en TASK.md, la línea de la pieza y el criterio de "hecho" de la Fase 2;
- docs/P46_MACRO_MAPA.md, secciones 5, 6 y 10, y lo que diga de la pieza
  la cabecera del ASCII de cada zona que la usa (mapas_texto/macro/zonas/);
- docs/P43_ZONA_DE_PRUEBAS.md;
- los scripts y escenas que ya hacen algo parecido, para reutilizarlos en
  vez de duplicarlos (por ejemplo locked_door.gd, arena_barrier.gd,
  boss_arena.gd, breakable_object.gd, story_hidden_actor.gd, GameManager).

Cómo trabajar:
- Antes de programar, cuéntame en pocas líneas el plan: qué escena y qué
  script nuevos o qué cambias, qué exporta (nombres y valores por defecto),
  qué guarda, y cómo lo vas a probar. Si hay una decisión de diseño que
  no esté en los documentos (números, comportamiento, arte), pregúntame
  en vez de suponerla. Espera a que lo apruebe.
- Static typing en todo el GDScript. Daño y curación en múltiplos de 0.25.
  Pixel art a escala entera y texto con el tema global (CLAUDE.md).
- Una pieza genérica y configurable desde el editor, que sirva a todas las
  zonas que la piden, no solo a <zona>.
- No toques los mapas de la ruta ni los ASCII: la pieza se monta en las
  zonas en la Fase 3. No toques los ajustes del temblor al caminar.
- Si editas un .tscn, dime cuál para recargarlo en el editor.
- Si falta arte, usa uno provisional que ya exista y apúntalo como
  pendiente.
<notas>

Al terminar, cumple el criterio de "hecho" de la Fase 2 de TASK.md:
prueba en la zona de pruebas, prueba sin ventana, arranques sin errores,
guardado si aplica, etapa en docs/, P46, TASK.md y un commit sin push.
Si algo no cuadra con lo que encuentres en los archivos, dímelo antes de
seguir. Responde en español.
```

**Orden (fijado el 2026-11-08):** por la primera zona de la ruta que pide cada pieza. Así la Fase 3 puede empezar por el calabozo en cuanto estén las suyas, sin esperar a tenerlo todo. Una pieza que sirve a varias zonas va en la primera que la pide; las demás la reutilizan.

**Modo autónomo:** `archivo/herramientas/fase2_auto.sh` hace las piezas una tras otra, con una sesión de Claude Code por pieza y un commit cada una, sin pedir aprobación. Las decisiones de diseño que los documentos no fijaban están en `docs/historial/FASE2_DECISIONES.md`: el script no arranca hasta que ese archivo diga "Estado: APROBADO". Una pieza que no se puede terminar se marca `- [~]` y su motivo va a ese archivo.

**0. Ajuste previo:**
- [x] La tienda vende un solo nivel de vida máxima (`max_level` 1 en `UPGRADE_DEFINITIONS`, 10 monedas; P46, sección 6). La vida máxima ya no se lee del guardado: sale de las mejoras (P47).

**1. Calabozo** (con estas cuatro piezas ya se puede generar en la Fase 3):
- [x] Pared agrietada que se rompe a golpes, también a puños (secretos del calabozo y de las profundidades): `escenas/objetos/pared_agrietada.tscn` (P48). Falta su arte; la caja y la estatua rompibles no reciben golpes (P48, sección 3).
- [x] Palanca y barrera que se abre según `completed_encounters` (atajos `:B:` a `:F:`, compuerta de la mazmorra, rejilla de la jaula del rey encadenado): `escenas/objetos/palanca.tscn` y `open_on_encounter` de `arena_barrier.gd` (P49). Falta el arte de la palanca.
- [x] Objeto de lore que abre un diálogo (`npc.gd` y `dialogue_ui`): el acta del prisionero y, después, el resto del lore de marcador: `escenas/objetos/objeto_lore.tscn` (P50). Falta su arte y los textos definitivos.
- [x] Mejora de +0.25 de daño en todos los tajos (la empuñadura del depósito del alcaide): `escenas/items/mejora_encontrada.tscn` y `FOUND_UPGRADE_DEFINITIONS` de `GameManager` (P51). `SAVE_FORMAT_VERSION` pasa a 3. Falta su arte.

**2. Castillo:**
- [x] Reja baja que solo se pasa rodando (`[H2]` y el pasillo del filo del infierno): `scripts/environment/roll_gate.gd` (P52). Sin escena propia: es una `arena_barrier.gd` con otro script; falta su arte.
- [x] Mostrar u ocultar según un encuentro superado (el castillo sin hechizo y el rey encadenado): `scripts/environment/encounter_visibility.gd`, componente hijo del nodo (P53). `story_hidden_actor.gd` no cambia.
- [x] Fragmento de vida: 4 dan 1 corazón: `escenas/items/fragmento_vida.tscn` y `grant_life_fragment` de `GameManager` (P54). `SAVE_FORMAT_VERSION` pasa a 4. Falta su arte.

**3. Cementerio:**
- [x] Contador de sellos que abre una puerta (`[S3]`, `[S7]`): `escenas/objetos/sello.tscn` y `open_on_seal_group` de `arena_barrier.gd` (P55). No cambia el formato de guardado. Falta su arte.
- [x] Rompible que solo acepta un tipo de golpe: el ascendente con Golpe final (losa de la cripta) o la Ultimate (estatua de la Reina): `escenas/objetos/rompible_selectivo.tscn` (P56). No cambia el guardado. Falta su arte.
- [x] `locked_door` con otro dibujo: velas, y después hielo negro y el hielo de `[P6]`: `locked_door.gd` con `require_interact`, `open_effect` y `piece_tint` (P57). No cambia el guardado. Falta su arte.
- [x] Mejora de +0.25 en pociones (el amuleto de la guardia): fila `amuleto_guardia` de `FOUND_UPGRADE_DEFINITIONS` y `get_potion_heal_amount()` del Player, con `mejora_encontrada.tscn` (P58). No cambia el guardado. Falta su arte.

**4. Minas:**
- [x] Ascensor minero (`:C:`): `escenas/objetos/ascensor.tscn` (P60). Una cabina por escena; sin guardado nuevo. Falta su arte.
- [x] Fuego infernal que solo se pasa con E5 (gruta de cristal, santuario de las profundidades, infierno): `escenas/sistemas/fuego_infernal.tscn` (P61). Sin guardado nuevo. Falta su arte.
- [x] IA del Crystal Mauler: `escenas/jefes/crystal_mauler.tscn`, con `simple_boss.gd` (P62). `boss_mina.tscn` no se toca (lo usa `mundo_2`). Su sala, la gruta de cristal, mide 16 x 14. Sin guardado nuevo.
- [x] La Adrenalina sale de `STARTING_ABILITIES` y la da el Mauler (`ability_reward adrenaline`): `SalaMauler` en la zona de pruebas (P63). `SAVE_FORMAT_VERSION` sigue en 5. Falta el arte de la reliquia (la de siempre).

**5. Mazmorra:**
- [x] Suelo que se hunde y secuencia de derrumbe y huida (`[!5]`): `scripts/environment/collapse_sequence.gd` y `falling_rubble.gd` (P64). Sin guardado nuevo. Falta su arte.

**6. Ruina:**
- [x] Hielo que se derrite con la llama eterna, y la luz de la antorcha (`[P6]`), sobre la `locked_door` con otro dibujo del paso 3: `escenas/items/llama_eterna.tscn` y `scripts/environment/dark_zone.gd` (P65). Sin guardado nuevo. Falta su arte.
- [x] Dash en el aire (`air_dash`, premio del Guardián con `ability_reward`): unas 7 piezas en horizontal, sin gravedad, una vez por salto. Probar en la zona de pruebas que el pasillo de 4 de alto con foso de 6 no se cruza sin él, ni con la Agilidad: `PlayerAction.AIR_DASH` y `PasilloDash` en la zona de pruebas (P66). Sin guardado nuevo. Falta su arte.

**7. Infierno:**
- [x] Arenas con oleadas (coliseo y salón de los verdugos): `scripts/combat/wave_arena.gd` y `ArenaOleadas` en la zona de pruebas (P67). Sin guardado nuevo (solo `completed_encounters`). Sin arte propio.

Las profundidades no piden piezas nuevas: reutilizan el contador de sellos, el fuego infernal, la barrera, la pared agrietada y el mostrar u ocultar.

**En paralelo: atuendos** (P46, sección 10). Dependen sobre todo del arte, así que no frenan el orden de arriba:
- [x] Atuendo actual y `OUTFIT_DEFINITIONS` en `GameManager` (guardado, reinicio, `SAVE_FORMAT_VERSION`): `outfits_found`, `grant_outfit` y rasgos en el Player (P59). `SAVE_FORMAT_VERSION` pasa a 5. Opción "Siguiente atuendo" en el modo dev; faltan su objeto, su aspecto y su menú.
- [x] Un `SpriteFrames` por atuendo; separar el Fire Knight (E5) de los harapos (E1): `escenas/atuendos/fire_knight.tres` (generado con `herramientas/sprites/generar_atuendo_fire_knight.tscn`) y `ManiquiFireKnight` en la zona de pruebas (P68). Sin guardado nuevo. Faltan el arte de E2-E4 y las tiras propias de E1.
- [x] Escena de atuendo para recoger, generalizando `espada_oxidada.tscn`: `escenas/objetos/atuendo.tscn` (`outfit_pickup.gd`, `outfit_id` exportado), del que hereda `espada_oxidada.tscn` con `harapos`; `EspadaOxidada` y `AtuendoSoldado` en la zona de pruebas (P69). Sin guardado nuevo. Falta su arte.
- [x] Sección "Equipo" en el menú de pausa: pestaña `TabEquipo` / `PaginaEquipo` de `escenas/menu/menu_pausa.tscn`, rellenada por `pause_menu_overlay.gd`; se prueba con `EspadaOxidada` y `AtuendoSoldado` de la zona de pruebas (P70). Sin guardado nuevo. Sin arte propio (falta un retrato por atuendo).
- [ ] Arte con IA de E2 (soldado), E3 (caballero de la cripta) y E4 (abrigo); terminar las tiras que faltan de E1.

---

## Fase 3: generar cada zona y montar su `_combate`

Al generar una zona, su archivo pasa a `mapas_texto/tiles_<zona>.txt` y se cambia su ruta en `zonas.txt` (P46, sección 9). Después hay que jugarla.

**Al generar cada zona, además** (P72):
- la escena nueva va a `escenas/mapas/tiles_<zona>.tscn` y `_combate`, el nombre que ya llevan las salidas de los ASCII y `zonas.txt`;
- las salidas que llegan a ella desde zonas todavía viejas apuntan hoy a `archivo/tiles_v1/escenas/`. Hay que cambiarlas a la nueva: la de la prisión (`camara_sellado_alma.tscn`) para el calabozo, y las de los `_combate` de `archivo/tiles_v1/` vecinos;
- castillo y cementerio: `GameManager.CASTLE_SCENE_PATH` / `CEMETERY_SCENE_PATH` (autoguardado) y la lista de `player.gd` (`debug_slide_collisions`) vuelven a `escenas/mapas/`;
- la versión vieja de la zona se queda en `archivo/tiles_v1/`: no se borra ni se toma como referencia.

**Estructura primero, vestir después** (P73): cada zona se genera y se juega con el arte y los enemigos de hoy (lista de abajo), y después se viste con arte y enemigos nuevos (lista "Vestir cada zona"). Lo que se pone en la `_combate` no se pierde al regenerar la base.

**Estructura de cada zona:**
- [x] **Calabozo:** cinco rejas, las dos cinemáticas y sus puntos, enemigos y carcelero, espada y preso, pared agrietada, depósito del alcaide con el acta y la empuñadura, trampilla, transición y spawn de `:B:`. Base generada y `_combate` montada (2026-11-10, `escenas/mapas/tiles_calabozo_combate.tscn`); la salida de la prisión ya apunta a la `_combate`.
  - La reja del depósito pide la llave `mazmorra_alcaide`: la mazmorra la da con ese id y añade su nombre a `KEY_NAMES` (`pause_menu_overlay.gd`).
  - Sin pieza de arcón: el acta y la empuñadura están sueltas en el suelo, en (14, 26) y (15, 26). Las marcas del secreto usan `dialogues/lore_marcas_preso.json` (texto provisional).
  - `SalidaAtajoB` apunta a `tiles_mazmorra_combate.tscn#DesdeCalabozo`, aún sin generar; se crea al montar la mazmorra. `[L1]` apunta a `tiles_castillo_combate.tscn#SpawnInicio`.
- [x] **Castillo:**
  - el Rey con `ability_reward` de Rodar, la reja de `[H2]`, las trampillas y la trampilla de `:C:`;
  - los aposentos de la Reina y el castillo sin hechizo (soldados NPC y el Capitán).
  - Base generada y `_combate` montada (2026-11-11, `escenas/mapas/tiles_castillo_combate.tscn`); `[L1]` del calabozo ya apunta a la `_combate` (`tiles_calabozo.txt` y `target_scene_path` de `tiles_calabozo.tscn`, sin regenerar). `CASTLE_SCENE_PATH` y `debug_slide_collisions` apuntan a `escenas/mapas/`. `[H2]` apunta al cementerio nuevo, aún sin generar.
  - `SalaRey` (`boss_arena.gd`, `encounter_id` `castillo_rey`, `ability_reward roll`, sin llave): puerta en la columna 102 y trampilla de x 70-72 en `Atajos`; la reliquia cae en (86, 62). La llave `castillo_rey` sale de `KEY_NAMES` y de `BOSS_KEY_IDS` (P46, sección 6).
  - Cerrojo del gran salón: barrera en la columna 68 con `open_on_encounter` `castillo_cerrojo_salon`, la palanca en la repisa de la antecámara, (70, 36).
  - `ArenaAntecamara` (`wave_arena.gd`, `encounter_id` `castillo_antecamara`, 2026-11-11): activador en x 76-97, filas 34-40 (se entra al caer de la armería; al reaparecer en el checkpoint de (100, 40) no empieza hasta andar hacia el centro). `Puertas`: `PuertaSalon`, reja en la columna 67, junto al cerrojo, para no huir por la palanca. `Atajos`: `TrampillaVestibulo`, losa en x 104-106, fila 41, sobre la escalera. Oleadas: 1, dos Guardias; 2, una Vanguardia y dos murciélagos; 3, dos Guardias y un murciélago; 4, un Guardia, una Vanguardia y dos murciélagos. Los enemigos de la antecámara salieron del ASCII y la base se regeneró con las mismas colisiones; las `Visibilidad` de los Guardias se renombraron (`Guardia11`, `Guardia12`, `Guardia15`) y la del `Guardia16` se quitó. Falta jugarla y ajustar las oleadas.
  - `:C:`: trampilla en la fila 76 y cabina (`AscensorC`) en el pozo, filas 76-78, sobre una barrera fija en la fila 79 que hace de suelo (el pozo llega al borde de abajo y la cabina no tiene colisión). Las dos escuchan `minas_atajo_c_abierto`: **la palanca de las minas lleva ese `encounter_id`**, y su cabina apunta a `tiles_castillo_combate.tscn#DesdeMinas`; la del castillo va a `tiles_mineria_combate.tscn#DesdeCastillo`.
  - El castillo sin hechizo escucha `mazmorra_reina`, el id con el que la sala de la Reina ya se marca en v1: **la mazmorra nueva lo conserva**. Los Guardias (6 desde la arena de la antecámara) se ocultan y aparecen `Soldado1`…`Soldado7` y `CapitanTrono` (`npc.gd`, cuadro `idle` de la Guardia y del Capitán, de pie: falta el arte de rodillas), con `encounter_visibility.gd`.
  - Aposentos: `PuertaAposentos` (`minas_caballero`), el diario I (`diario_reina_1`) y el fragmento `castillo_1`. E2 (`AtuendoSoldado`) en el nicho de la armería, (105, 10).
  - Textos provisionales: `dialogues/lore_diario_reina_1.json`, `castillo_soldado_1.json` a `_7.json` y `castillo_capitan_trono.json`.
  - La repisa de la palanca (fila 37, x 69-74) queda 4 piezas sobre el suelo de la antecámara: se sube con E1 (4,3), pero la cabecera dice que ningún escalón pasa de 3. Revisarlo al jugarla.
- [ ] **Cementerio:**
  - el Capitán sin llave, las tres tumbas sello y su contador, la losa de `[S3]`, las trampillas del atajo y de la fosa, la casa del sepulturero y E3;
  - la estatua de la Reina, con las notas y el amuleto; la losa, la puerta de velas, la corona con la carta y el fragmento de vida 2/4 de la cripta de la primera reina.
  - Base generada (2026-11-11, `escenas/mapas/tiles_cementerio.tscn`). Hasta que exista la `_combate`, dos salidas apuntan a la base y, al montarla, se cambian a `tiles_cementerio_combate.tscn`:
    - `[H2]` del castillo, a `tiles_cementerio.tscn` (`siguiente:` de `tiles_castillo.txt` y la línea `target_scene_path` de `tiles_castillo.tscn`, sin regenerar);
    - la salida anterior de las minas de v1, a `tiles_cementerio.tscn#DesdeMinas` (`anterior:` de `archivo/tiles_v1/mapas_texto/tiles_mineria.txt` y `SalidaAnterior1` de `archivo/tiles_v1/escenas/tiles_mineria.tscn`). Mientras no exista `DesdeMinas`, se llega al `SpawnInicio`.
  - `CEMETERY_SCENE_PATH` ya apunta a `escenas/mapas/`. `debug_slide_collisions` no cambia: su lista solo tiene el castillo.
  - En la `_combate`: `[S3]` apunta a las minas de v1 (`archivo/tiles_v1/escenas/tiles_mineria_combate.tscn`) hasta generar las nuevas, y `cementerio_capitan` sale de `KEY_NAMES` y `BOSS_KEY_IDS`, porque el Capitán ya no da llave (P46, sección 6).
- [ ] **Minas:**
  - el Caballero en su sala nueva, la puerta con llave de `[L4]`, el ascensor y la palanca de `:C:`, la trampilla del atajo, la reja de `:D:` y las transiciones de `[S3]` y `:C:`;
  - la gruta de cristal: fuego infernal, checkpoint y el Mauler con su `boss_arena` (trampilla de entrada en `Puertas`, la del suelo en `Atajos`, `ability_reward adrenaline`).
- [ ] **Mazmorra:**
  - la Reina con `ability_reward` del Ultimate y sin llave, el suelo que se hunde y el derrumbe, la compuerta y la palanca del atajo, la trampilla del colector y la transición de `[!5]`;
  - la palanca, la transición y el spawn de `:B:` (el calabozo sale a `#DesdeCalabozo` y espera llegar a `#DesdeMazmorra`), y la llave del alcaide (`mazmorra_alcaide`);
  - la trampilla, la transición y el spawn del pozo de los condenados (`:F:`).
- [ ] **Ruina:**
  - el Guardián, la reja de salida en `Atajos`, el hielo de `[P6]` y la llama eterna, la luz de la parte oscura;
  - la palanca y la reja de `:D:`, las trampillas del atajo y de `:E:`, y las transiciones de `[!5]`, `:D:`, `[P6]` y `:E:`;
  - el hielo negro (la misma pieza que el hielo de `[P6]`, con `key_id` `profundidades_ascua`), la página III y el fragmento de vida 3/4.
- [ ] **Profundidades:**
  - elegir los minijefes de los altares (P46, sección 7);
  - los tres altares y su contador, el fuego infernal y E5;
  - el Demon Slime, con reja y trampilla en `Puertas`, reja de salida en `Atajos` y la ascua (`profundidades_ascua`, en su `PuntoLlave`);
  - la palanca de `:E:`, las trampillas del atajo, del lago y del coliseo, y las transiciones de `[P6]`, `:E:` y `[S7]`;
  - la palanca, la transición y el spawn de `:F:`, los restos de los condenados y la página II del diario;
  - la jaula del rey encadenado: rejilla, el rey (sprite del Rey Caído), su alma y el fragmento de vida 4/4, según `infierno_animas_liberadas`.
- [ ] **Infierno:**
  - decidir los enemigos definitivos de la prueba final;
  - las arenas con oleadas del coliseo y del salón, las rejas bajas del pasillo y el fuego infernal;
  - Cthulhu en el trono, con la reja en `Puertas`, el activador, `PuntosJefe` y el aviso del final;
  - la transición y el spawn de `[S7]`, y la marca `infierno_animas_liberadas` del coliseo.

**Plantillas de prompt de la estructura.** La estructura de cada zona se hace en dos sesiones, cada una con su commit:
- parte 1, generar la base: modo normal;
- parte 2, montar la `_combate`: modo plan.

Después, la zona se juega a mano antes de vestirla. En cada plantilla, cambiar `<zona>`.

Parte 1, generar la base:

```
Tarea: Fase 3 de TASK.md, estructura de <zona>, parte 1: generar la escena base.

Antes de nada, lee:
- CLAUDE.md (mapas en uso, cómo se monta un mundo, validar cambios);
- en TASK.md, la Fase 3: el bloque "Al generar cada zona, además" y la
  línea de <zona>;
- docs/P46_MACRO_MAPA.md, secciones 9 y 10 (la fila de <zona> en
  "Desbloqueos por zona");
- mapas_texto/macro/conexiones.txt, zonas.txt y el ASCII
  mapas_texto/macro/zonas/<zona>.txt, sobre todo su cabecera;
- mapas_texto/LEYENDA.md (cómo se usa el constructor).

Qué hacer:
- Mueve el ASCII a mapas_texto/tiles_<zona>.txt y cambia su ruta en zonas.txt.
- Genera escenas/mapas/tiles_<zona>.tscn con el constructor. Todavía no
  hagas la _combate.
- Cambia a la escena nueva las salidas que llegan a <zona> desde zonas aún
  viejas (archivo/tiles_v1/ o la prisión) y, si es el castillo o el
  cementerio, CASTLE_SCENE_PATH / CEMETERY_SCENE_PATH y
  debug_slide_collisions de player.gd. Antes de tocar las salidas, dime
  cuáles vas a cambiar.

Al terminar:
- verificar_mundo.py con 0 errores, y arranque sin errores de la escena
  nueva y del juego;
- regenera el Atlas (datos_atlas.py) y publícalo de nuevo;
- dime qué .tscn cambiaste, para recargarlos, y haz un commit sin push.
Si algo no cuadra con los archivos, dímelo antes de seguir. Responde en español.
```

Parte 2, montar la `_combate`:

```
Tarea: Fase 3 de TASK.md, estructura de <zona>, parte 2: montar
escenas/mapas/tiles_<zona>_combate.tscn, que hereda de tiles_<zona>.tscn.

Antes de nada, lee:
- CLAUDE.md, sobre todo "Cómo se monta un mundo" y las piezas a reutilizar;
- en TASK.md, la lista de <zona> en la Fase 3: es lo que hay que montar;
- la cabecera de mapas_texto/tiles_<zona>.txt (sitios, coordenadas,
  encuentros, llaves);
- docs/P46_MACRO_MAPA.md, sección 10 (con qué llega el jugador y qué
  consigue aquí);
- las etapas de las piezas que usa (P48-P70) y
  docs/P33_ENEMIGOS_POR_PROFUNDIDAD.md.

Cómo trabajar:
- Antes de montar nada, pásame una lista: cada nodo, su escena o script, su
  posición en piezas y sus valores (encounter_id, key_id, ability_reward...).
  Espera a que la apruebe.
- Reutiliza las piezas de la Fase 2. No crees piezas nuevas: si falta algo,
  dímelo.
- No regeneres la base ni toques su .txt. Si hace falta, dímelo.
- Static typing; daño y curación en múltiplos de 0.25.

Al terminar:
- una prueba sin ventana (escena temporal, que se borra al acabar) de la
  secuencia principal: jefe, llave o puerta, salida;
- arranque sin errores de la _combate y del juego y, si tocaste scripts
  compartidos, de la zona de pruebas y de las zonas ya generadas;
- cambia las salidas para que apunten a la _combate;
- marca la casilla de <zona> en TASK.md, dime qué .tscn cambiaste y haz un
  commit sin push.
Si algo no cuadra, dímelo antes de seguir. Responde en español.
```

### Vestir cada zona: arte y enemigos nuevos (P73)

Hay tres pasos por zona; cada uno es una sesión con su commit:
1. **Ficha:** la propone Claude y se aprueba. Va en P73, sección 3.
2. **Piezas:** el tileset y los enemigos nuevos, probados en la galería de la zona de pruebas.
3. **Vestir:** se cambian la cabecera y las letras del `.txt`, se regenera la base y se comprueba que las colisiones no cambian.

El criterio de "hecho" de cada paso está en P73, sección 2. La ficha se puede armar antes de que exista la estructura, pero para vestir hay que tenerla.

Modo de cada paso: la ficha y vestir, en modo normal; las piezas, en modo plan si llevan un script o una escena nueva.

- [x] Calabozo: [x] ficha, [x] piezas, [x] vestida (2026-11-11: tileset, bloques y fondo `calabozo`, rejillas y telarañas; colisiones iguales, verificador con 0 errores, Atlas publicado y jugada a mano).
- [x] Castillo: [x] ficha (2026-11-11: tablón de madera en `=`, pared con pilastras, estandarte rojo y letras nuevas `A` armero, `D` trofeo, `O` provisiones y `Q` cuadro; los cofres toman el cofre del Mimic, que se deja para más abajo; revisada el 2026-11-11: una pared por sala con `fondo_sala`, cielo en las almenas y decorados `w`, `K`, `U`, `l`, `n`, `y` y `V`), [x] piezas (2026-11-11: `atlas_castillo.py` arma las filas 20-23 del atlas; `cofre_madera.tscn`; `A` 2x3, `D` 3x3, `O` 2x3 y `Q` 2x2; cuarto "TILESET CASTILLO" en la galería, probado sin ventana y en captura), [x] piezas de la revisión (2026-11-11: `fondo_sala` en el constructor, atlas a 512x512 con las paredes y los decorados nuevos, cuarto "CASTILLO, SALAS" en la galería, probado sin ventana y en captura), [x] vestida (2026-11-11: una pared por sala, con piedra en la biblioteca y piedra oscura en el gran salón y la galería; cielo en las almenas y los decorados nuevos colocados; base regenerada con las mismas colisiones; jugada a mano).
- [ ] Cementerio: [ ] ficha, [ ] piezas, [ ] vestida.
- [ ] Minas: [ ] ficha, [ ] piezas, [ ] vestida.
- [ ] Mazmorra: [ ] ficha, [ ] piezas, [ ] vestida.
- [ ] Ruina: [ ] ficha, [ ] piezas, [ ] vestida.
- [ ] Profundidades: [ ] ficha, [ ] piezas, [ ] vestida.
- [ ] Infierno: [ ] ficha, [ ] piezas, [ ] vestida.

**Plantilla de prompt** (cambiar `<zona>` y `<paso>` (ficha, piezas o vestir), y poner en `<notas>` lo que se quiera añadir):

```
Tarea: vestir <zona>, paso "<paso>" (TASK.md, Fase 3, "Vestir cada zona";
método en docs/P73_VESTIR_ZONAS.md).

Antes de nada, lee:
- docs/P73_VESTIR_ZONAS.md entero, sobre todo la ficha de <zona>;
- la cabecera del ASCII o del .txt de la zona (tileset, fondo, enemigos,
  decorados);
- docs/P33_ENEMIGOS_POR_PROFUNDIDAD.md y la fila de <zona> en "Desbloqueos
  por zona" de docs/P46_MACRO_MAPA.md, sección 10;
- mapas_texto/LEYENDA.md, secciones 5, 8 y 9, y docs/P34_ENEMIGOS_DE_LOS_PAQUETES.md
  (cómo se integra un pack y un enemigo).

Cómo trabajar:
- Ficha: proponme la ambientación, los enemigos (profundidad, script base,
  vida, daño, letra, sitio) y de dónde sale el arte (pack de assets/terceros/,
  pack nuevo o receta para la IA). Espera a que la apruebe.
- Piezas: antes de programar, dime qué escenas, scripts y letras nuevas hay.
  Prueba en la galería (herramientas/zona_pruebas/galeria.py). Solo piezas
  macizas en los bloques de un tileset nuevo. Si una decisión no está en la
  ficha, pregúntamela.
- Vestir: cambia solo el .txt de la zona y regenera. Compara las celdas
  sólidas antes y después; si cambian, para y pregúntame.
- Static typing, daño en múltiplos de 0.25 y pixel art a escala entera.
  Si editas un .tscn, dime cuál.
<notas>

Al terminar, cumple el criterio de "hecho" del paso (P73, sección 2),
marca la casilla en TASK.md y haz un commit sin push. Si algo no cuadra con
lo que encuentres en los archivos, dímelo antes de seguir. Responde en español.
```

---

## Otros pendientes del proyecto

- **Licencias:**
  - Pixel Fantasy Caves: el ZIP no trae licencia; confirmar de dónde se bajó (`assets/terceros/pixelfantasy_caves/ORIGEN.txt`);
  - `Final.zip` (Anokolisa): su nota pide no dar crédito si se cambia el arte; anotarlo en un `ORIGEN.txt` cuando se use.
  - los packs de `assets/terceros/` cuyo `ORIGEN.txt` dice "por confirmar" (los Elementals, Demon Slime, Cthulhu, Frost Guardian, mino, Lively NPCs, Raou, el Dungeon Tile Set y las barras de vida): procedencia y licencia (P72).
- **Duplicado:** `assets/terceros/dungeon_tile_set/Dungeon Tile Set.png` y `copia_prueba/Dungeon Tile Set.png` son el mismo PNG con dos uids. Unificarlos pide cambiar uids en escenas, no solo rutas (P72).
- **Arte:**
  - escala del diablillo, que a escala 1 se ve más grande que el Player;
  - enemigos y decorados de Gothicvania (`Legacy Collection/Assets/Gothicvania/`);
  - un tileset propio por tema. Pasos en `mapas_texto/LEYENDA.md`, sección 8.
- **Jefes:** jugar a mano los jefes nuevos y ajustar su dificultad.
- **Ramas:** fusionar esta rama en `main` cuando el equipo lo apruebe, y decidir qué hacer con la rama `v5`.
