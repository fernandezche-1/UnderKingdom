extends RefCounted

## Tileset del calabozo (P73, ficha del calabozo): el atlas del castillo (filas
## 0-19: mazmorra y piezas de Raou) más piezas del Dungeon Tile Set, el pack de
## la prisión, en las filas 20-23. Lo arma
## herramientas/constructor_mapas/atlas_calabozo.py; ver
## assets/terceros/dungeon_tile_set/ORIGEN.txt. Mismas letras que castillo;
## cambian el bloque "calabozo", la pared de fondo "calabozo", la viga de las
## plataformas, la escalera y los decorados t (antorcha de Raou), g (cadena),
## h (jaula colgante, 2x2), b (barril), x (caja), r (rejilla del desagüe) y
## C (telaraña, 4x1). f (rejas de celda), E (estantería) y T (armadura) siguen
## las del castillo. Coordenadas en piezas, no en píxeles.

const DATA := {
    "textura": "res://assets/terceros/dungeon_tile_set/tileset_calabozo.png",
    "tile": 16,

    # Origen del juego de 4x4 piezas de cada estilo y de su rombo de rampas.
    # El juego de 4x4: esquinas, bordes e interior en 3x3, columna a la
    # derecha y tiras de una pieza en la fila de abajo.
    "bloques": {
        "verde": [Vector2i(0, 0), Vector2i(4, 2)],
        "verde_claro": [Vector2i(6, 0), Vector2i(10, 2)],
        "ladrillo": [Vector2i(12, 0), Vector2i(16, 2)],
        "violeta": [Vector2i(12, 4), Vector2i(16, 6)],
        "oro": [Vector2i(18, 0), Vector2i(22, 2)],
        "oliva": [Vector2i(18, 4), Vector2i(22, 6)],
        "madera": [Vector2i(16, 12), Vector2i(20, 14)],
        "castillo": [Vector2i(0, 16), Vector2i(16, 6)],
        # Piedra gris azulada del Dungeon Tile Set, todas las piezas macizas.
        # El calabozo no tiene rampas: quedan las de violeta.
        "calabozo": [Vector2i(0, 20), Vector2i(16, 6)],
    },
    "bloques_por_defecto": "calabozo",

    # Plataformas de una vía (=): la viga de madera del pack (izquierda, medio,
    # derecha) en lugar de la fila de tiras del juego de bloques. Es fina y no
    # tiene las esquinas opacas, así que el constructor le da la colisión de
    # una vía sin mirarlas.
    "plataformas": Vector2i(4, 20),

    # Decorados: letra -> [pieza de abajo a la izquierda, tamaño en piezas].
    "decorados": {
        "t": [Vector2i(15, 20), Vector2i(1, 1)],   # antorcha de Raou (animada)
        "f": [Vector2i(17, 17), Vector2i(2, 2)],   # rejas de celda
        "b": [Vector2i(22, 20), Vector2i(1, 1)],   # barril
        "x": [Vector2i(23, 20), Vector2i(1, 1)],   # caja
        "T": [Vector2i(8, 17), Vector2i(2, 2)],    # armadura
        "h": [Vector2i(20, 21), Vector2i(2, 2)],   # jaula (cuelga del techo)
        "g": [Vector2i(19, 21), Vector2i(1, 2)],   # cadena (cuelga del techo)
        "r": [Vector2i(24, 21), Vector2i(2, 2)],   # rejilla redonda del desagüe
        "C": [Vector2i(26, 20), Vector2i(4, 1)],   # telaraña (cuelga del techo)
        "E": [Vector2i(15, 17), Vector2i(2, 2)],   # estantería
    },

    # Piezas animadas: base -> [cuadros, columnas (0 = en fila), fps].
    "animadas": {
        Vector2i(0, 10): [4, 0, 8.0],    # antorcha de mazmorra
        Vector2i(15, 20): [4, 0, 8.0],   # antorcha de Raou
        Vector2i(27, 4): [4, 1, 8.0],    # fogata
        Vector2i(12, 8): [4, 0, 6.0],    # superficie de lava
        Vector2i(12, 9): [4, 0, 4.0],    # lava
        Vector2i(0, 11): [4, 0, 6.0],    # superficie del agua
        Vector2i(0, 12): [4, 0, 4.0],    # agua
    },

    # Líquidos: [superficie, cuerpo].
    "lava": [Vector2i(12, 8), Vector2i(12, 9)],
    "agua": [Vector2i(0, 11), Vector2i(0, 12)],
    # Escalera de madera del pack (la pieza con peldaños, que se repite).
    "escalera": Vector2i(7, 20),
    # Pieza que se dibuja en cada checkpoint (S): la fogata, como una hoguera.
    "checkpoint": Vector2i(27, 4),

    # Fondos de pared: nombre -> [origen del patrón, tamaño del patrón].
    "fondos": {
        "cueva": [Vector2i(24, 0), Vector2i(8, 4)],
        "castillo": [Vector2i(4, 16), Vector2i(1, 3)],
        # Pared oscura del pack, piezas (6,6)-(12,7): se repite sin costura.
        "calabozo": [Vector2i(8, 20), Vector2i(7, 2)],
    },
}
