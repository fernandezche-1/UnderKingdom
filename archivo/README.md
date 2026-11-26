# Archivo histórico

El inventario `INVENTARIO_P72.tsv` conserva las rutas y referencias registradas en P72. El [inventario de traslados de la reorganización](../documentacion/inventario_traslados.tsv) indica dónde está cada archivo actualmente.

| Ruta actual | Contenido |
| --- | --- |
| `mapas/tng/historicos/tiles_v1/` | Escenas de las zonas con tiles de la primera versión. |
| `mapas/tng/historicos/mapas_viejos/` | Escena histórica `tiles_casa.tscn`. |
| `mapas/tog/historicos/mapas_viejos/` | Mundos hechos a mano, ejemplos y arenas anteriores. |
| `mapas/fuentes/tng/historicos/` y `mapas/fuentes/tog/historicos/` | ASCII e imágenes de autoría correlacionados con los mapas históricos. |
| `archivo/tiles_v1/` y `archivo/mapas_viejos/` | Código, objetos, jefes y arte específicos de los mapas anteriores. |
| `archivo/herramientas/` | Herramienta histórica de la Fase 2. |
| `rd/` | Reserva con `.gdignore`. Incluye paquetes y archivos comprobados como ajenos a las referencias de ejecución actuales. |

La campaña usa los mapas de Fase 3 en `mapas/tng/`. Las escenas históricas siguen importándose para consultar versiones anteriores y abrir partidas existentes de formato 5. El constructor excluye el directorio `historicos/` de cada familia.

Para recuperar un recurso de `rd/`, mueve con él su archivo `.import` o `.uid`, actualiza sus rutas `res://` y vuelve a importar el proyecto en Godot. Conserva la licencia y el archivo `ORIGEN.txt` cuando correspondan.
