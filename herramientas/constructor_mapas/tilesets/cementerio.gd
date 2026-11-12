extends RefCounted

## Tileset del cementerio: el atlas de mazmorra (filas 0-15, sin cambios) más
## piezas de Gothicvania Cemetery (CC0) en las filas 16-19 y, desde P73 (ficha
## del cementerio), las filas 20-31 que arma
## herramientas/constructor_mapas/atlas_cementerio.py con piezas del Cemetery y
## de Gothic Horror (Legacy Collection, CC0); ver
## assets/terceros/gothicvania_cementerio/ORIGEN.txt. Mismas letras que
## mazmorra; cambian los bloques "cementerio" y los decorados T (lápida), g
## (pasto), r (zarzas) y E (calaveras). Además: el estilo de bloques "cripta"
## (sin pasto, con la repisa de piedra en "="), las paredes "tierra" y
## "ladrillo", y los decorados K, Q, D, O, A, n, U y V, con las letras del
## castillo. Coordenadas en piezas, no en píxeles.

const DATA := {
    "textura": "res://assets/terceros/gothicvania_cementerio/tileset_cementerio.png",
    "tile": 16,

    # Origen del juego de 4x4 piezas de cada estilo y de su rombo de rampas.
    # El juego de 4x4: esquinas, bordes e interior en 3x3, columna a la
    # derecha y plataformas en la fila de abajo.
    "bloques": {
        "verde": [Vector2i(0, 0), Vector2i(4, 2)],
        "verde_claro": [Vector2i(6, 0), Vector2i(10, 2)],
        "ladrillo": [Vector2i(12, 0), Vector2i(16, 2)],
        "violeta": [Vector2i(12, 4), Vector2i(16, 6)],
        "oro": [Vector2i(18, 0), Vector2i(22, 2)],
        "oliva": [Vector2i(18, 4), Vector2i(22, 6)],
        "madera": [Vector2i(16, 12), Vector2i(20, 14)],
        # Pasto arriba, tierra con calaveras en paredes y techos, interior
        # oscuro. Sin rampas propias: usa las de verde.
        "cementerio": [Vector2i(0, 16), Vector2i(4, 2)],
        # Lo de bajo tierra (P73): tierra con calaveras sin pasto, rampas de
        # verde y, como tercer elemento, sus plataformas: la repisa de piedra
        # de Gothic Horror (izquierda, medio, derecha), con colisión de una vía.
        "cripta": [Vector2i(0, 20), Vector2i(4, 2), Vector2i(4, 20)],
    },
    "bloques_por_defecto": "cementerio",

    # Decorados: letra -> [pieza de abajo a la izquierda, tamaño en piezas].
    "decorados": {
        "t": [Vector2i(0, 10), Vector2i(1, 1)],    # antorcha (animada)
        "f": [Vector2i(27, 4), Vector2i(1, 1)],    # fogata (animada)
        "b": [Vector2i(29, 9), Vector2i(1, 1)],    # barril
        "x": [Vector2i(26, 10), Vector2i(1, 1)],   # caja
        "h": [Vector2i(0, 15), Vector2i(1, 1)],    # hongos luminosos
        "g": [Vector2i(6, 18), Vector2i(1, 1)],    # puntas de pasto
        "r": [Vector2i(7, 18), Vector2i(1, 1)],    # zarzas secas
        "T": [Vector2i(4, 18), Vector2i(2, 3)],    # lápida
        "C": [Vector2i(24, 5), Vector2i(3, 2)],    # tienda de campaña
        # Ficha del cementerio (P73), filas 20-31 de atlas_cementerio.py.
        "E": [Vector2i(22, 22), Vector2i(2, 3)],   # calaveras amontonadas (Gothic Horror)
        "K": [Vector2i(18, 22), Vector2i(2, 3)],   # cruz de piedra (stone-2)
        "Q": [Vector2i(20, 22), Vector2i(2, 3)],   # lápida inclinada (stone-3)
        "D": [Vector2i(0, 31), Vector2i(11, 8)],   # árbol muerto (tree-2)
        "O": [Vector2i(11, 28), Vector2i(5, 5)],   # arbusto con cruz (bush-large)
        "A": [Vector2i(26, 22), Vector2i(2, 3)],   # gárgola (Gothic Horror)
        "n": [Vector2i(28, 21), Vector2i(2, 2)],   # calaveras en la pared (Gothic Horror)
        "U": [Vector2i(24, 22), Vector2i(2, 3)],   # arco con calavera cornuda (Gothic Horror)
        "V": [Vector2i(30, 23), Vector2i(2, 4)],   # nicho con llama (Gothic Horror; da luz)
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
    "escalera": Vector2i(4, 10),
    # Pieza que se dibuja en cada checkpoint (S): la fogata, como una hoguera.
    "checkpoint": Vector2i(27, 4),

    # Fondos de pared: nombre -> [origen del patrón, tamaño del patrón].
    "fondos": {
        "cueva": [Vector2i(24, 0), Vector2i(8, 4)],
        # P73: tierra con calaveras (lo excavado) y ladrillo con musgo de
        # Gothic Horror (lo construido), al 35 % y al 60 % de brillo.
        "tierra": [Vector2i(7, 20), Vector2i(4, 2)],
        "ladrillo": [Vector2i(11, 20), Vector2i(7, 3)],
    },
}
