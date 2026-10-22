# Ruta inicial: calabozo y castillo

Escenas editables para Godot 4.7.2:

- `escape_calabozo.tscn`: entrada prevista desde la C?mara con el spawn `DesdeCamara`; salida a `interior_castillo.tscn` usando `DesdeCalabozo`.
- `interior_castillo.tscn`: entrada `DesdeCalabozo`; salida a `tiles_cementerio_combate.tscn` usando el spawn existente `SpawnInicio`.
- `tileset_dungeon_platformer.tres`: TileSet de 16?16 para `prueba/Dungeon Tile Set.png`. Solo las regiones opacas de mamposter?a se definieron como tiles; las piezas grandes de escalera, cadenas, cajas y pinchos se dibujan con regiones de atlas como decoraci?n.
- `tileset_dark_castle.tres`: TileSet de 16?16 para `dark_castle_tileset.png`; los paneles de pared se usan como mamposter?a, y las regiones grandes de ventana/arco/puerta se colocan como sprites de atlas. Las muestras inferiores del atlas no se usan como terreno.

## Prueba individual

Abre el proyecto en Godot 4.7.2, selecciona cada escena y pulsa **F6**. El controlador de spawn existente crea el jugador si no hay uno en la escena. Revisa especialmente las zonas de salto y que el atlas se vea n?tido con el filtrado pixel art del proyecto.

El flujo global queda pendiente de validaci?n: la cinem?tica se conserva sin cambios. Despu?s de probar ambas escenas, conecta su transici?n `SalidaPrision` al archivo `escape_calabozo.tscn` con destino `DesdeCamara`; el castillo ya sale al cementerio existente.

## Saltos base considerados

El jugador actual usa `jump_velocity = -560` y `gravity = 1500`, que da una altura bal?stica te?rica cercana a 104 px. Las diferencias obligatorias de nivel son de 16?48 px y los huecos principales tienen un m?ximo de 48 px; el ascenso por escalera es opcional.
