"""Arma el atlas del tileset "minas" (P73, ficha de las minas).

graficos/terceros/pixelfantasy_cavernas/tileset_minas.png, 512x320, piezas de 16:
- filas 0-15: copia del atlas de mazmorra
  (graficos/terceros/plataformas_mazmorra/dungeontilesetfull.png), por la antorcha,
  la fogata, la lava, los cristales, los hongos, la tienda, la caja y el
  barril; sus coordenadas no cambian, así que DECOR_LIGHTS de
  sistemas/entorno/map_ambience.gd sigue valiendo;
- filas 16-19: piezas de PixelFantasy Caves (mainlev_build.png y props1.png,
  el pack del parallax de las minas) a su escala, sin repintar, y la escalera
  de madera del Dungeon Tile Set. Coordenadas en LAYOUT, abajo;
  herramientas/constructor_mapas/baldosas/minas.gd las usa.

Se puede correr las veces que haga falta: el resultado es el mismo.

Uso, desde la raíz del proyecto:
  python3 herramientas/constructor_mapas/atlas_minas.py
"""
from pathlib import Path

from PIL import Image, ImageEnhance

ROOT = Path(__file__).resolve().parents[2]
MAZMORRA = ROOT / "graficos/terceros/plataformas_mazmorra/dungeontilesetfull.png"
CAVES = ROOT / "graficos/terceros/pixelfantasy_cavernas/mainlev_build.png"
PROPS = ROOT / "graficos/terceros/pixelfantasy_cavernas/props1.png"
DTS = ROOT / "graficos/terceros/baldosas_mazmorra/Dungeon Tile Set.png"
OUT = ROOT / "graficos/terceros/pixelfantasy_cavernas/tileset_minas.png"
T = 16

# Destino en el atlas (pieza de arriba a la izquierda) de cada grupo.
LAYOUT = {
    "bloques": (0, 16),       # juego de 4x4
    "viga": (4, 16),          # izquierda, medio, derecha
    "escalera": (7, 16),
    "galeria": (8, 16),       # pared, 6x4
    "ladrillo": (14, 16),     # pared, 2x2
    "entibado": (16, 16),     # K, 3x3
    "boca": (19, 16),         # U, 3x4
    "estalagmita": (22, 16),  # T, 3x4
    "estalactita": (25, 16),  # y, 3x4 (cuelga)
}

# Juego de bloques "minas": la roca marrón de mainlev_build.png. El pack dibuja
# los remates de la roca sobresaliendo a la celda vecina; solo se toman las
# celdas macizas (las 4 esquinas opacas), así que lo que sobresale se queda
# fuera. Arriba, la franja clara de las celdas de la fila 40 (bajo los
# remates); abajo, la de la fila 58; a los lados, la roca con vetas claras de
# las paredes del pack (no traen otro borde macizo); dentro, un cuadro de
# relleno. Pieza (columna, fila) del pack para cada casilla del juego de 4x4.
ROCK = {
    (0, 0): (21, 40), (1, 0): (21, 40), (2, 0): (21, 40), (3, 0): (9, 40),
    (0, 1): (26, 44), (1, 1): (8, 46), (2, 1): (4, 44), (3, 1): (8, 46),
    (0, 2): (21, 58), (1, 2): (21, 58), (2, 2): (21, 58), (3, 2): (9, 58),
}
# Viga de madera (fila 1 del pack, x 755-925): tapa izquierda, un tramo sin el
# herraje en aspa y tapa derecha, de 16 px cada uno.
BEAM = ((755, 16), (787, 16), (909, 16))
# Pared "galeria": el relleno de roca de 6x4 del pack (se repite sin costura)
# con el marco abierto de postes y viga (3x4) a la izquierda, oscurecida.
ROCK_FILL = (14, 46)
FRAME = (960, 112, 1008, 176)
WALL_BRIGHTNESS = 0.6
# Pared "ladrillo": dos hiladas por pieza; el trozo (54,33)-(55,34) del muro
# del pack, oscurecido.
BRICK = (54, 33)
# Decorados: región en píxeles del pack.
ENTIBADO = (880, 96, 928, 144)      # marco con aspa, 48x48
BOCA = (960, 16, 1008, 80)          # marco con el fondo oscuro, 48x64
ESTALAGMITA = (656, 96, 704, 168)   # props1, 48x55
ESTALACTITA = (656, 168, 704, 240)  # props1, 48x55


def tile(img, tx, ty, w=1, h=1):
    return img.crop((tx * T, ty * T, (tx + w) * T, (ty + h) * T))


def place(atlas, piece, dest, dx=0, dy=0):
    atlas.alpha_composite(piece, (dest[0] * T + dx, dest[1] * T + dy))


def dark(img, brightness=WALL_BRIGHTNESS):
    rgb = ImageEnhance.Brightness(img.convert("RGB")).enhance(brightness)
    out = rgb.convert("RGBA")
    out.putalpha(img.getchannel("A"))
    return out


def fit(atlas, img, region, dest, size, align):
    """Recorta region por su borde y la pone en su hueco, centrada de lado;
    align: "arriba" (cuelga) o "abajo" (apoya)."""
    crop = img.crop(region)
    crop = crop.crop(crop.getbbox())
    w, h = size
    assert crop.width <= w * T and crop.height <= h * T, (region, crop.size)
    dx = (w * T - crop.width) // 2
    dy = 0 if align == "arriba" else h * T - crop.height
    place(atlas, crop, dest, dx, dy)


def main():
    mazmorra = Image.open(MAZMORRA).convert("RGBA")
    assert mazmorra.size == (512, 256), mazmorra.size
    atlas = Image.new("RGBA", (512, 320))
    atlas.paste(mazmorra, (0, 0))
    caves = Image.open(CAVES).convert("RGBA")
    props = Image.open(PROPS).convert("RGBA")
    dts = Image.open(DTS).convert("RGBA")

    # Bloques: las tres primeras filas, tal cual; la cuarta (tiras de una
    # pieza de alto y la pieza suelta) une la mitad de arriba de la fila 0
    # con la de abajo de la fila 2, como el calabozo.
    bx, by = LAYOUT["bloques"]
    for (i, j), (sx, sy) in ROCK.items():
        piece = tile(caves, sx, sy)
        assert piece.getchannel("A").getextrema() == (255, 255), ("no maciza", sx, sy)
        place(atlas, piece, (bx + i, by + j))
    half = T // 2
    for i in range(4):
        p = Image.new("RGBA", (T, T))
        p.paste(tile(caves, *ROCK[(i, 0)]).crop((0, 0, T, half)), (0, 0))
        p.paste(tile(caves, *ROCK[(i, 2)]).crop((0, half, T, T)), (0, half))
        place(atlas, p, (bx + i, by + 3))

    # Viga.
    vx, vy = LAYOUT["viga"]
    for i, (sx, sy) in enumerate(BEAM):
        place(atlas, caves.crop((sx, sy, sx + T, sy + T)), (vx + i, vy))

    # Escalera de madera del Dungeon Tile Set, la pieza (5,9), como el calabozo.
    place(atlas, tile(dts, 5, 9), LAYOUT["escalera"])

    # Pared "galeria".
    wall = tile(caves, *ROCK_FILL, 6, 4)
    wall.alpha_composite(caves.crop(FRAME), (0, 0))
    place(atlas, dark(wall), LAYOUT["galeria"])

    # Pared "ladrillo".
    place(atlas, dark(tile(caves, *BRICK, 2, 2)), LAYOUT["ladrillo"])

    # Decorados.
    fit(atlas, caves, ENTIBADO, LAYOUT["entibado"], (3, 3), "abajo")
    fit(atlas, caves, BOCA, LAYOUT["boca"], (3, 4), "abajo")
    fit(atlas, props, ESTALAGMITA, LAYOUT["estalagmita"], (3, 4), "abajo")
    fit(atlas, props, ESTALACTITA, LAYOUT["estalactita"], (3, 4), "arriba")

    atlas.save(OUT)
    print("atlas:", OUT.relative_to(ROOT), atlas.size)


if __name__ == "__main__":
    main()
