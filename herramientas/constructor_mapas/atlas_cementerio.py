"""Arma las filas 20-31 del atlas del tileset "cementerio" (P73, ficha del cementerio).

assets/terceros/gothicvania_cementerio/tileset_cementerio.png, piezas de 16:
- filas 0-19: no se tocan (atlas de mazmorra en 0-15 y piezas de Gothicvania
  Cemetery en 16-19, ver assets/terceros/gothicvania_cementerio/ORIGEN.txt);
  las escenas que ya usan el atlas se ven igual;
- filas 20-31: se borran y se vuelven a poner con las piezas de LAYOUT, de
  Gothicvania Cemetery y de Gothic Horror (Legacy Collection), todo CC0 de
  Ansimuz, sin repintar. Agrandan el atlas de 512x320 a 512x512.
  herramientas/constructor_mapas/tilesets/cementerio.gd las usa.

Se puede correr las veces que haga falta: el resultado es el mismo.

Uso, desde la raíz del proyecto:
  python3 herramientas/constructor_mapas/atlas_cementerio.py
"""
from pathlib import Path

from PIL import Image, ImageEnhance

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "assets/terceros/gothicvania_cementerio/tileset_cementerio.png"
CEM = ROOT / "assets/terceros/gothicvania_cementerio/tileset_original.png"
OBJ = ROOT / "assets/terceros/gothicvania_cementerio/objetos"
HORROR = ROOT / "assets/terceros/gothicvania/gothic_horror/tiles.png"
T = 16
FIRST_ROW = 20

# Destino en el atlas (pieza de arriba a la izquierda) y tamaño en piezas.
LAYOUT = {
    "cripta": ((0, 20), (4, 4)),       # juego de bloques sin pasto
    "repisa": ((4, 20), (3, 1)),       # izquierda, medio, derecha
    "tierra": ((7, 20), (4, 2)),       # pared de lo excavado
    "ladrillo": ((11, 20), (7, 3)),    # pared de lo construido
    "cruz": ((18, 20), (2, 3)),        # K
    "lapida": ((20, 20), (2, 3)),      # Q
    "calaveras": ((22, 20), (2, 3)),   # E
    "arco": ((24, 20), (2, 3)),        # U
    "gargola": ((26, 20), (2, 3)),     # A
    "huesos": ((28, 20), (2, 2)),      # n
    "nicho": ((30, 20), (2, 4)),       # V
    "arbol": ((0, 24), (11, 8)),       # D
    "arbusto": ((11, 24), (5, 5)),     # O
}
# Tierra con calaveras del pack, sin pasto (tileset.png, fila 5).
EARTH = [(4, 5), (5, 5), (6, 5), (7, 5)]
# Brillo de las paredes de fondo, como "libros" del castillo.
WALL_BRIGHTNESS = 0.6
# La pared "tierra" va más oscura: al vestir el cementerio, al 60 % no se
# distinguía de los bloques "cripta", que usan la misma tierra (P73).
EARTH_WALL_BRIGHTNESS = 0.35
# Fachada con musgo de Gothic Horror: 7 x 3 piezas que se repiten sin costura
# (de lado cada 7 columnas; en vertical, cada 16 px, la altura de dos hiladas).
BRICK = (34, 8)


def tile(img, tx, ty, w=1, h=1):
    return img.crop((tx * T, ty * T, (tx + w) * T, (ty + h) * T))


def place(atlas, piece, dest, dx=0, dy=0):
    atlas.alpha_composite(piece, (dest[0] * T + dx, dest[1] * T + dy))


def dark(img, brightness=WALL_BRIGHTNESS):
    rgb = ImageEnhance.Brightness(img.convert("RGB")).enhance(brightness)
    return rgb.convert("RGBA")


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
    assert old.width == 512 and old.height in (320, 512), old.size
    # Filas 0-19 tal cual; las 20-31 se rehacen.
    atlas = Image.new("RGBA", (512, 512))
    atlas.paste(old.crop((0, 0, 512, FIRST_ROW * T)), (0, 0))
    cem = Image.open(CEM).convert("RGBA")
    horror = Image.open(HORROR).convert("RGBA")

    # Juego de bloques "cripta" (4x4, como el de "cementerio" en (0,16)): la
    # fila de arriba y la de tiras, con la tierra con calaveras del pack sin
    # pasto; los lados, la tierra del pack; el interior oscuro y la fila de
    # abajo (techos), las del juego "cementerio" (filas 17-18). Todas macizas.
    cx, cy = LAYOUT["cripta"][0]
    for i, (sx, sy) in enumerate(EARTH):
        place(atlas, tile(cem, sx, sy), (cx + i, cy))        # arriba y columna
        place(atlas, tile(cem, sx, sy), (cx + i, cy + 3))    # tiras y pieza suelta
    place(atlas, tile(cem, *EARTH[2]), (cx, cy + 1))          # lado izquierdo
    place(atlas, tile(old, 1, 17), (cx + 1, cy + 1))          # interior
    place(atlas, tile(cem, *EARTH[0]), (cx + 2, cy + 1))      # lado derecho
    place(atlas, tile(cem, *EARTH[1]), (cx + 3, cy + 1))      # columna, medio
    for i in range(4):
        place(atlas, tile(old, i, 18), (cx + i, cy + 2))      # abajo y columna

    # Repisa de piedra de Gothic Horror (2,1)-(6,1): izquierda, medio, derecha.
    rx, ry = LAYOUT["repisa"][0]
    for i, sx in enumerate((2, 3, 6)):
        place(atlas, tile(horror, sx, 1), (rx + i, ry))

    # Pared "tierra": la tierra del pack en dos filas, la segunda con la fila
    # de abajo del juego "cementerio" (sin pasto), oscurecida.
    wall = Image.new("RGBA", (4 * T, 2 * T))
    for i, (sx, sy) in enumerate(EARTH):
        wall.alpha_composite(tile(cem, sx, sy), (i * T, 0))
        wall.alpha_composite(tile(old, i, 18), (i * T, T))
    place(atlas, dark(wall, EARTH_WALL_BRIGHTNESS), LAYOUT["tierra"][0])

    # Pared "ladrillo": la fachada con musgo de Gothic Horror, oscurecida.
    dest, (w, h) = LAYOUT["ladrillo"]
    place(atlas, dark(tile(horror, *BRICK, w, h)), dest)

    # Decorados, recortados por su borde, sin repintar.
    fit(atlas, Image.open(OBJ / "stone-2.png").convert("RGBA"), (0, 0, 27, 40), "cruz", "abajo")
    fit(atlas, Image.open(OBJ / "stone-3.png").convert("RGBA"), (0, 0, 27, 33), "lapida", "abajo")
    fit(atlas, Image.open(OBJ / "tree-2.png").convert("RGBA"), (0, 0, 166, 117), "arbol", "abajo")
    fit(atlas, Image.open(OBJ / "bush-large.png").convert("RGBA"), (0, 0, 76, 65), "arbusto", "abajo")
    fit(atlas, horror, (128, 96, 160, 144), "calaveras", "abajo")   # calaveras amontonadas, 32x45
    fit(atlas, horror, (224, 112, 256, 160), "arco", "abajo")       # arco con calavera cornuda, 32x48
    fit(atlas, horror, (448, 32, 488, 80), "gargola", "centro")     # gárgola sin el muro de la casa
    fit(atlas, horror, (32, 112, 64, 144), "huesos", "abajo")       # calaveras en la pared, 32x32
    fit(atlas, horror, (272, 96, 304, 160), "nicho", "abajo")       # nicho con llama, 32x64

    atlas.save(OUT)
    print("atlas:", OUT.relative_to(ROOT), atlas.size)


if __name__ == "__main__":
    main()
