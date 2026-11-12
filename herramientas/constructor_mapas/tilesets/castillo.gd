extends RefCounted

## Tileset del castillo: el atlas de mazmorra (filas 0-15, sin cambios) más
## piezas del muro de ladrillo de Raou y decorados de castillo en las filas
## 16-19 y, desde P73 (ficha del castillo), las piezas de las filas 20-23 que
## arma herramientas/constructor_mapas/atlas_castillo.py; ver
## assets/terceros/raou_castillo/ORIGEN.txt. Mismas letras que mazmorra;
## cambian el bloque "castillo", la pared de fondo "castillo" (con pilastras),
## las plataformas (tablón de madera), el cofre (el del Mimic) y los decorados
## T (armadura), h (estandarte rojo), g (cadena), r (ventana), C (puerta en
## arco), E (estantería) y f (rejas de celda, en vez de la fogata). Letras
## propias: A (armero), D (trofeo), O (provisiones) y Q (cuadro); y, desde la
## ficha revisada, w (ventana de celosía), K (columna), U (tapiz), l
## (estantería alta), n (mesa), y (lámpara) y V (mostrador), más una pared por
## sala para fondo_sala. Coordenadas en piezas, no en píxeles.

const DATA := {
    "textura": "res://assets/terceros/raou_castillo/tileset_castillo.png",
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
        # Ladrillo morado con losas claras arriba e interior negro. Las rampas
        # de Raou no son macizas, así que usa las de violeta.
        "castillo": [Vector2i(0, 16), Vector2i(16, 6)],
    },
    "bloques_por_defecto": "castillo",

    # Plataformas de una vía (=): el tablón de madera de Raou (izquierda,
    # medio, derecha). No tiene las esquinas opacas; el constructor le da la
    # colisión de una vía sin mirarlas.
    "plataformas": Vector2i(0, 20),

    # Cofre (c): el del Mimic, para que el Mimic de más abajo sorprenda.
    "cofre": "res://escenas/objetos/cofre_madera.tscn",

    # Decorados: letra -> [pieza de abajo a la izquierda, tamaño en piezas].
    "decorados": {
        "t": [Vector2i(0, 10), Vector2i(1, 1)],    # antorcha (animada)
        "f": [Vector2i(17, 17), Vector2i(2, 2)],   # rejas de celda
        "b": [Vector2i(29, 9), Vector2i(1, 1)],    # barril
        "x": [Vector2i(26, 10), Vector2i(1, 1)],   # caja
        "T": [Vector2i(8, 17), Vector2i(2, 2)],    # armadura
        "h": [Vector2i(9, 21), Vector2i(1, 2)],    # estandarte rojo de craftpix (cuelga del techo)
        "g": [Vector2i(11, 17), Vector2i(1, 2)],   # cadena (cuelga del techo)
        "r": [Vector2i(19, 17), Vector2i(2, 2)],   # ventana en arco
        "C": [Vector2i(13, 18), Vector2i(2, 3)],   # puerta en arco
        "E": [Vector2i(15, 17), Vector2i(2, 2)],   # estantería
        "A": [Vector2i(10, 22), Vector2i(2, 3)],   # armero con espadas (craftpix)
        "D": [Vector2i(12, 22), Vector2i(3, 3)],   # trofeo: cráneo de dragón (craftpix)
        "O": [Vector2i(15, 22), Vector2i(2, 3)],   # estante con provisiones (craftpix)
        "Q": [Vector2i(17, 21), Vector2i(2, 2)],   # cuadro (Raou)
        # Ficha revisada (P73): decorados de Raou para que cada sala se note.
        "w": [Vector2i(3, 29), Vector2i(3, 3)],    # ventana de celosía (vidriera de la capilla)
        "K": [Vector2i(30, 30), Vector2i(2, 7)],   # columna alta
        "U": [Vector2i(6, 29), Vector2i(2, 3)],    # tapiz
        "l": [Vector2i(8, 29), Vector2i(2, 3)],    # estantería alta
        "n": [Vector2i(12, 27), Vector2i(2, 1)],   # mesa con frascos
        "y": [Vector2i(14, 27), Vector2i(1, 1)],   # lámpara (cuelga del techo)
        "V": [Vector2i(10, 28), Vector2i(2, 2)],   # mostrador con frascos
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
        # Pared de Raou con una pilastra cada 6 columnas.
        "castillo": [Vector2i(3, 20), Vector2i(6, 3)],
        # Paredes de cada sala (fondo_sala), de Raou; las arma atlas_castillo.py.
        "piedra_oscura": [Vector2i(0, 24), Vector2i(3, 3)],
        "piedra": [Vector2i(3, 24), Vector2i(3, 3)],
        "piedra_clara": [Vector2i(6, 24), Vector2i(3, 3)],
        "madera": [Vector2i(9, 24), Vector2i(3, 3)],
        "madera_oscura": [Vector2i(12, 24), Vector2i(3, 3)],
        "columnas": [Vector2i(15, 24), Vector2i(3, 3)],
        "marco": [Vector2i(18, 24), Vector2i(3, 3)],
        "arcada": [Vector2i(21, 24), Vector2i(6, 8)],
        "ladrillo": [Vector2i(27, 24), Vector2i(3, 3)],
        "libros": [Vector2i(0, 27), Vector2i(3, 3)],
    },
}
