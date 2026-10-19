# Region de cavernas

Seis escenas nuevas y enlazadas, preparadas para ejecutarse con F6 desde Godot. La entrada desde el cementerio y la salida hacia las minas estan rotuladas como conexiones futuras; no apuntan a escenas inexistentes.

## Recorrido

`01_entrada_cavernas` -> `02_cavernas_naturales` -> `03_gruta_vertical` -> `04_caverna_de_los_ecos` -> `05_ruinas_subterraneas` -> `06_galeria_abandonada`.

Las puertas entre salas permiten regresar. La gruta vertical ofrece una rampa escalonada y terrazas opcionales. La sala 2 tiene una ruta alta con monedas. La sala 4 usa geodas geometricas cian hechas con `Polygon2D`, porque no se encontro un atlas de cristales ambientales. Hay checkpoints en las salas 2, 4 y 6.

## Recursos

- `tilesets/cavernas_tileset.tres`: TileSet local de celdas 16x16 con colision solida, plataformas unidireccionales y atlas decorativo. Usa `assets_prueba/dungeon_platformer/dungeontilesetfull.png` (512x256).
- Fondos y paredes de caverna de `assets_prueba/gothicvania/cavernas/` (192x288 y 512x288), usados como capas visuales/parallax. No sustituyen la geometria jugable.
- `scripts/generador_sala_caverna.gd`: genera las celdas de las cuatro TileMapLayer y actualiza los limites de camara. El script es exclusivo de esta carpeta.
- Se reutilizan las escenas del jugador (instanciado por el controlador existente), transiciones, checkpoints, monedas y dos enemigos comunes. No se alteran sus escenas ni scripts.

El atlas de `prueba/PixelFantasy_Caves_1.0/` mide 1024-1280 px por lado, pero el proyecto no define sus celdas ni colisiones; sus piezas tienen otra escala y no se mezclaron con el terreno 16x16. No se encontro un set de cristales de escenario. El enemigo Crystal Mauler es un personaje, no una pieza de decoracion, por lo que no se uso como geoda.

## Comprobacion

Se comprobaron estaticamente las rutas de recursos, destinos de transicion y spawn IDs. No se encontro Godot en el entorno; falta comprobar en el editor la carga visual, las colisiones y el recorrido completo. Abre cualquiera de las seis escenas y usa F6 para probarla.
