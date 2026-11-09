# Macro mapa: rehacer el mundo desde cero

- **Plan:** `docs/P46_MACRO_MAPA.md` (dibujo, ruta, atajos, decisiones y desbloqueos por zona). La forma de trabajo está en su sección 9.
- **Puertas hacia atrás:** el punto 1 de `mapas_texto/macro/sugerencias_exploracion.txt`, ideas 1 a 9, con sitio, llave, premio, vuelta y coste de cada una.
- **Lo que hay hoy en Godot no cuenta:** los niveles `tiles_*` y sus escenas `_combate` se descartan mientras dure la fase ASCII. No se usan como referencia ni se arreglan; cada zona se genera de nuevo desde su ASCII en la Fase 3.

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

Cada pieza se prueba en la zona de pruebas (`escenas/mapas/zona_pruebas_combate.tscn`) y se documenta en una etapa nueva de `docs/`. Si toca el Player o el `GameManager`, se comprueba también `mundo_1`.

**Una pieza está hecha cuando:**
- funciona en la zona de pruebas, montada en `zona_pruebas_combate.tscn` (o en el `.txt` si lleva letra), con un caso que muestre que cierra y otro que muestre que abre;
- se probó sin ventana con una escena temporal que simula entradas e imprime el resultado, y esa escena se borró;
- arrancan sin errores el juego (`godot --headless --quit-after 120`) y la zona de pruebas, y también `mundo_1` si se tocó el Player, un enemigo, el `GameManager` o el Capitán;
- si guarda estado, se reinicia en `reset_for_new_game`, se guarda en `_make_save_data` / `_restore_game_state` y se sube `SAVE_FORMAT_VERSION`;
- hay una etapa nueva en `docs/` (la siguiente libre es P63), con el formato de las demás, y está al día lo que la nombra: P46 (secciones 5 y 10), CLAUDE.md si cambia una regla o una pieza a reutilizar, y esta lista;
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

**Modo autónomo:** `herramientas/fase2_auto.sh` hace las piezas una tras otra, con una sesión de Claude Code por pieza y un commit cada una, sin pedir aprobación. Las decisiones de diseño que los documentos no fijaban están en `docs/FASE2_DECISIONES.md`: el script no arranca hasta que ese archivo diga "Estado: APROBADO". Una pieza que no se puede terminar se marca `- [~]` y su motivo va a ese archivo.

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
- [ ] Suelo que se hunde y secuencia de derrumbe y huida (`[!5]`).

**6. Ruina:**
- [ ] Hielo que se derrite con la llama eterna, y la luz de la antorcha (`[P6]`), sobre la `locked_door` con otro dibujo del paso 3.
- [ ] Dash en el aire (`air_dash`, premio del Guardián con `ability_reward`): unas 7 piezas en horizontal, sin gravedad, una vez por salto. Probar en la zona de pruebas que el pasillo de 4 de alto con foso de 6 no se cruza sin él, ni con la Agilidad.

**7. Infierno:**
- [ ] Arenas con oleadas (coliseo y salón de los verdugos).

Las profundidades no piden piezas nuevas: reutilizan el contador de sellos, el fuego infernal, la barrera, la pared agrietada y el mostrar u ocultar.

**En paralelo: atuendos** (P46, sección 10). Dependen sobre todo del arte, así que no frenan el orden de arriba:
- [x] Atuendo actual y `OUTFIT_DEFINITIONS` en `GameManager` (guardado, reinicio, `SAVE_FORMAT_VERSION`): `outfits_found`, `grant_outfit` y rasgos en el Player (P59). `SAVE_FORMAT_VERSION` pasa a 5. Opción "Siguiente atuendo" en el modo dev; faltan su objeto, su aspecto y su menú.
- [ ] Un `SpriteFrames` por atuendo; separar el Fire Knight (E5) de los harapos (E1).
- [ ] Escena de atuendo para recoger, generalizando `espada_oxidada.tscn`.
- [ ] Sección "Equipo" en el menú de pausa.
- [ ] Arte con IA de E2 (soldado), E3 (caballero de la cripta) y E4 (abrigo); terminar las tiras que faltan de E1.

---

## Fase 3: generar cada zona y montar su `_combate`

Al generar una zona, su archivo pasa a `mapas_texto/tiles_<zona>.txt` y se cambia su ruta en `zonas.txt` (P46, sección 9). Después hay que jugarla.

- [ ] **Calabozo:** cinco rejas, las dos cinemáticas y sus puntos, enemigos y carcelero, espada y preso, pared agrietada, depósito del alcaide con el acta y la empuñadura, trampilla, transición y spawn de `:B:`.
- [ ] **Castillo:**
  - el Rey con `ability_reward` de Rodar, la reja de `[H2]`, las trampillas y la trampilla de `:C:`;
  - los aposentos de la Reina y el castillo sin hechizo (soldados NPC y el Capitán).
- [ ] **Cementerio:**
  - el Capitán sin llave, las tres tumbas sello y su contador, la losa de `[S3]`, las trampillas del atajo y de la fosa, la casa del sepulturero y E3;
  - la estatua de la Reina, con las notas y el amuleto; la losa, la puerta de velas, la corona con la carta y el fragmento de vida 2/4 de la cripta de la primera reina.
- [ ] **Minas:**
  - el Caballero en su sala nueva, la puerta con llave de `[L4]`, el ascensor y la palanca de `:C:`, la trampilla del atajo, la reja de `:D:` y las transiciones de `[S3]` y `:C:`;
  - la gruta de cristal: fuego infernal, checkpoint y el Mauler con su `boss_arena` (trampilla de entrada en `Puertas`, la del suelo en `Atajos`, `ability_reward adrenaline`).
- [ ] **Mazmorra:**
  - la Reina con `ability_reward` del Ultimate y sin llave, el suelo que se hunde y el derrumbe, la compuerta y la palanca del atajo, la trampilla del colector y la transición de `[!5]`;
  - la palanca, la transición y el spawn de `:B:`, y la llave del alcaide;
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

---

## Otros pendientes del proyecto

- **Licencias:**
  - Pixel Fantasy Caves: el ZIP no trae licencia; confirmar de dónde se bajó (`assets_prueba/pixelfantasy_caves/ORIGEN.txt`);
  - `Final.zip` (Anokolisa): su nota pide no dar crédito si se cambia el arte; anotarlo en un `ORIGEN.txt` cuando se use.
- **Arte:**
  - escala del diablillo, que a escala 1 se ve más grande que el Player;
  - enemigos y decorados de Gothicvania (`Legacy Collection/Assets/Gothicvania/`);
  - un tileset propio por tema. Pasos en `mapas_texto/LEYENDA.md`, sección 8.
- **Jefes:** jugar a mano los jefes nuevos y ajustar su dificultad.
- **Ramas:** fusionar esta rama en `main` cuando el equipo lo apruebe, y decidir qué hacer con la rama `v5`.
