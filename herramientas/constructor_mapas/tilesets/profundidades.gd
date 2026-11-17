extends RefCounted

## Tileset de las profundidades (P73, ficha de las profundidades): el atlas de
## mazmorra (filas 0-15, sin cambios, por la lava animada, la antorcha, la
## fogata, los cristales, la caja y el barril) más, en las filas 16-21, los
## cantos de Caverns de la Legacy en su morado (el de las rocas del parallax
## de lava; la ruina usa las mismas formas teñidas de frío), el ladrillo, el
## horno y el arco de Gothic Horror teñidos de rojo, su montón de calaveras y
## la escalera de madera del Dungeon Tile Set. Lo arma
## herramientas/constructor_mapas/atlas_profundidades.py; ver
## assets/terceros/gothicvania/ORIGEN.txt. Mismas letras que mazmorra; cambian
## el bloque "profundidades", la repisa de piedras de las plataformas, la
## escalera, el cofre (el del Mimic) y las paredes "basalto" (los cantos,
## oscurecidos) y "ladrillo". Además, con letras del castillo: V (horno con
## chimenea, 2x6, da luz), U (arco con cara de demonio, 2x3) y n (montón de
## calaveras, 2x3). Coordenadas en piezas, no en píxeles.

const DATA := {
    "textura": "res://assets/terceros/gothicvania/lava/tileset_profundidades.png",
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
        # Cantos de Caverns, todas las piezas macizas. Las profundidades no
        # tienen rampas: quedan las de ladrillo.
        "profundidades": [Vector2i(0, 16), Vector2i(16, 2)],
    },
    "bloques_por_defecto": "profundidades",

    # Plataformas de una vía (=): la banda de piedras del suelo del pack, sin
    # el negro de debajo (izquierda, medio, derecha), con la colisión de una
    # vía sin mirar sus esquinas.
    "plataformas": Vector2i(4, 16),

    # Cofre (c): el del Mimic, como en las zonas de arriba (P73).
    "cofre": "res://escenas/objetos/cofre_madera.tscn",

    # Decorados: letra -> [pieza de abajo a la izquierda, tamaño en piezas].
    "decorados": {
        "t": [Vector2i(0, 10), Vector2i(1, 1)],    # antorcha (animada)
        "f": [Vector2i(27, 4), Vector2i(1, 1)],    # fogata (animada)
        "b": [Vector2i(29, 9), Vector2i(1, 1)],    # barril
        "x": [Vector2i(26, 10), Vector2i(1, 1)],   # caja
        "r": [Vector2i(22, 9), Vector2i(1, 1)],    # cristales (las ascuas)
        # Ficha de las profundidades (P73), filas 16-21 de atlas_profundidades.py.
        "V": [Vector2i(17, 21), Vector2i(2, 6)],   # horno con chimenea (da luz)
        "U": [Vector2i(19, 18), Vector2i(2, 3)],   # arco con cara de demonio
        "n": [Vector2i(21, 18), Vector2i(2, 3)],   # montón de calaveras
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
        # P73: los cantos de Caverns, oscurecidos (el fondo de la zona:
        # galería de los condenados, pie de :E:, llegada, pasos, túnel,
        # encrucijada, antesala y pozos).
        "basalto": [Vector2i(8, 16), Vector2i(2, 4)],
        # P73: el ladrillo de Gothic Horror teñido de rojo (lo construido:
        # forja, coliseo, sala del Demon Slime y cámara del altar del fuego).
        "ladrillo": [Vector2i(10, 16), Vector2i(7, 2)],
    },
}
