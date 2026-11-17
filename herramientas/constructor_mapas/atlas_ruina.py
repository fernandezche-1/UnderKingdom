"""Arma el atlas del tileset "ruina" (P73, ficha de la ruina).

assets/terceros/gothicvania/cavernas/tileset_ruina.png, 512x320, piezas de 16:
- filas 0-15: copia del atlas de mazmorra
  (assets/terceros/dungeon_platformer/dungeontilesetfull.png), por la antorcha,
  la fogata, el agua, los cristales, los hongos, la estantería, la caja y el
  barril; sus coordenadas no cambian, así que DECOR_LIGHTS de
  scripts/environment/map_ambience.gd sigue valiendo;
- filas 16-19: piezas de Caverns de la Legacy (cavernas/tiles.png, el pack del
  parallax de la ruina) a su escala, teñidas de frío, y la escalera de madera
  del Dungeon Tile Set. Coordenadas en LAYOUT, abajo;
  herramientas/constructor_mapas/tilesets/ruina.gd las usa.

El frío (sin arte de hielo en ningún pack): TINTE recolorea las piezas del pack
hacia un azul frío, sin dibujar nada (elegido en la galería el 2026-11-16,
frente a las piezas tal cual y a una luz ambiente fría; P73, ficha de la
ruina). La llama de la hornacina conserva su rosa.

Se puede correr las veces que haga falta: el resultado es el mismo.

Uso, desde la raíz del proyecto:
  python3 herramientas/constructor_mapas/atlas_ruina.py
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
MAZMORRA = ROOT / "assets/terceros/dungeon_platformer/dungeontilesetfull.png"
CAVERNS = ROOT / "assets/terceros/gothicvania/cavernas/tiles.png"
DTS = ROOT / "assets/terceros/dungeon_tile_set/Dungeon Tile Set.png"
OUT = ROOT / "assets/terceros/gothicvania/cavernas/tileset_ruina.png"
T = 16

# Destino en el atlas (pieza de arriba a la izquierda) de cada grupo.
LAYOUT = {
    "bloques": (0, 16),     # juego de 4x4
    "plataformas": (4, 16), # izquierda, medio, derecha
    "escalera": (7, 16),
    "ruina": (8, 16),       # pared, 7x3
    "hornacina": (15, 16),  # V, 2x2 (da luz)
    "contrafuerte": (17, 16),  # U, 4x3
    "pedruscos": (21, 16),  # n, 2x2
}

# Juego de bloques "ruina": el borde de cantos morados del pack. Los remates
# de las esquinas sobresalen a la celda vecina; solo se toman celdas macizas
# (las 4 esquinas opacas), así que las esquinas toman el borde de arriba o el
# de abajo, como en las minas. Arriba, el suelo con piedras (fila 15); a los
# lados, los cantos de los laterales (columnas 7 y 23); abajo, el techo con
# flecos (fila 5). Pieza (columna, fila) del pack para cada casilla del juego.
TOP, LEFT, RIGHT, BOTTOM = (2, 15), (7, 2), (23, 2), (12, 5)
EDGES = {
    (0, 0): TOP, (1, 0): TOP, (2, 0): TOP, (3, 0): TOP,
    (0, 1): LEFT, (2, 1): RIGHT,
    (0, 2): BOTTOM, (1, 2): BOTTOM, (2, 2): BOTTOM, (3, 2): BOTTOM,
}
# El interior del pack es del mismo color plano que su muro, (25,14,27): la
# roca se leería como un hueco sobre la pared. El interior es la textura de
# cantos del lateral izquierdo, oscurecida.
INTERIOR = LEFT
INTERIOR_BRIGHTNESS = 0.55
# Color plano del interior y del muro del pack (y sus vecinos casi iguales):
# pasa a transparente en los decorados y bajo las piedras de las plataformas.
FLAT = {(25, 14, 27), (26, 15, 28), (27, 16, 29)}
# Plataforma: la banda de piedras de la fila 15, sin el negro de debajo.
LEDGE = (2, 15)
# Pared "ruina": el muro de ladrillo roto del pasillo del pack (filas 6-8),
# las columnas 11-14 y 17-19, sin la hornacina ni los contrafuertes.
WALL_ROWS = (6, 3)
WALL_COLS = ((11, 4), (17, 3))
# Decorados, (columna, fila, ancho, alto) en el pack.
NICHE = (15, 6, 2, 2)
BUTTRESS = (7, 6, 4, 3)
SHARDS = ((20, 1, 1, 2), (9, 11, 1, 2))

# Tinte frío: cada color se acerca a su luminancia teñida de azul. TINTE_MEZCLA
# es la parte del color teñido (0 = sin tinte).
TINTE = (0.80, 0.96, 1.24)
TINTE_MEZCLA = 0.6


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
    """Quita el color plano del interior y del muro (pasa a transparente)."""
    out = img.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            if px[x, y][:3] in FLAT:
                px[x, y] = (0, 0, 0, 0)
    return out


def tint(img, keep_vivid=False):
    """Recolorea hacia el azul frío. keep_vivid deja los colores saturados (la llama)."""
    out = img.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            r, g, b, a = px[x, y]
            if a == 0 or (keep_vivid and max(r, g, b) - min(r, g, b) > 60):
                continue
            lum = 0.299 * r + 0.587 * g + 0.114 * b
            px[x, y] = tuple(
                min(255, round(c * (1.0 - TINTE_MEZCLA) + lum * k * TINTE_MEZCLA))
                for c, k in zip((r, g, b), TINTE)) + (a,)
    return out


def solid(piece, name):
    assert piece.getchannel("A").getextrema() == (255, 255), ("no maciza", name)
    return piece


def bottom_aligned(piece):
    """Baja el dibujo hasta el borde de abajo de su caja (sin repintar)."""
    box = piece.getbbox()
    out = Image.new("RGBA", piece.size)
    out.alpha_composite(piece.crop(box), (box[0], piece.height - (box[3] - box[1])))
    return out


def pack_pieces(caverns):
    """Piezas del pack para las filas 16-19: lista de (pieza, destino, llama)."""
    pieces = []
    bx, by = LAYOUT["bloques"]
    blocks = {k: solid(tile(caverns, *v), v) for k, v in EDGES.items()}
    blocks[(1, 1)] = solid(scale(tile(caverns, *INTERIOR), INTERIOR_BRIGHTNESS), "interior")
    # Columna de una pieza de ancho: la mitad izquierda del lateral izquierdo
    # con la derecha del derecho.
    column = Image.new("RGBA", (T, T))
    column.paste(tile(caverns, *LEFT).crop((0, 0, T // 2, T)), (0, 0))
    column.paste(tile(caverns, *RIGHT).crop((T // 2, 0, T, T)), (T // 2, 0))
    blocks[(3, 1)] = solid(column, "columna")
    # Tiras de una pieza de alto (y la pieza suelta): la mitad de arriba del
    # borde de arriba con la de abajo del de abajo, como el calabozo y las minas.
    half = T // 2
    for i in range(4):
        p = Image.new("RGBA", (T, T))
        p.paste(blocks[(i, 0)].crop((0, 0, T, half)), (0, 0))
        p.paste(blocks[(i, 2)].crop((0, half, T, T)), (0, half))
        blocks[(i, 3)] = solid(p, ("tira", i))
    for (i, j), p in blocks.items():
        pieces.append((p, (bx + i, by + j), False))

    px_, py_ = LAYOUT["plataformas"]
    ledge = no_flat(tile(caverns, *LEDGE))
    for i in range(3):
        pieces.append((ledge, (px_ + i, py_), False))

    wall = Image.new("RGBA", (7 * T, 3 * T))
    x = 0
    for col, w in WALL_COLS:
        wall.alpha_composite(tile(caverns, col, WALL_ROWS[0], w, WALL_ROWS[1]), (x * T, 0))
        x += w
    pieces.append((solid(wall, "pared ruina"), LAYOUT["ruina"], False))

    pieces.append((no_flat(tile(caverns, *NICHE)), LAYOUT["hornacina"], True))
    pieces.append((no_flat(tile(caverns, *BUTTRESS)), LAYOUT["contrafuerte"], False))
    shards = Image.new("RGBA", (2 * T, 2 * T))
    for i, s in enumerate(SHARDS):
        shards.alpha_composite(bottom_aligned(no_flat(tile(caverns, *s))), (i * T, 0))
    pieces.append((shards, LAYOUT["pedruscos"], False))
    return pieces


def main():
    mazmorra = Image.open(MAZMORRA).convert("RGBA")
    assert mazmorra.size == (512, 256), mazmorra.size
    atlas = Image.new("RGBA", (512, 320))
    atlas.paste(mazmorra, (0, 0))
    caverns = Image.open(CAVERNS).convert("RGBA")
    assert caverns.size == (512, 288), caverns.size
    for piece, dest, flame in pack_pieces(caverns):
        place(atlas, tint(piece, keep_vivid=flame), dest)
    # Escalera de madera del Dungeon Tile Set, la pieza (5,9), como el calabozo.
    dts = Image.open(DTS).convert("RGBA")
    place(atlas, tile(dts, 5, 9), LAYOUT["escalera"])
    atlas.save(OUT)
    print("atlas:", OUT.relative_to(ROOT), atlas.size)


if __name__ == "__main__":
    main()
