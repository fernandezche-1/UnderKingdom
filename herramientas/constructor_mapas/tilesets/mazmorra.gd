extends RefCounted

## Tileset "2D Dungeon Platformer Tileset" (CC0, assets_prueba/dungeon_platformer/).
## Para agregar otro tileset: copiar este archivo con otro nombre, cambiar la
## textura y las coordenadas de las piezas, y elegirlo en el mapa con
## "tileset: <nombre del archivo>". Coordenadas en piezas, no en píxeles.

const DATA := {
    "textura": "res://assets_prueba/dungeon_platformer/dungeontilesetfull.png",
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
    },
    "bloques_por_defecto": "oro",

    # Decorados: letra -> [pieza de abajo a la izquierda, tamaño en piezas].
    "decorados": {
        "t": [Vector2i(0, 10), Vector2i(1, 1)],    # antorcha (animada)
        "f": [Vector2i(27, 4), Vector2i(1, 1)],    # fogata (animada)
        "b": [Vector2i(29, 9), Vector2i(1, 1)],    # barril
        "x": [Vector2i(26, 10), Vector2i(1, 1)],   # caja
        "h": [Vector2i(0, 15), Vector2i(1, 1)],    # hongos luminosos
        "g": [Vector2i(3, 4), Vector2i(1, 1)],     # pasto
        "r": [Vector2i(22, 9), Vector2i(1, 1)],    # cristales
        "T": [Vector2i(5, 9), Vector2i(2, 3)],     # árbol verde
        "E": [Vector2i(24, 15), Vector2i(3, 3)],   # estantería
        "C": [Vector2i(24, 5), Vector2i(3, 2)],    # tienda de campaña
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

    # Fondos de pared: nombre -> [origen del patrón, tamaño del patrón].
    "fondos": {
        "cueva": [Vector2i(24, 0), Vector2i(8, 4)],
    },
}
