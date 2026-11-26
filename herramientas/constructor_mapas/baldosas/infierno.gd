extends RefCounted

## Tileset del infierno (P73, ficha del infierno): el atlas de mazmorra (filas
## 0-15, sin cambios, por la lava animada, la antorcha y la fogata) más, en las
## filas 16-24, Living Tissue de la Legacy (la carne con colmillos y ojos, sin
## teñir), el ladrillo rojo de las profundidades y la escalera de madera del
## Dungeon Tile Set. Lo arma herramientas/constructor_mapas/atlas_infierno.py;
## ver graficos/terceros/gothicvania/ORIGEN.txt. Cambian el bloque "carne", la
## repisa de carne de las plataformas, la escalera, el cofre (el del Mimic) y
## las paredes "carne" (el fondo del pack) y "ladrillo". Decorados: t y f de
## mazmorra y, con letras de otros tilesets, y (colmillos que cuelgan, 3x3),
## r (ojo, 2x2, da luz verde), n (pústula, 2x2) y U (herida, 3x2). Coordenadas
## en piezas, no en píxeles.

const DATA := {
    "textura": "res://graficos/terceros/gothicvania/tejido_vivo/tileset_infierno.png",
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
        # Carne de Living Tissue, todas las piezas macizas. El infierno no
        # tiene rampas: quedan las de ladrillo.
        "carne": [Vector2i(0, 16), Vector2i(16, 2)],
    },
    "bloques_por_defecto": "carne",

    # Plataformas de una vía (=): el canto del suelo de carne sin el relleno
    # de debajo (izquierda, medio, derecha), con la colisión de una vía sin
    # mirar sus esquinas.
    "plataformas": Vector2i(4, 16),

    # Cofre (c): el del Mimic, como en las zonas de arriba (P73).
    "cofre": "res://objetos/entorno/cofre_madera.tscn",

    # Decorados: letra -> [pieza de abajo a la izquierda, tamaño en piezas].
    "decorados": {
        "t": [Vector2i(0, 10), Vector2i(1, 1)],    # antorcha (animada)
        "f": [Vector2i(27, 4), Vector2i(1, 1)],    # fogata (animada)
        # Ficha del infierno (P73), filas 16-24 de atlas_infierno.py.
        "y": [Vector2i(24, 18), Vector2i(3, 3)],   # colmillos (cuelgan: la letra, tres piezas bajo el techo)
        "r": [Vector2i(27, 17), Vector2i(2, 2)],   # ojo (da luz verde)
        "n": [Vector2i(29, 17), Vector2i(2, 2)],   # pústula
        "U": [Vector2i(17, 19), Vector2i(3, 2)],   # herida
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
    # Escalera de madera del Dungeon Tile Set (la de las zonas de arriba).
    "escalera": Vector2i(7, 16),
    # Pieza que se dibuja en cada checkpoint (S): la fogata, como una hoguera.
    "checkpoint": Vector2i(27, 4),

    # Fondos de pared: nombre -> [origen del patrón, tamaño del patrón].
    "fondos": {
        "cueva": [Vector2i(24, 0), Vector2i(8, 4)],
        # P73: el fondo de Living Tissue, 9x9 (el fondo de la zona).
        "carne": [Vector2i(8, 16), Vector2i(9, 9)],
        # P73: el ladrillo rojo de las profundidades (lo construido: coliseo de
        # los condenados y salón de los verdugos).
        "ladrillo": [Vector2i(17, 16), Vector2i(7, 2)],
    },
}
