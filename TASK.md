# Macro mapa: rehacer el mundo desde cero

- **Plan:** `docs/P46_MACRO_MAPA.md` (dibujo, ruta, atajos, decisiones y desbloqueos por zona). La forma de trabajo está en su sección 9.
- **Puertas hacia atrás:** el punto 1 de `mapas_texto/macro/sugerencias_exploracion.txt`, ideas 1 a 9, con sitio, llave, premio, vuelta y coste de cada una.
- **Lo que hay hoy en Godot no cuenta:** los niveles `tiles_*` y sus escenas `_combate` se descartan mientras dure la fase ASCII. No se usan como referencia ni se arreglan; cada zona se genera de nuevo desde su ASCII en la Fase 3.

Las tres fases:
1. **Fase 1, los ASCII:** cada zona dibujada a escala real, con sus puertas hacia atrás. Todas las zonas tienen ya su primera y segunda pasada; falta sumar las puertas.
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
- [ ] 5. **Ruina:** idea 8 (hielo negro).
- [ ] 6. **Profundidades e infierno:** idea 9 (rey encadenado).
  - Quitar al Mauler del comentario del santuario: ahora va el segundo demonslime.
  - Anotar en el infierno que su coliseo marca "ánimas liberadas".
- [ ] 7. **Cierre:**
  - repasar la tabla "Desbloqueos por zona" de P46 contra los ASCII;
  - verificador y Atlas;
  - marcar el punto 1 de las sugerencias como hecho.

**Fuera de esta fase:** los puntos 2 (premio del Guardián), 4 (secretos variados), 5 (premios), 6 (monedas), 7 (mapa del jugador) y 8 (NPC que baja) de las sugerencias.

---

## Fase 2: piezas en Godot

Cada pieza se prueba en la zona de pruebas (`escenas/mapas/zona_pruebas_combate.tscn`) y se documenta en una etapa nueva de `docs/`. Si toca el Player o el `GameManager`, se comprueba también `mundo_1`. El orden se fija al terminar la Fase 1.

**Piezas de las zonas** (P46, sección 5):
- [ ] Reja baja que solo se pasa rodando (`[H2]` y el pasillo del filo del infierno).
- [ ] Contador de sellos que abre una puerta (`[S3]`, `[S7]`).
- [ ] Suelo que se hunde y secuencia de derrumbe y huida (`[!5]`).
- [ ] Hielo que se derrite con la llama eterna, y la luz de la antorcha (`[P6]`).
- [ ] Ascensor minero (`:C:`).
- [ ] Pared agrietada que se rompe a golpes (secreto del calabozo).
- [ ] Palanca y barrera que se abre según `completed_encounters` (atajos `:B:` a `:F:` y compuerta de la mazmorra).
- [ ] Fuego infernal que solo se pasa con E5 (santuario, gruta de cristal, infierno).
- [ ] IA del Crystal Mauler: hoy `escenas/jefes/boss_mina.tscn` es solo sprite y colisión, sin script (¿`simple_boss.gd`?). Su sala, la gruta de cristal, mide 16 x 14.
- [ ] Arenas con oleadas (coliseo y salón de los verdugos del infierno).

**Piezas de las puertas hacia atrás** (punto 1 de las sugerencias, "Piezas compartidas"):
- [ ] Fragmento de vida: 4 dan 1 corazón. Hay que tocar el guardado y subir `SAVE_FORMAT_VERSION`.
- [ ] Objeto de lore que abre un diálogo (`npc.gd` y `dialogue_ui`).
- [ ] Rompible que solo acepta un tipo de golpe: el ascendente con Golpe final o la Ultimate.
- [ ] `locked_door` con otro dibujo: velas y hielo negro, la misma pieza del hielo de `[P6]`.
- [ ] Mostrar u ocultar según un encuentro superado (generalizar `story_hidden_actor.gd`).
- [ ] Mejoras de +0.25 de daño y +0.25 en pociones.

**Ajustes de lo decidido** (P46, sección 6):
- [ ] La tienda vende un solo nivel de vida máxima (`max_level` 1 en `UPGRADE_DEFINITIONS`).
- [ ] La Adrenalina sale de `STARTING_ABILITIES` (la da el Mauler).

**Atuendos** (P46, sección 10):
- [ ] Atuendo actual y `OUTFIT_DEFINITIONS` en `GameManager` (guardado, reinicio, `SAVE_FORMAT_VERSION`).
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
  - el hielo negro.
- [ ] **Profundidades:**
  - elegir los minijefes de los altares (P46, sección 7);
  - los tres altares y su contador, el fuego infernal y E5;
  - el Demon Slime, con reja y trampilla en `Puertas`, reja de salida en `Atajos` y la ascua;
  - la palanca de `:E:`, las trampillas del atajo, del lago y del coliseo, y las transiciones de `[P6]`, `:E:` y `[S7]`;
  - la palanca, la transición y el spawn de `:F:`, los restos de los condenados y la página II del diario, y el rey encadenado.
- [ ] **Infierno:**
  - decidir los enemigos definitivos de la prueba final;
  - las arenas con oleadas del coliseo y del salón, las rejas bajas del pasillo y el fuego infernal;
  - Cthulhu en el trono, con la reja en `Puertas`, el activador, `PuntosJefe` y el aviso del final;
  - la transición y el spawn de `[S7]`, y la marca de "ánimas liberadas".

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
