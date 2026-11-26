"""Arma el atlas del tileset "infierno" (P73, ficha del infierno).

graficos/terceros/gothicvania/tejido_vivo/tileset_infierno.png, 512x400, piezas de 16:
- filas 0-15: copia del atlas de mazmorra
  (graficos/terceros/plataformas_mazmorra/dungeontilesetfull.png), por la lava
  animada, la antorcha y la fogata; sus coordenadas no cambian, así que
  DECOR_LIGHTS de sistemas/entorno/map_ambience.gd sigue valiendo;
- filas 16-24: piezas de Living Tissue de la Legacy (tejido_vivo/tiles.png y
  tejido_vivo/fondo.png), la carne con colmillos y ojos, sin teñir; el
  ladrillo rojo de las profundidades (el mismo de atlas_profundidades.py, píxel
  a píxel), y la escalera de madera del Dungeon Tile Set. Coordenadas en
  LAYOUT, abajo; herramientas/constructor_mapas/baldosas/infierno.gd las usa.

Se puede correr las veces que haga falta: el resultado es el mismo.

Uso, desde la raíz del proyecto:
  python3 herramientas/constructor_mapas/atlas_infierno.py
"""
import sys
from collections import deque
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import atlas_profundidades as prof  # noqa: E402  (el ladrillo rojo, igual)

ROOT = Path(__file__).resolve().parents[2]
MAZMORRA = ROOT / "graficos/terceros/plataformas_mazmorra/dungeontilesetfull.png"
TISSUE = ROOT / "graficos/terceros/gothicvania/tejido_vivo/tiles.png"
TISSUE_BG = ROOT / "graficos/terceros/gothicvania/tejido_vivo/fondo.png"
DTS = ROOT / "graficos/terceros/baldosas_mazmorra/Dungeon Tile Set.png"
OUT = ROOT / "graficos/terceros/gothicvania/tejido_vivo/tileset_infierno.png"
T = 16

# Destino en el atlas (pieza de arriba a la izquierda) de cada grupo.
LAYOUT = {
    "bloques": (0, 16),      # juego de 4x4
    "plataformas": (4, 16),  # izquierda, medio, derecha
    "escalera": (7, 16),
    "carne": (8, 16),        # pared, 9x9 (filas 16-24)
    "ladrillo": (17, 16),    # pared, 7x2
    "herida": (17, 18),      # U, 3x2
    "colmillos": (24, 16),   # y, 3x3 (cuelga: pegado arriba)
    "ojo": (27, 16),         # r, 2x2 (da luz verde)
    "pustula": (29, 16),     # n, 2x2 (apoyada abajo)
}

# Juego de bloques "carne". Todas las piezas del suelo (2,7)-(13,10) y del
# techo (12,1)-(16,4) del pack tienen las cuatro esquinas opacas. Arriba, el
# canto del suelo (con sus esquinas redondas); a los lados, los bordes del
# suelo de la fila 10, que se repiten mejor en vertical que los de la 9;
# abajo, el canto del techo; el interior, el relleno liso.
EDGES = {
    (0, 0): (2, 7), (1, 0): (3, 7), (2, 0): (13, 7),
    (0, 1): (2, 10), (1, 1): (5, 10), (2, 1): (13, 10),
    (0, 2): (12, 4), (1, 2): (13, 4), (2, 2): (16, 4),
}
# Color plano del relleno de la carne.
FLAT = (48, 16, 32)
# Decorados del pack: pieza de arriba a la izquierda y tamaño en piezas.
WOUND = ((2, 1), (3, 2))     # herida o vena
FANGS = ((6, 1), (3, 3))     # mandíbula con colmillos y el colmillo largo
EYE = ((3, 4), (2, 2))       # ojo verde
PUSTULE = ((9, 5), (2, 2))   # pústula, sin fondo en el pack


def clear_flat(img):
    """Quita el relleno liso que toca el borde de la pieza (relleno por
    inundación desde el borde): el ojo, la herida y los colmillos traen un
    cuadro opaco del color del relleno, que sobre la pared de carne se vería
    como un parche. No se repinta nada."""
    out = img.copy()
    px = out.load()
    w, h = out.size
    todo = deque([(x, y) for x in range(w) for y in (0, h - 1)]
                 + [(x, y) for y in range(h) for x in (0, w - 1)])
    seen = set()
    while todo:
        x, y = todo.popleft()
        if (x, y) in seen or not (0 <= x < w and 0 <= y < h):
            continue
        seen.add((x, y))
        if px[x, y][3] == 0 or px[x, y][:3] != FLAT:
            continue
        px[x, y] = (0, 0, 0, 0)
        todo.extend(((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)))
    return out


def place_aligned(atlas, img, name, size, top=False):
    """Recorta img por su borde y la pone centrada en su hueco, apoyada abajo
    (o pegada arriba, para lo que cuelga)."""
    crop = img.crop(img.getbbox())
    w, h = size
    assert crop.width <= w * T and crop.height <= h * T, (name, crop.size)
    dy = 0 if top else h * T - crop.height
    prof.place(atlas, crop, LAYOUT[name], (w * T - crop.width) // 2, dy)


def blocks(tissue, atlas):
    bx, by = LAYOUT["bloques"]
    pieces = {k: prof.solid(prof.tile(tissue, *v), v) for k, v in EDGES.items()}
    half = T // 2
    # Columna de una pieza de ancho: la mitad izquierda del borde izquierdo con
    # la derecha del derecho, en sus tres alturas.
    for j in range(3):
        column = Image.new("RGBA", (T, T))
        column.paste(pieces[(0, j)].crop((0, 0, half, T)), (0, 0))
        column.paste(pieces[(2, j)].crop((half, 0, T, T)), (half, 0))
        pieces[(3, j)] = prof.solid(column, ("columna", j))
    # Tiras de una pieza de alto: la mitad de arriba del borde de arriba con la
    # de abajo del de abajo.
    for i in range(4):
        p = Image.new("RGBA", (T, T))
        p.paste(pieces[(i, 0)].crop((0, 0, T, half)), (0, 0))
        p.paste(pieces[(i, 2)].crop((0, half, T, T)), (0, half))
        pieces[(i, 3)] = prof.solid(p, ("tira", i))
    for (i, j), p in pieces.items():
        prof.place(atlas, p, (bx + i, by + j))


def main():
    mazmorra = Image.open(MAZMORRA).convert("RGBA")
    assert mazmorra.size == (512, 256), mazmorra.size
    atlas = Image.new("RGBA", (512, 400))
    atlas.paste(mazmorra, (0, 0))
    tissue = Image.open(TISSUE).convert("RGBA")
    assert tissue.size == (288, 192), tissue.size
    background = Image.open(TISSUE_BG).convert("RGBA")
    assert background.size == (144, 144), background.size

    blocks(tissue, atlas)

    # Repisa (=): el canto del suelo (izquierda, medio, derecha) sin el relleno
    # liso de debajo.
    px_, py_ = LAYOUT["plataformas"]
    for i, src in enumerate(((2, 7), (3, 7), (13, 7))):
        prof.place(atlas, clear_flat(prof.tile(tissue, *src)), (px_ + i, py_))

    # Escalera de madera del Dungeon Tile Set, la pieza (5,9), como el calabozo.
    prof.place(atlas, prof.tile(Image.open(DTS).convert("RGBA"), 5, 9), LAYOUT["escalera"])

    # Pared "carne": el fondo del pack entero, 9x9, que se repite sin costura.
    prof.place(atlas, prof.solid(background, "carne"), LAYOUT["carne"])

    # Pared "ladrillo": la de las profundidades, con sus mismas funciones.
    horror = Image.open(prof.HORROR).convert("RGBA")
    brick = Image.new("RGBA", (7 * T, len(prof.BRICK_LINES) * T))
    for j, line in enumerate(prof.BRICK_LINES):
        for i, col in enumerate(line):
            brick.alpha_composite(prof.tile(horror, col, prof.BRICK_ROW), (i * T, j * T))
    prof.place(atlas, prof.solid(prof.scale(prof.tint(brick), prof.BRICK_BRIGHTNESS), "ladrillo"),
               LAYOUT["ladrillo"])

    for name, (src, size), top in (("herida", WOUND, False), ("colmillos", FANGS, True),
                                   ("ojo", EYE, False), ("pustula", PUSTULE, False)):
        place_aligned(atlas, clear_flat(prof.tile(tissue, *src, *size)), name, size, top)

    atlas.save(OUT)
    print("atlas:", OUT.relative_to(ROOT), atlas.size)


if __name__ == "__main__":
    main()
