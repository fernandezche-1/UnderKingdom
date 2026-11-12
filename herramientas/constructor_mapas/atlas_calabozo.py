"""Arma el atlas del tileset "calabozo" (P73, ficha del calabozo).

assets/terceros/dungeon_tile_set/tileset_calabozo.png, 512x384, piezas de 16:
- filas 0-19: copia de las filas 0-19 de
  assets/terceros/raou_castillo/tileset_castillo.png (atlas de mazmorra en
  0-15 y piezas de Raou en 16-19: rejas, estantería, armadura, pared
  "castillo"), para que las letras sigan valiendo; las 20-23 del castillo, que
  arma atlas_castillo.py, no se copian;
- filas 20-23: piezas del Dungeon Tile Set (el pack de la prisión) y la
  antorcha de Raou, recortadas sin repintar. Coordenadas en LAYOUT, abajo;
  herramientas/constructor_mapas/tilesets/calabozo.gd las usa.

Uso, desde la raíz del proyecto:
  python3 herramientas/constructor_mapas/atlas_calabozo.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
CASTILLO = ROOT / "assets/terceros/raou_castillo/tileset_castillo.png"
DTS = ROOT / "assets/terceros/dungeon_tile_set/Dungeon Tile Set.png"
TORCH = ROOT / "assets/terceros/dungeon_sidescroller-Raou/spr_torch.png"
OUT = ROOT / "assets/terceros/dungeon_tile_set/tileset_calabozo.png"
T = 16

# Destino en el atlas (pieza de arriba a la izquierda) de cada grupo.
LAYOUT = {
    "bloques": (0, 20),     # juego de 4x4
    "viga": (4, 20),        # izquierda, medio, derecha
    "escalera": (7, 20),
    "fondo": (8, 20),       # 7x2
    "antorcha": (15, 20),   # 4 cuadros en fila
    "cadena": (19, 20),     # 1x2
    "jaula": (20, 20),      # 2x2
    "barril": (22, 20),
    "caja": (23, 20),
    "rejilla": (24, 20),    # 2x2
    "telarana": (26, 20),   # 4x1
}


def tile(img, tx, ty, w=1, h=1):
    return img.crop((tx * T, ty * T, (tx + w) * T, (ty + h) * T))


def place(atlas, piece, dest, dx=0, dy=0):
    atlas.alpha_composite(piece, (dest[0] * T + dx, dest[1] * T + dy))


def main():
    castillo = Image.open(CASTILLO).convert("RGBA")
    assert castillo.size == (512, 384), castillo.size
    # Solo las filas 0-19: las 20-23 del castillo son suyas (atlas_castillo.py).
    atlas = Image.new("RGBA", castillo.size)
    atlas.paste(castillo.crop((0, 0, castillo.width, 20 * T)), (0, 0))
    dts = Image.open(DTS).convert("RGBA")
    torch = Image.open(TORCH).convert("RGBA")

    # Bloques: el bloque de piedra de 3x3 del pack, piezas (1,1)-(3,3), tal
    # cual. La columna (3, *) une la mitad izquierda de la pieza izquierda con
    # la derecha de la derecha; las tiras (*, 3), la mitad de arriba de la
    # pieza de arriba con la de abajo de la de abajo; (3, 3), las 4 esquinas.
    bx, by = LAYOUT["bloques"]
    src = {(i, j): tile(dts, 1 + i, 1 + j) for i in range(3) for j in range(3)}
    for (i, j), p in src.items():
        place(atlas, p, (bx + i, by + j))
    half = T // 2
    for j in range(3):
        p = Image.new("RGBA", (T, T))
        p.paste(src[(0, j)].crop((0, 0, half, T)), (0, 0))
        p.paste(src[(2, j)].crop((half, 0, T, T)), (half, 0))
        place(atlas, p, (bx + 3, by + j))
    for i in range(3):
        p = Image.new("RGBA", (T, T))
        p.paste(src[(i, 0)].crop((0, 0, T, half)), (0, 0))
        p.paste(src[(i, 2)].crop((0, half, T, T)), (0, half))
        place(atlas, p, (bx + i, by + 3))
    p = Image.new("RGBA", (T, T))
    p.paste(src[(0, 0)].crop((0, 0, half, half)), (0, 0))
    p.paste(src[(2, 0)].crop((half, 0, T, half)), (half, 0))
    p.paste(src[(0, 2)].crop((0, half, half, T)), (0, half))
    p.paste(src[(2, 2)].crop((half, half, T, T)), (half, half))
    place(atlas, p, (bx + 3, by + 3))

    # Viga de madera (1,9)-(3,9), escalera (5,9) (la pieza con peldaños que se
    # repite sin costura) y pared de fondo (6,6)-(12,7), 7x2.
    place(atlas, tile(dts, 1, 9, 3, 1), LAYOUT["viga"])
    place(atlas, tile(dts, 5, 9), LAYOUT["escalera"])
    place(atlas, tile(dts, 6, 6, 7, 2), LAYOUT["fondo"])

    # Antorcha de Raou: 4 cuadros de 21x27; la llama y el palo caben en
    # 7x16 (x 7-14, y 4-20, igual en los 4). Centrada en la pieza.
    ax, ay = LAYOUT["antorcha"]
    for i in range(4):
        frame = torch.crop((i * 21 + 7, 4, i * 21 + 14, 20))
        place(atlas, frame, (ax + i, ay), (T - frame.width) // 2, 0)

    # Decorados recortados por su borde. Los que cuelgan, pegados arriba y
    # centrados de lado; los del suelo, tal cual (ya apoyan abajo).
    def hanging(region, dest, w, h):
        crop = dts.crop(region)
        crop = crop.crop(crop.getbbox())
        assert crop.width <= w * T and crop.height <= h * T, (region, crop.size)
        place(atlas, crop, dest, (w * T - crop.width) // 2, 0)

    hanging((2 * T, 12 * T, 3 * T, 14 * T), LAYOUT["cadena"], 1, 2)   # cadena larga
    hanging((7 * T, 12 * T, 10 * T, 14 * T), LAYOUT["jaula"], 2, 2)   # jaula, 19x32
    place(atlas, tile(dts, 10, 12), LAYOUT["barril"])
    place(atlas, tile(dts, 10, 10), LAYOUT["caja"])
    place(atlas, tile(dts, 10, 3, 2, 2), LAYOUT["rejilla"])
    place(atlas, tile(dts, 10, 14, 4, 1), LAYOUT["telarana"])

    atlas.save(OUT)
    print("atlas:", OUT.relative_to(ROOT), atlas.size)


if __name__ == "__main__":
    main()
