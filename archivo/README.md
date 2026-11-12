# archivo/

Lo que el juego ya no usa para avanzar, apartado en P72 (`docs/P72_ORGANIZACION_REPO.md`) antes de la Fase 3. No se borró nada. Cada archivo, con su ruta de antes y quién lo usaba, está en `INVENTARIO_P72.tsv`.

| Carpeta | Qué hay | ¿Godot lo abre? |
|---|---|---|
| `tiles_v1/` | Los niveles con tiles de antes de la Fase 3: las 16 escenas `tiles_*` y `_combate` (`escenas/`), sus fuentes `.txt`/`.png` (`mapas_texto/`) y la armería con llave del castillo viejo (`scripts/`, `escenas/items/`). La ruta de hoy pasa por aquí: prisión → `tiles_v1/escenas/tiles_calabozo_combate.tscn` → … | Sí |
| `mapas_viejos/` | Los mapas hechos a mano (`mundo_1`, `mundo_2`, `mundo_3`, `primer_boss_mundo_1`, `ruina`, `profundidades`, `jefe_final`), los ejemplos y arenas de prueba (`ejemplo_*`, `arena_enemigos`, `prueba_tileset`, `antorhca`) y `tiles_casa`. Con ellos van sus fondos, sus `.txt`, las piezas y scripts que solo usan ellos (`world1_*`, `story_hidden_actor`, `world_test_route`, caja y estatua rompibles, jefes viejos) y los assets exclusivos (`assets/<pack>/`). | Sí |
| `herramientas/` | `fase2_auto.sh`, el modo autónomo de la Fase 2 (ya cerrada; sus decisiones están en `docs/historial/FASE2_DECISIONES.md`). | — |
| `sin_uso/` | Packs de arte y archivos que nada referencia. Cada parte de un pack lleva una copia de su licencia. | No (`.gdignore`) |

## Por qué

- **`tiles_v1/` y `mapas_viejos/` no llevan `.gdignore`:** algo los referencia y tienen que seguir abriendo, porque la ruta actual corre por `tiles_v1/` y los mapas viejos se conservan por si se quieren consultar (desde 2026-11-10 `mundo_1` ya no se comprueba al tocar scripts compartidos). No se toman como referencia de diseño ni se arreglan (TASK.md).
- **Los `.txt` de `tiles_v1/mapas_texto/` y `mapas_viejos/mapas_texto/` ya no se regeneran en su sitio:** el constructor solo escribe en `res://escenas/mapas/`. Son la fuente de lo que hay, no de lo que vendrá.
- **`sin_uso/` lleva `.gdignore`:** así Godot no importa sus ~2 900 archivos.

## Cómo recuperar algo

1. Moverlo de vuelta con `git mv`, junto con su `.import` y su `.uid`. La ruta de origen está en `INVENTARIO_P72.tsv`.
2. Si viene de `sin_uso/`, el destino debe quedar fuera de esa carpeta, o Godot no lo verá. Un asset de terceros va a `assets/terceros/<pack>/`.
3. Corregir las rutas `res://` que lo nombren y correr `godot --headless --import`.
