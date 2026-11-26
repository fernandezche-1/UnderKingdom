extends RefCounted

## Tileset de la mazmorra de la Reina (P73, ficha de la mazmorra): el atlas de
## mazmorra (filas 0-15, sin cambios, por la antorcha, la fogata, la lava, el
## agua, la estantería, la caja, el barril, los cristales y los hongos) más
## piezas del tileset Old Dark Castle interior de la Legacy, el pack del
## parallax de la mazmorra, a su escala, en las filas 16-19, la escalera de
## madera del Dungeon Tile Set y la reja de celda de Raou. Lo arma
## herramientas/constructor_mapas/atlas_mazmorra_reina.py; ver
## graficos/terceros/gothicvania/ORIGEN.txt. Mismas letras que mazmorra; cambian
## el bloque "mazmorra_reina" (la piedra verde con el remate de musgo), la
## pasarela de las plataformas, la escalera, el cofre (el del Mimic) y las
## paredes "piedra" (ladrillo verde oscuro con pilastra) y "cloaca" (la misma,
## oscurecida). Además, con letras del castillo: g (cadena, 1x4, cuelga del
## techo), U (arco del desagüe, 6x3) y w (reja de celda, 2x2). Coordenadas en
## piezas, no en píxeles.

const DATA := {
    "textura": "res://graficos/terceros/gothicvania/castillo_viejo/tileset_mazmorra_reina.png",
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
        # Piedra verde del Old Dark Castle, todas las piezas macizas. La
        # mazmorra no tiene rampas: quedan las de oliva.
        "mazmorra_reina": [Vector2i(0, 16), Vector2i(22, 6)],
    },
    "bloques_por_defecto": "mazmorra_reina",

    # Plataformas de una vía (=): la pasarela de madera del pack (izquierda,
    # medio, derecha), con la colisión de una vía sin mirar sus esquinas.
    "plataformas": Vector2i(4, 16),

    # Cofre (c): el del Mimic, como el castillo, el cementerio y las minas (P73).
    "cofre": "res://objetos/entorno/cofre_madera.tscn",

    # Decorados: letra -> [pieza de abajo a la izquierda, tamaño en piezas].
    "decorados": {
        "t": [Vector2i(0, 10), Vector2i(1, 1)],    # antorcha (animada)
        "f": [Vector2i(27, 4), Vector2i(1, 1)],    # fogata (animada)
        "b": [Vector2i(29, 9), Vector2i(1, 1)],    # barril
        "x": [Vector2i(26, 10), Vector2i(1, 1)],   # caja
        "h": [Vector2i(0, 15), Vector2i(1, 1)],    # hongos luminosos
        "r": [Vector2i(22, 9), Vector2i(1, 1)],    # cristales
        "E": [Vector2i(24, 15), Vector2i(3, 3)],   # estantería
        # Ficha de la mazmorra (P73), fila 16 de atlas_mazmorra_reina.py.
        "g": [Vector2i(20, 19), Vector2i(1, 4)],   # cadena (cuelga del techo)
        "U": [Vector2i(21, 18), Vector2i(6, 3)],   # arco del desagüe
        "w": [Vector2i(27, 17), Vector2i(2, 2)],   # reja de celda (Raou)
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
    # Escalera de madera del Dungeon Tile Set (la del calabozo y las minas).
    "escalera": Vector2i(7, 16),
    # Pieza que se dibuja en cada checkpoint (S): la fogata, como una hoguera.
    "checkpoint": Vector2i(27, 4),

    # Fondos de pared: nombre -> [origen del patrón, tamaño del patrón].
    "fondos": {
        "cueva": [Vector2i(24, 0), Vector2i(8, 4)],
        # P73: el ladrillo verde oscuro con su pilastra (celdas, torre, cuerpo
        # de guardia, llegada, antesala y sala de tortura) y el mismo,
        # oscurecido (desagües, fosa, huida y pozos).
        "piedra": [Vector2i(8, 16), Vector2i(6, 4)],
        "cloaca": [Vector2i(14, 16), Vector2i(6, 4)],
    },
}
