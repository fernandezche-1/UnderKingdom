# P72 - Organización del repo antes de la Fase 3

- La Fase 2 está cerrada. La Fase 3 genera cada zona desde su ASCII (`mapas_texto/macro/zonas/`) con el constructor y monta su `_combate` en `escenas/mapas/`.
- Antes de P72 la raíz tenía 20 packs de arte sueltos (unos 5 900 archivos que nada usaba), PNG sueltos, y los mapas viejos y los `tiles_*` mezclados con lo vivo.
- Ahora lo que la Fase 3 usa queda a mano, y el resto está en `archivo/`, sin borrar nada.
- No cambian:
  - el contenido de ningún mapa más allá de sus rutas;
  - las colisiones;
  - los ajustes del temblor al caminar;
  - la lógica del juego.
- Sin guardado nuevo. Las partidas guardadas dentro de un nivel `tiles_*` (su `scene_path` apunta a `escenas/mapas/`) ya no cargan ese mapa: hay que empezar partida nueva.

## 1. Cómo se clasificó

- Con un grafo de referencias de los 7 334 archivos de git, que siguió tres tipos de referencia:
  - rutas `res://`, también con espacios, en escenas, recursos, scripts, `project.godot`, `.txt` del constructor, `.py`, `.sh` y `.json`;
  - `uid://`, resueltos con los `.uid`, los `.import` y las cabeceras;
  - los `class_name` usados por nombre.
- Desde cada grupo de raíces se calculó qué se alcanza, sin cruzar de un grupo a otro:
  - **vivo:** proyecto, menús, cinemática, prisión, zona de pruebas, constructor, herramientas y todas las piezas de `escenas/{enemigos,jefes,objetos,items,sistemas,ui,npc,proyectiles,atuendos}`;
  - **`tiles_*`;**
  - **mapas hechos a mano.**
- Tres grupos:
  - **VIVO:** lo alcanza algo vivo. También lo que usan los `tiles_*` y la Fase 3 va a reutilizar: jefes, carcelero, `cinematic_controller`, `map_ambience`, diálogos y fondos de zona.
  - **VIEJO:** solo lo alcanzan los `tiles_*` o los mapas hechos a mano.
  - **SIN USO:** no lo alcanza nada.
- Dentro de un pack cuenta cada archivo: lo usado se queda, el resto se aparta.
- El inventario completo, archivo por archivo (ruta de antes, grupo, destino y quién lo usa), está en `archivo/INVENTARIO_P72.tsv`.

## 2. Qué se movió y a dónde

| Bloque | Commit | Qué | A dónde |
|---|---|---|---|
| 1 | `c326c90` | Arte vivo de los packs de la raíz, de `otra vez/`, `prueba/`, `assets_prueba/`, `tile/` e `imagem vidas/`; el arte propio del protagonista que estaba dentro del pack del Fire Knight; `111.png` | `assets/terceros/<pack>/` (carpeta doble de los Elementals aplanada), `assets/personajes/`, `assets/prision/` |
| 2 | `824c57a` | `mundo_1`, `mundo_2`, `mundo_3`, `primer_boss_mundo_1`, `ruina`, `profundidades`, `jefe_final`, `ejemplo_*`, `arena_enemigos`, `prueba_tileset`, `antorhca`, `tiles_casa`, con sus `.txt`, `fondos/`, spikes, caja y estatua rompibles, `boss.tscn`, `boss_mina.tscn`, `espada_recuperable.tscn`, scripts (`world1_boss_gate_blocker`, `checkpoint_boss`, `ledge_transition_zone`, `story_hidden_actor`, `w2_queen_knight_progress`, `world_test_route`, `dark_castle_map`, `animated_sprite_2d`) y los assets que solo usan ellos | `archivo/mapas_viejos/` |
| 3 | `a255709` | Los 16 `tiles_*` (base y `_combate`), sus `.txt`/`.png` y la armería con llave del castillo viejo (`castle_key_guard`, `castle_key_door`, `castle_armory_equipment`, `castle_key_pickup`, `llave_armeria_castillo.tscn`) | `archivo/tiles_v1/` |
| 4 | `8aa1e11` | El resto de los packs, PNG sueltos (`armandito`, `prsision`, `escaleras_12_frames…`), `comandos.txt`, `prision/cadenas.png`, `fondos/ruina_bajo.png`, `dialogues/w1_intro_cementerio.json`, `herramientas/diagnostico_colisiones_armeria.gd` | `archivo/sin_uso/` (con `.gdignore`) |
| 5 | `992854d` | P1–P7, P26, P28 (2), P30, P39, P40, los 10 CHANGELOG, `CAMBIOS_*.txt` y `FASE2_DECISIONES.md`; `fase2_auto.sh` | `docs/historial/`, `archivo/herramientas/` |

- Cada archivo se movió con `git mv`, junto con su `.import` y su `.uid`, así que los uids no cambian.
- Después de cada bloque se corrigieron las rutas `res://` en escenas, recursos, scripts, `.import`, tilesets del constructor, `galeria.py`, `generar_atuendo_fire_knight.gd` (lee una carpeta entera), docs, CLAUDE.md, TASK.md y LEYENDA.md.
- Cada pack de `assets/terceros/` lleva su licencia y un `ORIGEN.txt`. El `ORIGEN.txt` dice de dónde venía, qué lo usa y dónde quedó el resto. Cada parte apartada lleva una copia de la licencia.
- Packs que no traen licencia: su `ORIGEN.txt` dice "por confirmar" (TASK.md, "Otros pendientes").
- **Lo que se queda donde estaba:** `escenas/` (salvo los mapas y las piezas viejas), `scripts/` (salvo los de arriba), `dialogues/`, `fuentes/`, `sprites/` (monedas, poción, trampas), `assets/cinematica/`, `mapas_texto/` (LEYENDA, `macro/`, paleta, `zona_pruebas.txt`), `herramientas/` y los docs P31–P38 y P41–P71.
  - P42 se queda: además del calabozo viejo, guarda las reglas sin espada (`unarmed_*`) y la receta del arte con IA que cita P46.
- **No se cambió ningún nombre de archivo.** Solo carpetas:
  - `tile/` pasa a `dungeon_tile_set/`;
  - la copia de `prueba/Dungeon Tile Set.png` va a `dungeon_tile_set/copia_prueba/`;
  - la carpeta doble de los Elementals y la de `imagem vidas` se aplanan.

## 3. Rutas que apuntan al archivo

La ruta se sigue jugando desde `archivo/tiles_v1/`. Apuntan ahí:
- la salida de la prisión (`escenas/mapas/prologo_prision/camara_sellado_alma.tscn`);
- las salidas entre los `tiles_*`;
- `GameManager.CASTLE_SCENE_PATH` y `CEMETERY_SCENE_PATH` (autoguardado al entrar);
- la lista de `player.gd` de la traza `debug_slide_collisions`.

`GameManager` usa además `scene_path.contains("tiles_castillo")`, que sigue funcionando.

**No se tocó:**
- la clave de guardado `"res://escenas/mapas/tiles_castillo.tscn|PuertaArmeria"` de `castle_armory_equipment.gd` y `castle_key_door.gd`: es un id, no una ruta, y las dos la escriben igual;
- las salidas y el `escena:` de `mapas_texto/macro/zonas/*.txt` y la columna de escena de `zonas.txt`: nombran `escenas/mapas/tiles_*`, donde generará la Fase 3. El constructor ya admite salidas a escenas que todavía no existen.

Al generar cada zona, la Fase 3 vuelve a poner estas rutas en `escenas/mapas/` (TASK.md, Fase 3).

## 4. Cómo se validó

Después de cada bloque se comparó con una pasada de referencia hecha antes del bloque 1:
- `godot --headless --import`: sin "Failed loading resource", "Cannot open file" ni dependencias rotas;
- `--quit-after 120` en estas escenas, con los mismos avisos que antes:
  - el menú principal;
  - `cinematica_inicial.tscn` (el aviso de `narracion_reina.mp3` al cortar, de siempre);
  - la prisión;
  - los 8 `tiles_*_combate`;
  - `zona_pruebas_combate.tscn`;
  - `mundo_1.tscn` (su aviso "No se encontró un SpawnPoint con suelo seguro" ya salía antes).
- Todas las `target_scene_path` de las escenas que quedan apuntan a archivos que existen.
- Grep final con el mismo analizador. No queda ningún `res://` a una ruta que no existe, salvo:
  - las salidas hacia la Fase 3 de los ASCII;
  - la clave `PuertaArmeria`;
  - dos ejemplos que ya estaban rotos (`docs/historial/P26`, nombres de ejemplo de LEYENDA).
- `verificar_mundo.py`: 0 errores.
- El constructor regenera `zona_pruebas.tscn` (y `galeria.py`, `zona_pruebas_galeria.tscn` y `zona_pruebas.txt`) sin diferencias, salvo los `unique_id`. Esos cambian en cada pasada también sin P72.

## 5. Pendiente

- Al abrir el editor, Godot reimporta lo movido (unos 1 200 archivos): tarda unos minutos.
- Hay que recargar en el editor, sin guardar encima, las escenas editadas. Se cambiaron sus rutas; las que se movieron además están en `archivo/`.
- Confirmar la procedencia y la licencia de los packs con "por confirmar".
- `Dungeon Tile Set.png` está dos veces (`dungeon_tile_set/` y `copia_prueba/`), con dos uids. Unificarlo pide cambiar uids en escenas, no solo rutas.
- Fase 3: al generar cada zona, mover a `escenas/mapas/` las rutas de la sección 3.
