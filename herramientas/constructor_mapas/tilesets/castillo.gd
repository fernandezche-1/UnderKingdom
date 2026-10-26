extends RefCounted

## Tileset del castillo: el atlas de mazmorra (filas 0-15, sin cambios) más
## piezas del muro de ladrillo de Raou y decorados de castillo en las filas
## 16-19, ver assets_prueba/raou_castillo/ORIGEN.txt. Mismas letras que
## mazmorra; cambian el bloque "castillo", la pared de fondo "castillo" y los
## decorados T (armadura), h (estandarte), g (cadena), r (ventana), C (puerta
## en arco), E (estantería) y f (rejas de celda, en vez de la fogata). Coordenadas en piezas, no en píxeles.

const DATA := {
    "textura": "res://assets_prueba/raou_castillo/tileset_castillo.png",
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

    # Decorados: letra -> [pieza de abajo a la izquierda, tamaño en piezas].
    "decorados": {
        "t": [Vector2i(0, 10), Vector2i(1, 1)],    # antorcha (animada)
        "f": [Vector2i(17, 17), Vector2i(2, 2)],   # rejas de celda
        "b": [Vector2i(29, 9), Vector2i(1, 1)],    # barril
        "x": [Vector2i(26, 10), Vector2i(1, 1)],   # caja
        "T": [Vector2i(8, 17), Vector2i(2, 2)],    # armadura
        "h": [Vector2i(10, 17), Vector2i(1, 2)],   # estandarte (cuelga del techo)
        "g": [Vector2i(11, 17), Vector2i(1, 2)],   # cadena (cuelga del techo)
        "r": [Vector2i(19, 17), Vector2i(2, 2)],   # ventana en arco
        "C": [Vector2i(13, 18), Vector2i(2, 3)],   # puerta en arco
        "E": [Vector2i(15, 17), Vector2i(2, 2)],   # estantería
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
        "castillo": [Vector2i(4, 16), Vector2i(1, 3)],
    },
}
