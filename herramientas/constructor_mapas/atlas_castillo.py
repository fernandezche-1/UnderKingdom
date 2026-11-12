"""Arma las filas 20-23 del atlas del tileset "castillo" (P73, ficha del castillo).

assets/terceros/raou_castillo/tileset_castillo.png, 512x384, piezas de 16:
- filas 0-19: no se tocan (atlas de mazmorra en 0-15 y piezas de Raou en
  16-19, ver assets/terceros/raou_castillo/ORIGEN.txt); las escenas que ya
  usan el atlas se ven igual;
- filas 20-23: se borran y se vuelven a poner con las piezas de LAYOUT,
  recortadas de Tilesetv3.png de Raou y del pack de craftpix sin repintar.
  herramientas/constructor_mapas/tilesets/castillo.gd las usa.

Se puede correr las veces que haga falta: el resultado es el mismo.
atlas_calabozo.py toma solo las filas 0-19 de este atlas.

Uso, desde la raíz del proyecto:
  python3 herramientas/constructor_mapas/atlas_castillo.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets/terceros/raou_castillo/tileset_castillo.png"
RAOU = ROOT / "assets/terceros/dungeon_sidescroller-Raou/Tilesetv3.png"
CRAFTPIX = ROOT / "assets/terceros/craftpix-net-218281-free-pixel-art-dungeon-objects-asset-pack/PNG"
OTHER = CRAFTPIX / "Other_objects.png"
SUPPLIES = CRAFTPIX / "supplies_objects.png"
T = 16
FIRST_ROW = 20

# Destino en el atlas (pieza de arriba a la izquierda) y tamaño en piezas.
LAYOUT = {
    "tablon": ((0, 20), (3, 1)),       # izquierda, medio, derecha
    "pared": ((3, 20), (6, 3)),        # 5 columnas lisas y la pilastra
    "estandarte": ((9, 20), (1, 2)),
    "armero": ((10, 20), (2, 3)),
    "trofeo": ((12, 20), (3, 3)),
    "provisiones": ((15, 20), (2, 3)),
    "cuadro": ((17, 20), (2, 2)),
}


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
    atlas = Image.open(OUT).convert("RGBA")
    assert atlas.size == (512, 384), atlas.size
    # Borra las filas 20-23 para rehacerlas.
    atlas.paste(Image.new("RGBA", (atlas.width, atlas.height - FIRST_ROW * T)), (0, FIRST_ROW * T))
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

    atlas.save(OUT)
    print("atlas:", OUT.relative_to(ROOT), atlas.size)


if __name__ == "__main__":
    main()
