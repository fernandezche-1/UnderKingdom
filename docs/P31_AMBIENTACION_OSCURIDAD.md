# P31 - Ambientación: oscuridad, luces y viñeta

- Nuevo script `scripts/environment/map_ambience.gd` (`UnderkingdomMapAmbience`). Se pone como nodo hijo de la raíz de la escena `_combate` de cada mundo, nunca en la base generada, para que sobreviva a regenerar el mapa.
- Primer uso: nodo `Ambientacion` en `tiles_cementerio_combate.tscn`. Las minas todavía no lo tienen.

## Qué hace al cargar el mapa

- **Oscuridad:** crea un `CanvasModulate` con `ambient_color` (cementerio: azul violáceo `(0.42, 0.42, 0.58)`). Oscurece tiles, parallax, enemigos y Player. El HUD, la barra de jefe, los diálogos y los menús van en `CanvasLayer` propios y no se oscurecen.
- **Luz del Player:** un `PointLight2D` hijo del Player, llamado `LuzAmbiente` y colocado a la altura de su `CollisionShape2D`.
- **Luces del mapa:** recorre la capa `Decorado` y pone una luz en cada pieza que brilla, según su coordenada en el atlas (`DECOR_LIGHTS`):
  - antorcha `(0,10)` y fogata/checkpoint `(27,4)`, cálidas y con parpadeo;
  - hongos `(0,15)` en cian y cristales `(22,9)` en violeta, fijas.
- **Lava:** en la capa `Liquidos`, una luz cada 3 piezas de superficie `(12,8)`.
- **Llave del jefe:** al aparecer un nodo del grupo `boss_key`, se le añade una luz dorada.
- **Halos:** cada luz del mapa lleva un `Sprite2D` aditivo con anillos de pixel art (`z_index = -1`: detrás del terreno y de los personajes, delante del fondo). Sin él, la luz casi no se vería en el cementerio, porque detrás de las antorchas suele haber cielo o relleno oscuro.
- **Viñeta:** un `CanvasLayer` en la capa 5, por debajo del HUD (10) y por encima del aviso de la sala de jefe (9). Lleva un shader que oscurece los bordes, calculado por píxel de 480x270 y en 6 escalones.

## Notas

- Las luces no tocan los fondos con parallax (`lights_on_backgrounds = false`), que solo se tiñen. Así se evitan antorchas que iluminan montañas lejanas y se respeta el límite de Compatibility de 8 luces por objeto (`rendering/limits/opengl/max_lights_per_object`).
- Las texturas de luz y halo se generan por código, un texel por píxel del juego, y se reutilizan por radio. No hay arte nuevo.
- Todo se ajusta desde el inspector del nodo `Ambientacion`: color de ambiente, radio, color y energía de la luz del Player, parpadeo, intensidad y tamaño del halo, y fuerza, inicio y color de la viñeta.
- Para otro mundo: añadir un `Node2D` con este script a su escena `_combate` y cambiar `ambient_color`. Las piezas nuevas que den luz se añaden a `DECOR_LIGHTS`.

## Pendiente

- Ajuste de brillo en el menú de pausa, para monitores oscuros.
- Ambientación de los mundos siguientes, cada vez más oscuros conforme se baja. Las minas ya la tienen: nodo `Ambientacion` en `tiles_mineria_combate.tscn` con `ambient_color` `(0.3, 0.28, 0.36)`, más oscuro y terroso que el cementerio, luz del Player de 112 px y viñeta 0.6. Encienden 39 luces (antorchas, fogatas y lava de la veta ardiente).
- Niebla y partículas (polvo, brasas) por mundo.
