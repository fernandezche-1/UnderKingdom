# Organización de UnderKingdom

La reorganización se realizó en la rama de desarrollo `v4-6ex`, a partir de `abfa63c`. Las carpetas usan nombres en español, minúsculas y caracteres ASCII. Se conservaron los nombres de los archivos, los UID, los identificadores de escena y las configuraciones de importación. Las escenas y scripts se agrupan por su sistema. Las fuentes de mapas y las herramientas de autoría tienen ubicaciones propias.

El [inventario de traslados](documentacion/inventario_traslados.tsv) registra **7 474 rutas anteriores y nuevas**, una por archivo, incluidos los metadatos asociados. Su columna `revision_de_uso` permite localizar la reserva comprobada y los recursos con posible uso indirecto o de autoría.

## Árbol de carpetas

```text
UnderKingdom/
├── .git/
├── archivo/
│   ├── herramientas/
│   ├── mapas_viejos/          soporte de las escenas hechas a mano
│   └── tiles_v1/              código y objetos de la primera versión
├── audio/
│   └── narracion/
├── documentacion/
│   ├── desarrollo/
│   └── historial/
├── graficos/
│   ├── cinematicas/
│   ├── interfaz/
│   ├── mapas/prision/
│   ├── objetos/
│   ├── personajes/jugador/
│   ├── terceros/
│   ├── tipografias/
│   └── trampas/
├── herramientas/
│   ├── constructor_mapas/baldosas/
│   ├── fotogramas/
│   ├── macro_mapa/
│   └── zona_pruebas/
├── interfaces/
│   ├── dialogos/
│   ├── hud/
│   └── menu/
├── mapas/
│   ├── tng/                   escenas cuyo nombre empieza por tiles_
│   │   └── historicos/        mapas_viejos y tiles_v1
│   ├── tog/                   las demás escenas de mapa
│   │   ├── fondos/
│   │   ├── historicos/mapas_viejos/
│   │   ├── prologo_prision/
│   │   └── pruebas/
│   └── fuentes/
│       ├── macro/
│       ├── tng/historicos/
│       └── tog/               pruebas e historicos
├── narrativa/
│   ├── cinematicas/
│   └── dialogos/
├── objetos/
│   ├── entorno/
│   ├── equipo/
│   └── recogibles/
├── personajes/
│   ├── enemigos/
│   ├── jefes/
│   ├── jugador/
│   └── npc/
├── rd/
│   ├── animaciones/
│   ├── audio/
│   ├── dialogos/
│   ├── fondos/
│   ├── graficos/
│   ├── graficos_prueba/
│   ├── herramientas/
│   ├── otra_vez/
│   ├── prision/
│   ├── prueba/
│   └── .gdignore
├── sistemas/
│   ├── camara/
│   ├── combate/
│   ├── efectos/
│   ├── entorno/
│   ├── nucleo/
│   ├── proyectiles/
│   └── transiciones/
├── .editorconfig
├── .gitattributes
├── .gitignore
├── AGENTS.md
├── CLAUDE.md
├── ORGANIZACION.md
├── README.md
├── TASK.md
├── icon.svg
├── icon.svg.import
└── project.godot
```

El árbol muestra las carpetas funcionales. El inventario detalla las subcarpetas de cada paquete. Git, la configuración de Godot y el icono conservan sus ubicaciones en la raíz. Godot genera localmente la caché `.godot/`, que permanece ignorada por Git.

## Correspondencias principales

| Antes | Ahora |
| --- | --- |
| `escenas/mapas/tiles_*.tscn` | `mapas/tng/tiles_*.tscn` |
| `escenas/mapas/zona_pruebas*.tscn`, `prologo_prision/` y `fondos/` | `mapas/tog/pruebas/`, `mapas/tog/prologo_prision/` y `mapas/tog/fondos/` |
| `archivo/tiles_v1/escenas/tiles_*.tscn` y `archivo/mapas_viejos/escenas/tiles_casa.tscn` | `mapas/tng/historicos/` |
| Mapas hechos a mano y arenas históricas | `mapas/tog/historicos/mapas_viejos/` |
| `mapas_texto/` y fuentes de mapas históricos | `mapas/fuentes/`, en las familias `tng` y `tog` y en `macro` para las tablas |
| `escenas/player.tscn`, `escenas/prisn.tscn` y `scripts/player/` | `personajes/jugador/` |
| `escenas/enemigos/`, `escenas/jefes/`, `scripts/bosses/` y escena y código de NPC | `personajes/enemigos/`, `personajes/jefes/` y `personajes/npc/` |
| `scripts/core/`, `scripts/combat/`, `scripts/environment/`, `scripts/transitions/`, `scripts/fx/` y afines | `sistemas/`, por responsabilidad |
| Menús, HUD, barras, tema y caja de diálogo | `interfaces/`, con las texturas en `graficos/interfaz/` |
| `escenas/objetos/`, `escenas/items/`, `scripts/items/` y `escenas/atuendos/` | `objetos/entorno/`, `objetos/recogibles/` y `objetos/equipo/` |
| `escenas/cinematica/`, `scripts/cinematics/` y `dialogues/` | `narrativa/cinematicas/` y `narrativa/dialogos/` |
| `assets/cinematica/narracion_reina.mp3` | `audio/narracion/narracion_reina.mp3` |
| `assets/`, `sprites/` y `fuentes/` | `graficos/`, con subcarpetas por procedencia y función |
| `herramientas/sprites/` y `herramientas/constructor_mapas/tilesets/` | `herramientas/fotogramas/` y `herramientas/constructor_mapas/baldosas/` |
| `docs/` y `docs/historial/` | `documentacion/desarrollo/` y `documentacion/historial/` |
| `archivo/sin_uso/` | `rd/`, con gráficos, sonido, materiales y archivos de reserva |

Se actualizaron la escena principal, los autoloads, el tema, las referencias `res://`, las cargas por ruta, las rutas generadas por herramientas, los destinos de transición y los metadatos de autoría e importación. Se mantuvo la relación entre cada base de mapa y su escena `_combate`. El constructor elige la familia por el prefijo `tiles_` y excluye las subcarpetas históricas.

El formato de guardado sigue siendo **5**. Al cargar, `GameManager` resuelve las rutas anteriores hacia las nuevas. Al guardar, conserva las rutas e identificadores persistentes anteriores, incluidos los de objetos consumidos, checkpoints y reaparición. La clave histórica de la armería conserva su valor. [GameManager](sistemas/nucleo/game_manager.gd)

Los 19 archivos que cambiaron en la misma ubicación son `project.godot`, `CLAUDE.md`, `README.md`, `TASK.md`, `archivo/README.md`, `archivo/herramientas/fase2_auto.sh`, `herramientas/constructor_mapas/construir_mapa.gd` y sus ocho `atlas_*.py`, los tres scripts de `herramientas/macro_mapa/` y `herramientas/zona_pruebas/galeria.py`. El resto de las actualizaciones de archivos existentes acompaña a los traslados. El documento y el inventario son nuevos.

## Recursos sin uso directo y casos conservados

- **Reserva comprobada.** Se movieron 5 680 archivos de la carpeta ya excluida por Godot, incluidos recursos originales, licencias y archivos asociados. La búsqueda en escenas, scripts, configuración y herramientas de fuera de la reserva no encontró referencias a esos archivos por ruta de recurso ni por UID exclusivo. La reserva incluye hojas alternativas, ilustraciones, sonidos y música de Brackeys, un diálogo antiguo y una herramienta de diagnóstico. Se conservó el `.gdignore` que impide su importación.
- **Candidatos conservados.** La búsqueda literal dejó 105 recursos sin una referencia directa detectada. Entre ellos hay cuadros alternativos de Fire Knight, originales de sprites, materiales que consumen los generadores de atlas mediante rutas de archivo y escenas reutilizables de plataformas y zonas de quemadura. Permanecen en su grupo de trabajo. El inventario los marca con `posible_uso_indirecto_o_de_autoria` junto a sus metadatos.
- **Duplicado con referencias.** La copia de `Dungeon Tile Set.png` en `copia_prueba/` sigue referenciada por la prisión y por mapas antiguos. Se mantiene con su UID propio.
- **Escenas históricas.** Siguen importándose. Sus rutas aparecen en transiciones antiguas y pueden aparecer en perfiles guardados. El inventario P72 mantiene las rutas históricas como registro.

## Validación por bloques

Tras cada bloque se comprobó que todos los archivos originales seguían presentes, que sus UID coincidían y que las referencias literales de ejecución tenían destino.

| Bloque | Archivos trasladados |
| --- | ---: |
| Recursos gráficos, tipografías y audio | 1 290 |
| Sistemas, personajes, interfaces, objetos y narrativa | 243 |
| Mapas activos, fuentes y herramientas | 81 |
| Mapas históricos, soporte y reserva | 5 793 |
| Documentación | 67 |
| **Total** | **7 474** |

| Comprobación final | Resultado |
| --- | --- |
| Inventario y dependencias | 7 528 archivos originales conservados, 2 056 referencias literales `res://` resueltas y 3 524 UID conservados. |
| Comparación de contenido | 151 escenas con cambios limitados a rutas de recursos o de autoría. 22 cuadrículas ASCII, 26 archivos JSON y 3 402 archivos de arte, tipografías y audio conservan su contenido. |
| Mapas e importación | 59 escenas de mapa en su familia `tng` o `tog`. Se comprobaron 3 385 metadatos `.import` trasladados contra la nueva ruta de origen. |
| Importación y compilación en Godot 4.7 estable | Se importó desde caché vacía y se repitió la importación. Cargaron 151 escenas y 3 recursos `.tres` y compilaron 90 scripts importables. |
| Arranque sin ventana | Salieron con código 0 el menú, introducción, prólogo, zona de pruebas y las ocho escenas de campaña `_combate`. Se usaron 120 fotogramas por escena. |
| Compatibilidad de guardado | Se verificaron 61 destinos de escenas con perfiles sintéticos de formato 5, incluidas la resolución del destino de reaparición y la conservación de claves de objetos. |
| Herramientas de autoría | Generaron correctamente una escena TNG y una TOG, el recurso Fire Knight con 14 animaciones, los datos del atlas y la galería de pruebas. Se comprobó la sintaxis de los 13 scripts Python. |
| Atlas gráficos | Los ocho generadores con Pillow produjeron imágenes idénticas píxel a píxel en las copias anterior y reorganizada. |
| Verificador del macro mapa | 0 errores. Los tres avisos existentes corresponden a la distancia de los atajos `:B:`, `:C:` y `:F:`. |

Las comprobaciones de Godot y las pruebas que escriben escenas se ejecutaron en copias temporales. La primera importación registró mensajes de error transitorios durante la carga temprana de tipografías y texturas del tema antes de poblar la caché, tanto antes como después del traslado. La segunda importación y las cargas de recursos completaron sus comprobaciones. También se reprodujeron los diagnósticos anteriores del almacén de certificados, de `MapBounds` en el prólogo y de recursos retenidos al terminar la introducción desde la línea de comandos. Se usó el binario portátil oficial. [Godot 4.7 estable](https://godotengine.org/download/archive/4.7-stable/)

## Pruebas manuales pendientes

1. Abrir el proyecto en Godot 4.7 y comprobar visualmente el menú, la narración de la introducción y el cambio al prólogo.
2. Empezar una partida y pasar por Prisión, Calabozo y Castillo. Comprobar la recogida de la espada, la escalera, la rodada, la transición y la reaparición.
3. Cargar una partida anterior de formato 5 en la que ya se haya recogido un objeto. Confirmar el destino y que el objeto siga consumido. Comprobar el HUD y la pausa durante el recorrido.
