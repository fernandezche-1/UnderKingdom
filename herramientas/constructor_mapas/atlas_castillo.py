"""Arma las filas 20-23 del atlas del tileset "castillo" (P73, ficha del castillo).

assets/terceros/raou_castillo/tileset_castillo.png, 512x384, piezas de 16:
- filas 0-19: no se tocan (atlas de mazmorra en 0-15 y piezas de Raou en
  16-19, ver assets/terceros/raou_castillo/ORIGEN.txt); las escenas que ya
  usan el atlas se ven igual. Solo se borra el estandarte viejo de
  (10,16)-(10,17), de origen sin anotar, que la letra h ya no usa desde que
  se vistió el castillo;
- filas 20-31: se borran y se vuelven a poner con las piezas de LAYOUT,
  recortadas de Tilesetv3.png de Raou y del pack de craftpix sin repintar.
  herramientas/constructor_mapas/tilesets/castillo.gd las usa. Las 24-31
  (paredes de fondo de cada sala) agrandaron el atlas de 512x384 a 512x512.

Se puede correr las veces que haga falta: el resultado es el mismo.
atlas_calabozo.py toma solo las filas 0-19 de este atlas.

Uso, desde la raíz del proyecto:
  python3 herramientas/constructor_mapas/atlas_castillo.py
"""
from pathlib import Path

from PIL import Image, ImageEnhance

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets/terceros/raou_castillo/tileset_castillo.png"
RAOU = ROOT / "assets/terceros/dungeon_sidescroller-Raou/Tilesetv3.png"
CRAFTPIX = ROOT / "assets/terceros/craftpix-net-218281-free-pixel-art-dungeon-objects-asset-pack/PNG"
OTHER = CRAFTPIX / "Other_objects.png"
SUPPLIES = CRAFTPIX / "supplies_objects.png"
T = 16
FIRST_ROW = 20
# Estandarte viejo de dark_castle_tileset.png (pieza de arriba, tamaño).
OLD_BANNER = ((10, 16), (1, 2))

# Destino en el atlas (pieza de arriba a la izquierda) y tamaño en piezas.
LAYOUT = {
    "tablon": ((0, 20), (3, 1)),       # izquierda, medio, derecha
    "pared": ((3, 20), (6, 3)),        # 5 columnas lisas y la pilastra
    "estandarte": ((9, 20), (1, 2)),
    "armero": ((10, 20), (2, 3)),
    "trofeo": ((12, 20), (3, 3)),
    "provisiones": ((15, 20), (2, 3)),
    "cuadro": ((17, 20), (2, 2)),
    # Paredes de fondo de las salas (fondo_sala), filas 24-31.
    "piedra_oscura": ((0, 24), (3, 3)),
    "piedra": ((3, 24), (3, 3)),
    "piedra_clara": ((6, 24), (3, 3)),
    "madera": ((9, 24), (3, 3)),
    "madera_oscura": ((12, 24), (3, 3)),
    "columnas": ((15, 24), (3, 3)),
    "marco": ((18, 24), (3, 3)),
    "arcada": ((21, 24), (6, 8)),
    "ladrillo": ((27, 24), (3, 3)),
    "libros": ((0, 27), (3, 3)),
    # Decorados de la ficha revisada (Raou), filas 24-31.
    "celosia": ((3, 27), (3, 3)),
    "tapiz": ((6, 27), (2, 3)),
    "estanteria": ((8, 27), (2, 3)),
    "mostrador": ((10, 27), (2, 2)),
    "mesa": ((12, 27), (2, 1)),
    "lampara": ((14, 27), (1, 1)),
    "columna": ((30, 24), (2, 7)),
}

# De dónde sale cada pared en Tilesetv3.png (pieza de arriba a la izquierda).
# Se repiten sin costura de lado y en vertical cada 3 filas (la arcada, cada 8).
WALLS = {
    "piedra_oscura": (11, 20),   # bloques de piedra, los más oscuros
    "piedra": (8, 20),           # bloques de piedra medios
    "piedra_clara": (5, 20),     # bloques de piedra claros
    "madera": (8, 17),           # ladrillo con postes y baranda de madera
    "madera_oscura": (14, 17),   # la misma, más oscura
    "columnas": (5, 17),         # ladrillo con una columna de piedra
    "marco": (8, 14),            # ladrillo con marco de piedra clara
    "arcada": (10, 28),          # dos pisos de arcos
    "ladrillo": (5, 14),         # ladrillo claro con juntas verticales
}
# Pared de la biblioteca: la estantería alta (0,34)-(1,36) sobre la madera
# oscura, con el brillo bajado para que no se confunda con los tablones.
BOOKS_WALL = (14, 17)
BOOKCASE = (0, 34)
BOOKS_BRIGHTNESS = 0.6
# Fondo de los huecos transparentes de la arcada (el negro de sus bandas).
ARCH_DARK = (6, 6, 6, 255)


def tile(img, tx, ty, w=1, h=1):
    return img.crop((tx * T, ty * T, (tx + w) * T, (ty + h) * T))


def place(atlas, piece, dest, dx=0, dy=0):
    atlas.alpha_composite(piece, (dest[0] * T + dx, dest[1] * T + dy))


def fit(atlas, img, region, name, align):
    """Recorta region por su borde y la pone en el hueco de name, centrada de
    lado; align: "arriba" (cuelga), "abajo" (apoya) o "centro" (en la pared)."""
    crop = img.crop(region)
    crop = crop.crop(crop.getbbox())
    dest, (w, h) = LAYOUT[name]
    assert crop.width <= w * T and crop.height <= h * T, (name, crop.size)
    dx = (w * T - crop.width) // 2
    dy = {"arriba": 0, "abajo": h * T - crop.height, "centro": (h * T - crop.height) // 2}[align]
    place(atlas, crop, dest, dx, dy)


def main():
    old = Image.open(OUT).convert("RGBA")
    assert old.width == 512 and old.height in (384, 512), old.size
    # Filas 0-19 tal cual; las 20-31 se rehacen.
    atlas = Image.new("RGBA", (512, 512))
    atlas.paste(old.crop((0, 0, 512, FIRST_ROW * T)), (0, 0))
    # Borra el estandarte viejo (P73, castillo vestido).
    (bx, by), (bw, bh) = OLD_BANNER
    atlas.paste(Image.new("RGBA", (bw * T, bh * T)), (bx * T, by * T))
    raou = Image.open(RAOU).convert("RGBA")
    other = Image.open(OTHER).convert("RGBA")
    supplies = Image.open(SUPPLIES).convert("RGBA")

    # Tablón de madera (7,8)-(9,8): plataformas "=" (clave "plataformas").
    place(atlas, tile(raou, 7, 8, 3, 1), LAYOUT["tablon"][0])

    # Pared de fondo: la pared lisa de hoy, (12,14)-(12,16), cinco veces, y la
    # pilastra (12,17)-(12,19), que tiene las mismas hiladas a los lados.
    px, py = LAYOUT["pared"][0]
    for i in range(5):
        place(atlas, tile(raou, 12, 14, 1, 3), (px + i, py))
    place(atlas, tile(raou, 12, 17, 1, 3), (px + 5, py))

    # Decorados de craftpix y Raou, recortados por su borde.
    fit(atlas, other, (14 * T, 4 * T, 15 * T, 7 * T), "estandarte", "arriba")  # rojo pequeño, 15x19
    fit(atlas, supplies, (64, 472, 96, 505), "armero", "abajo")               # espadas, 32x33
    fit(atlas, other, (7, 5, 41, 48), "trofeo", "centro")                     # cráneo de dragón, 34x43
    fit(atlas, supplies, (146, 10, 175, 55), "provisiones", "abajo")          # estante, 29x45
    fit(atlas, raou, (51, 690, 76, 717), "cuadro", "centro")                  # paisaje, 25x27

    # Paredes de fondo de las salas, opacas (la arcada tiene los arcos huecos).
    for name, (sx, sy) in WALLS.items():
        dest, (w, h) = LAYOUT[name]
        wall = Image.new("RGBA", (w * T, h * T), ARCH_DARK)
        wall.alpha_composite(tile(raou, sx, sy, w, h))
        place(atlas, wall, dest)
    dest, (w, h) = LAYOUT["libros"]
    wall = Image.new("RGBA", (w * T, h * T), ARCH_DARK)
    wall.alpha_composite(tile(raou, *BOOKS_WALL, w, h))
    wall.alpha_composite(tile(raou, *BOOKCASE, 2, 3))
    rgb = ImageEnhance.Brightness(wall.convert("RGB")).enhance(BOOKS_BRIGHTNESS)
    wall = rgb.convert("RGBA")
    place(atlas, wall, dest)

    # Decorados de la ficha revisada, de Tilesetv3.png (píxeles), sin repintar.
    fit(atlas, raou, (208, 624, 256, 672), "celosia", "centro")     # ventana de celosía, 38x41
    fit(atlas, raou, (80, 416, 112, 464), "tapiz", "centro")        # tapiz, 32x48
    fit(atlas, raou, (0, 544, 32, 592), "estanteria", "abajo")      # estantería alta, 26x48
    fit(atlas, raou, (128, 592, 160, 624), "mostrador", "abajo")    # mostrador con frascos, 26x21
    fit(atlas, raou, (32, 608, 64, 624), "mesa", "abajo")           # mesa con frascos, 24x16
    fit(atlas, raou, (32, 560, 48, 576), "lampara", "arriba")       # lámpara colgante
    fit(atlas, raou, (80, 32, 112, 144), "columna", "abajo")        # columna alta, 32x109

    atlas.save(OUT)
    print("atlas:", OUT.relative_to(ROOT), atlas.size)


if __name__ == "__main__":
    main()
