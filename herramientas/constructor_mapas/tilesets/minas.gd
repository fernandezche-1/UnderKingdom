extends RefCounted

## Tileset de las minas (P73, ficha de las minas): el atlas de mazmorra (filas
## 0-15, sin cambios, por la antorcha, la fogata, la lava, los cristales y los
## hongos) más piezas de PixelFantasy Caves, el pack del parallax de las minas,
## a su escala, en las filas 16-19, y la escalera de madera del Dungeon Tile
## Set. Lo arma herramientas/constructor_mapas/atlas_minas.py; ver
## assets/terceros/pixelfantasy_caves/ORIGEN.txt. Mismas letras que mazmorra;
## cambian el bloque "minas" (la roca marrón), la viga de las plataformas, la
## escalera, el cofre (el del Mimic) y las paredes "galeria" (roca con el marco
## de postes y viga) y "ladrillo". Además, con letras del castillo: K
## (entibado, 3x3), U (boca de galería, 3x4), T (estalagmita, 3x4) e y
## (estalactita, 3x4, cuelga del techo). Coordenadas en piezas, no en píxeles.

const DATA := {
    "textura": "res://assets/terceros/pixelfantasy_caves/tileset_minas.png",
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
        # Roca marrón de PixelFantasy Caves, todas las piezas macizas. Las
        # minas no tienen rampas: quedan las de madera.
        "minas": [Vector2i(0, 16), Vector2i(20, 14)],
    },
    "bloques_por_defecto": "minas",

    # Plataformas de una vía (=): la viga de madera del pack (izquierda, medio,
    # derecha), con la colisión de una vía sin mirar sus esquinas.
    "plataformas": Vector2i(4, 16),

    # Cofre (c): el del Mimic, como el castillo y el cementerio (P73).
    "cofre": "res://escenas/objetos/cofre_madera.tscn",

    # Decorados: letra -> [pieza de abajo a la izquierda, tamaño en piezas].
    "decorados": {
        "t": [Vector2i(0, 10), Vector2i(1, 1)],    # antorcha (animada)
        "f": [Vector2i(27, 4), Vector2i(1, 1)],    # fogata (animada)
        "b": [Vector2i(29, 9), Vector2i(1, 1)],    # barril
        "x": [Vector2i(26, 10), Vector2i(1, 1)],   # caja
        "h": [Vector2i(0, 15), Vector2i(1, 1)],    # hongos luminosos
        "r": [Vector2i(22, 9), Vector2i(1, 1)],    # cristales
        "C": [Vector2i(24, 5), Vector2i(3, 2)],    # tienda de campaña
        # Ficha de las minas (P73), fila 16 de atlas_minas.py.
        "K": [Vector2i(16, 18), Vector2i(3, 3)],   # entibado: marco con aspa
        "U": [Vector2i(19, 19), Vector2i(3, 4)],   # boca de galería
        "T": [Vector2i(22, 19), Vector2i(3, 4)],   # estalagmita (props1)
        "y": [Vector2i(25, 19), Vector2i(3, 4)],   # estalactita (props1; cuelga)
    },

    # Piezas animadas: base -> [cuadros, columnas (0 = en fila), fps].
    "animadas": {
        Vector2i(0, 10): [4, 0, 8.0],    # antorcha
        Vector2i(27, 4): [4, 1, 8.0],    # fogata
        Vector2i(12, 8): [4, 0, 6.0],    # superficie de lava
        Vector2i(12, 9): [4, 0, 4.0],    # lava
        Vector2i(0, 11): [4, 0, 6.0],    # superficie del agua
        Vector2i(0, 12): [4, 0, 4.0],    # agua
    },

    # Líquidos: [superficie, cuerpo].
    "lava": [Vector2i(12, 8), Vector2i(12, 9)],
    "agua": [Vector2i(0, 11), Vector2i(0, 12)],
    # Escalera de madera del Dungeon Tile Set (la del calabozo).
    "escalera": Vector2i(7, 16),
    # Pieza que se dibuja en cada checkpoint (S): la fogata, como una hoguera.
    "checkpoint": Vector2i(27, 4),

    # Fondos de pared: nombre -> [origen del patrón, tamaño del patrón].
    "fondos": {
        "cueva": [Vector2i(24, 0), Vector2i(8, 4)],
        # P73: la roca con el marco de postes y viga (lo excavado) y el muro de
        # ladrillo (lo construido), al 60 % de brillo.
        "galeria": [Vector2i(8, 16), Vector2i(6, 4)],
        "ladrillo": [Vector2i(14, 16), Vector2i(2, 2)],
    },
}
