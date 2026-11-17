"""Arma el atlas del tileset "profundidades" (P73, ficha de las profundidades).

assets/terceros/gothicvania/lava/tileset_profundidades.png, 512x352, piezas de 16:
- filas 0-15: copia del atlas de mazmorra
  (assets/terceros/dungeon_platformer/dungeontilesetfull.png), por la lava
  animada, la antorcha, la fogata, los cristales (las ascuas), la caja y el
  barril; sus coordenadas no cambian, así que DECOR_LIGHTS de
  scripts/environment/map_ambience.gd sigue valiendo;
- filas 16-21: piezas de Caverns de la Legacy (cavernas/tiles.png) en su
  morado original, el de las rocas del parallax de lava (la ruina usa las
  mismas formas teñidas de frío); el ladrillo, el horno y el arco de Gothic
  Horror (gothic_horror/tiles.png) teñidos de rojo; el montón de calaveras de
  Gothic Horror tal cual, y la escalera de madera del Dungeon Tile Set.
  Coordenadas en LAYOUT, abajo; herramientas/constructor_mapas/tilesets/
  profundidades.gd las usa.

Se puede correr las veces que haga falta: el resultado es el mismo.

Uso, desde la raíz del proyecto:
  python3 herramientas/constructor_mapas/atlas_profundidades.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
MAZMORRA = ROOT / "assets/terceros/dungeon_platformer/dungeontilesetfull.png"
CAVERNS = ROOT / "assets/terceros/gothicvania/cavernas/tiles.png"
HORROR = ROOT / "assets/terceros/gothicvania/gothic_horror/tiles.png"
DTS = ROOT / "assets/terceros/dungeon_tile_set/Dungeon Tile Set.png"
OUT = ROOT / "assets/terceros/gothicvania/lava/tileset_profundidades.png"
T = 16

# Destino en el atlas (pieza de arriba a la izquierda) de cada grupo.
LAYOUT = {
    "bloques": (0, 16),      # juego de 4x4
    "plataformas": (4, 16),  # izquierda, medio, derecha
    "escalera": (7, 16),
    "basalto": (8, 16),      # pared, 2x4
    "ladrillo": (10, 16),    # pared, 7x2
    "horno": (17, 16),       # V, 2x6 (filas 16-21; da luz)
    "arco": (19, 16),        # U, 2x3
    "calaveras": (21, 16),   # n, 2x3
    # Pared agrietada del secreto (P48): la columna del juego de bloques tres
    # veces, 1x3, para escenas/objetos/pared_agrietada_profundidades.tscn.
    "pared_agrietada": (23, 16),
}

# Juego de bloques: el de la ruina (atlas_ruina.py), sin tinte. Arriba, el
# suelo con piedras (fila 15); a los lados, los cantos de los laterales
# (columnas 7 y 23); abajo, el techo con flecos (fila 5). Solo celdas macizas.
TOP, LEFT, RIGHT, BOTTOM = (2, 15), (7, 2), (23, 2), (12, 5)
EDGES = {
    (0, 0): TOP, (1, 0): TOP, (2, 0): TOP, (3, 0): TOP,
    (0, 1): LEFT, (2, 1): RIGHT,
    (0, 2): BOTTOM, (1, 2): BOTTOM, (2, 2): BOTTOM, (3, 2): BOTTOM,
}
# El interior del pack es casi negro, del color del hueco de la cueva: la roca
# se leería como un hueco. El interior es la textura de cantos del lateral
# izquierdo, oscurecida, como en la ruina.
INTERIOR = LEFT
INTERIOR_BRIGHTNESS = 0.55
# Color plano del interior del pack: pasa a transparente bajo las piedras de
# las plataformas.
FLAT = {(25, 14, 27), (26, 15, 28), (27, 16, 29)}
LEDGE = (2, 15)
# Pared "basalto": los cantos de los dos laterales, filas 1-4, más oscuros
# que el interior de la roca, para que la roca no se lea como un hueco.
BASALT_COLS = (7, 23)
BASALT_ROWS = (1, 4)
BASALT_BRIGHTNESS = 0.32
# Pared "ladrillo": la fachada de Gothic Horror, teñida de rojo oscuro. Solo
# la fila 7 está entera sin musgo; de ella se toman las piezas sin los postes
# (columnas 33 y 44) ni el revoque claro (37-40), en dos órdenes para que el
# patrón de 7x2 no se repita fila a fila (los ladrillos casan cada 16 px).
BRICK_ROW = 7
BRICK_LINES = ((31, 32, 34, 35, 36, 41, 42), (35, 36, 41, 42, 31, 32, 34))
# Decorados de Gothic Horror, en píxeles (izquierda, arriba, derecha, abajo).
OVEN = (272, 64, 304, 160)      # nicho con llama y chimenea, 32x96
ARCH = (224, 112, 256, 160)     # arco con cara de demonio, 32x48
SKULLS = (128, 96, 160, 144)    # calaveras amontonadas, 32x45

# Tinte rojo: cada color se acerca a su luminancia teñida de rojo y se
# oscurece. TINTE_MEZCLA es la parte del color teñido.
TINTE = (1.45, 0.55, 0.45)
TINTE_MEZCLA = 0.85
# La llama del horno (amarilla y verdosa en el pack) pasa a una rampa naranja,
# para que se lea como fuego de forja.
TINTE_LLAMA = (1.35, 0.85, 0.30)
BRICK_BRIGHTNESS = 0.6


def tile(img, tx, ty, w=1, h=1):
    return img.crop((tx * T, ty * T, (tx + w) * T, (ty + h) * T))


def place(atlas, piece, dest, dx=0, dy=0):
    atlas.alpha_composite(piece, (dest[0] * T + dx, dest[1] * T + dy))


def scale(img, factor):
    out = img.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = px[x, y]
            px[x, y] = (round(r * factor), round(g * factor), round(b * factor), a)
    return out


def no_flat(img):
    """Quita el color plano del interior del pack (pasa a transparente)."""
    out = img.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            if px[x, y][:3] in FLAT:
                px[x, y] = (0, 0, 0, 0)
    return out


def tint(img, flame=False):
    """Recolorea hacia el rojo. Con flame, la llama del horno (amarilla y
    verdosa: más verde que rojo y bastante más que azul) va a TINTE_LLAMA."""
    out = img.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            lum = 0.299 * r + 0.587 * g + 0.114 * b
            if flame and g >= r and g > b + 40:
                px[x, y] = tuple(min(255, round(lum * k)) for k in TINTE_LLAMA) + (a,)
                continue
            px[x, y] = tuple(
                min(255, round(c * (1.0 - TINTE_MEZCLA) + lum * k * TINTE_MEZCLA))
                for c, k in zip((r, g, b), TINTE)) + (a,)
    return out


def solid(piece, name):
    assert piece.getchannel("A").getextrema() == (255, 255), ("no maciza", name)
    return piece


def fit(atlas, img, region, name, size):
    """Recorta region por su borde y la apoya abajo en su hueco, centrada."""
    crop = img.crop(region)
    crop = crop.crop(crop.getbbox())
    w, h = size
    assert crop.width <= w * T and crop.height <= h * T, (name, crop.size)
    place(atlas, crop, LAYOUT[name], (w * T - crop.width) // 2, h * T - crop.height)


def blocks(caverns, atlas):
    bx, by = LAYOUT["bloques"]
    pieces = {k: solid(tile(caverns, *v), v) for k, v in EDGES.items()}
    pieces[(1, 1)] = solid(scale(tile(caverns, *INTERIOR), INTERIOR_BRIGHTNESS), "interior")
    # Columna de una pieza de ancho: la mitad izquierda del lateral izquierdo
    # con la derecha del derecho.
    column = Image.new("RGBA", (T, T))
    column.paste(tile(caverns, *LEFT).crop((0, 0, T // 2, T)), (0, 0))
    column.paste(tile(caverns, *RIGHT).crop((T // 2, 0, T, T)), (T // 2, 0))
    pieces[(3, 1)] = solid(column, "columna")
    # La pared agrietada (P48) es la misma columna, de 1x3: la roca que sigue
    # hasta el suelo bajo la columna de la galería.
    wx, wy = LAYOUT["pared_agrietada"]
    for j in range(3):
        place(atlas, column, (wx, wy + j))
    # Tiras de una pieza de alto: la mitad de arriba del borde de arriba con la
    # de abajo del de abajo.
    half = T // 2
    for i in range(4):
        p = Image.new("RGBA", (T, T))
        p.paste(pieces[(i, 0)].crop((0, 0, T, half)), (0, 0))
        p.paste(pieces[(i, 2)].crop((0, half, T, T)), (0, half))
        pieces[(i, 3)] = solid(p, ("tira", i))
    for (i, j), p in pieces.items():
        place(atlas, p, (bx + i, by + j))


def main():
    mazmorra = Image.open(MAZMORRA).convert("RGBA")
    assert mazmorra.size == (512, 256), mazmorra.size
    atlas = Image.new("RGBA", (512, 352))
    atlas.paste(mazmorra, (0, 0))
    caverns = Image.open(CAVERNS).convert("RGBA")
    assert caverns.size == (512, 288), caverns.size
    horror = Image.open(HORROR).convert("RGBA")

    blocks(caverns, atlas)

    px_, py_ = LAYOUT["plataformas"]
    ledge = no_flat(tile(caverns, *LEDGE))
    for i in range(3):
        place(atlas, ledge, (px_ + i, py_))

    # Escalera de madera del Dungeon Tile Set, la pieza (5,9), como el calabozo.
    place(atlas, tile(Image.open(DTS).convert("RGBA"), 5, 9), LAYOUT["escalera"])

    r0, rows = BASALT_ROWS
    basalt = Image.new("RGBA", (len(BASALT_COLS) * T, rows * T))
    for i, col in enumerate(BASALT_COLS):
        basalt.alpha_composite(tile(caverns, col, r0, 1, rows), (i * T, 0))
    place(atlas, solid(scale(basalt, BASALT_BRIGHTNESS), "basalto"), LAYOUT["basalto"])

    brick = Image.new("RGBA", (7 * T, len(BRICK_LINES) * T))
    for j, line in enumerate(BRICK_LINES):
        for i, col in enumerate(line):
            brick.alpha_composite(tile(horror, col, BRICK_ROW), (i * T, j * T))
    place(atlas, solid(scale(tint(brick), BRICK_BRIGHTNESS), "ladrillo"), LAYOUT["ladrillo"])

    fit(atlas, tint(horror.crop(OVEN), flame=True), (0, 0, 32, 96), "horno", (2, 6))
    fit(atlas, tint(horror.crop(ARCH)), (0, 0, 32, 48), "arco", (2, 3))
    fit(atlas, horror, SKULLS, "calaveras", (2, 3))

    atlas.save(OUT)
    print("atlas:", OUT.relative_to(ROOT), atlas.size)


if __name__ == "__main__":
    main()
