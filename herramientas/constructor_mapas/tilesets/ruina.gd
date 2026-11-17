extends RefCounted

## Tileset de la ruina helada (P73, ficha de la ruina): el atlas de mazmorra
## (filas 0-15, sin cambios, por la antorcha, la fogata, el agua, los
## cristales, los hongos, la estantería, la caja y el barril) más piezas de
## Caverns de la Legacy, el pack del parallax de la ruina, a su escala, en las
## filas 16-19, y la escalera de madera del Dungeon Tile Set. Lo arma
## herramientas/constructor_mapas/atlas_ruina.py; ver
## assets/terceros/gothicvania/ORIGEN.txt. Mismas letras que mazmorra; cambian
## el bloque "ruina" (el borde de cantos morados), la repisa de piedras de las
## plataformas, la escalera, el cofre (el del Mimic) y la pared "ruina" (el
## muro de ladrillo roto del pack). Además, con letras del castillo: V
## (hornacina con llama, 2x2, da luz), U (contrafuerte, 4x3) y n (pedruscos
## caídos, 2x2). Coordenadas en piezas, no en píxeles.

const DATA := {
    "textura": "res://assets/terceros/gothicvania/cavernas/tileset_ruina.png",
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
        # Cantos de Caverns, todas las piezas macizas. La ruina no tiene
        # rampas: quedan las de ladrillo.
        "ruina": [Vector2i(0, 16), Vector2i(16, 2)],
    },
    "bloques_por_defecto": "ruina",

    # Plataformas de una vía (=): la banda de piedras del suelo del pack, sin
    # el negro de debajo (izquierda, medio, derecha), con la colisión de una
    # vía sin mirar sus esquinas.
    "plataformas": Vector2i(4, 16),

    # Cofre (c): el del Mimic, como el castillo, el cementerio, las minas y la
    # mazmorra (P73).
    "cofre": "res://escenas/objetos/cofre_madera.tscn",

    # Decorados: letra -> [pieza de abajo a la izquierda, tamaño en piezas].
    "decorados": {
        "t": [Vector2i(0, 10), Vector2i(1, 1)],    # antorcha (animada)
        "f": [Vector2i(27, 4), Vector2i(1, 1)],    # fogata (animada)
        "b": [Vector2i(29, 9), Vector2i(1, 1)],    # barril
        "x": [Vector2i(26, 10), Vector2i(1, 1)],   # caja
        "h": [Vector2i(0, 15), Vector2i(1, 1)],    # hongos luminosos
        "r": [Vector2i(22, 9), Vector2i(1, 1)],    # cristales (el hielo)
        "E": [Vector2i(24, 15), Vector2i(3, 3)],   # estantería
        # Ficha de la ruina (P73), fila 16 de atlas_ruina.py.
        "V": [Vector2i(15, 17), Vector2i(2, 2)],   # hornacina con llama (da luz)
        "U": [Vector2i(17, 18), Vector2i(4, 3)],   # contrafuerte
        "n": [Vector2i(21, 17), Vector2i(2, 2)],   # pedruscos caídos
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
    # Escalera de madera del Dungeon Tile Set (la del calabozo, las minas y la
    # mazmorra).
    "escalera": Vector2i(7, 16),
    # Pieza que se dibuja en cada checkpoint (S): la fogata, como una hoguera.
    "checkpoint": Vector2i(27, 4),

    # Fondos de pared: nombre -> [origen del patrón, tamaño del patrón].
    "fondos": {
        "cueva": [Vector2i(24, 0), Vector2i(8, 4)],
        # P73: el muro de ladrillo roto del pasillo del pack (lo construido:
        # llegada, torre, pasillo, galerías, capilla, criptas, antesala, sala
        # del Guardián y cámaras).
        "ruina": [Vector2i(8, 16), Vector2i(7, 3)],
    },
}
