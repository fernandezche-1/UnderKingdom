# Camara del Sellado del Alma

Escena independiente del prologo, preparada para una cinematica posterior. Abre `camara_sellado_alma.tscn` y ejecutala con **F6 (Ejecutar escena actual)** para revisar el encuadre. No se cambio la escena principal del proyecto.

## Recursos y escala

- `tile/Dungeon Tile Set.png` (240 x 288 px), usada como atlas de celdas de 16 x 16 px. La hoja aporta mamposteria gotica, arcos, una ventana enrejada y cadenas.
- `tileset_prision.tres` separa los muros de fondo y el terreno; las celdas del piso tienen colision.
- El portal de hierro y el circulo ritual son geometria editable de Godot (Polygon2D y Line2D), sin imagen conceptual ni fondo prerenderizado.
- Resolucion interna del proyecto: 480 x 270. La sala mide 1024 x 416 px y la camara encuadra a los dos marcadores centrales.

## Marcadores

`MarcadoresCinematica` contiene al protagonista encadenado, la Reina del Agua, dos anclajes, el centro ritual y la entrada y salida. `EncuadresCamara` contiene los puntos de plano de dialogo y ritual. Los sprites originales estan en `Elementals_fire_knight_FREE_v1.1/.../fire_knight.png` y `Elementals_water_priestess_FREE_v1.1/.../water_priestess.png`; esta escena no altera ni instancia las animaciones del jugador.
