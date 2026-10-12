# P26 — Ruta provisional de prueba entre mapas

Esta ruta existe únicamente para recorrer los mapas actuales y detectar errores de colisión, cámara, enemigos, navegación y spawns antes de cerrar la progresión definitiva.

## Secuencia de archivos usada

1. `res://escenas/mundo 1.tscn` — Entrada al reino / cementerio.
2. `res://escenas/primer boss mundo1.tscn` — Castillo / primer encuentro de boss.
3. `res://escenas/mundo_2.tscn` — siguiente región disponible.
4. `res://escenas/mundo3.tscn` — siguiente región disponible.
5. `res://escenas/ruina.tscn` — Ruinas.
6. `res://escenas/profundidades.tscn` — Profundidades.
7. `res://escenas/jefe.tscn` — zona final / boss final provisional.

## Convención visual de transiciones

- Azul: avanzar.
- Morado: regresar.
- Verde: One Way.
- Rojo/rosa: muerte instantánea o peligro letal.
- Blanco: daño progresivo de 1/4 de corazón.
- Amarillo: puertas internas/teletransportes dentro de un mismo mapa.

Los portales provisionales azul/morado se activan con `E`.

## Progresión narrativa prevista

Mundo 1 / Cementerio -> Castillo / primer boss -> Mundo 2 / Cavernas -> Mundo 3 / Minas abandonadas -> Ruinas antiguas -> Mazmorras -> Profundidades -> Zona final -> Cthulhu -> Final.

Actualmente no existe una escena independiente claramente separada para Mazmorras dentro de la secuencia de archivos principal; durante la auditoría se decidirá qué escena actual corresponde mejor o si debe crearse una escena adicional.

## Imágenes/mapas repetidos

Cuando existan referencias visuales repetidas por cambios de diseño, la ruta usa la escena `.tscn` actual más completa. No se eliminan las variantes o assets alternativos durante esta fase de prueba.
