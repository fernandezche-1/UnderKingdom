# Castillo oscuro editable

Abre `res://escenas/mapas/prologo/castillo_oscuro.tscn`. La escena guarda el mapa completo; el nodo raíz ya no tiene el generador asociado.

- `Terreno` y `Plataformas`: tiles de 8×8 con colisión en capa física 1. Su desplazamiento vertical de 6 px conserva las alturas exactas del recorrido anterior. Los atlas contienen la apariencia original de las plataformas, incluidos los bordes y juntas. Pinta o borra sus celdas para cambiar tanto el dibujo como la colisión. Los pequeños fragmentos que sobresalen lateralmente son juntas decorativas sin colisión.
- `Arquitectura`: selecciona las subcapas de ventanas, estandartes y arco para pintar tiles de 16×16 del atlas Dark Castle. Se usa una copia local ampliada del TileSet, sin modificar el recurso compartido por otros mapas. Columnas, capiteles, bases y umbral siguen siendo nodos editables con sus medidas originales.
- `Fondo`: fondo y juntas de mampostería originales como nodos editables. Incluye el TileSet Dark Castle para añadir tiles.
- `Decoracion`: antorchas animadas y luces originales. Cada antorcha tiene `autoplay = fuego`.
- `PrimerPlano`: los cinco pinchos originales.
- `ElementosInteractivos`: diez monedas y la zona de daño, conservando sus escenas y scripts.

Las capas que contienen objetos también permiten añadir tiles Dark Castle sin colisión. Sus nodos hijos se seleccionan y mueven directamente. Guarda con Ctrl+S; ningún generador sobrescribe estos cambios al jugar.

El Player original continúa apareciendo mediante `ControladorSpawn`, como antes. Se conservan los dos puntos de aparición, límites, cámara y salida al cementerio. No se cambiaron los controles, HUD, combate, otros mapas ni `project.godot`.

Los PNG `plataforma_*.png` son copias nuevas del dibujo procedural anterior. El TileSet guarda esas imágenes internamente para que no dependa de su importación. Ningún PNG original fue modificado. Dungeon Platformer y Tilesetv3 se revisaron, pero no se utilizan porque el generador original no los usaba y sustituir el dibujo alteraría el diseño.

Respaldos exactos anteriores a la conversión:

- `res://escenas/mapas/prologo/castillo_oscuro.before_editable_20261022.tscn`
- `res://scripts/environment/dark_castle_map.before_editable_20261022.gd`

El script original sigue intacto y desconectado. `tools/bake_castillo_oscuro.gd` es una herramienta manual de conversión histórica: **no la ejecutes después de editar**, porque restaura el diseño del respaldo. No se ejecuta al abrir ni jugar el mapa.

Validación reproducible: Godot `--headless --path . --script tools/validate_castillo_editable.gd`. Comprueba carga desde disco, capas, celdas válidas, apariencia exacta de plataformas, colisiones sin duplicación, física real, hueco central, posiciones de aparición y cantidad de objetos. No reemplaza una prueba manual del combate o del HUD.
