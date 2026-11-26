"""Arma el atlas del tileset "mazmorra_reina" (P73, ficha de la mazmorra).

graficos/terceros/gothicvania/castillo_viejo/tileset_mazmorra_reina.png, 512x320,
piezas de 16:
- filas 0-15: copia del atlas de mazmorra
  (graficos/terceros/plataformas_mazmorra/dungeontilesetfull.png), por la antorcha,
  la fogata, la lava, el agua, la estantería, la caja, el barril, los cristales
  y los hongos; sus coordenadas no cambian, así que DECOR_LIGHTS de
  sistemas/entorno/map_ambience.gd sigue valiendo;
- filas 16-19: piezas del tileset Old Dark Castle interior de la Legacy
  (castillo_viejo/tileset.png, el pack del parallax de la mazmorra) a su escala,
  sin repintar, la escalera de madera del Dungeon Tile Set y la reja de celda
  de Raou (la "f" del castillo). Coordenadas en LAYOUT, abajo;
  herramientas/constructor_mapas/baldosas/mazmorra_reina.gd las usa.

Se puede correr las veces que haga falta: el resultado es el mismo.

Uso, desde la raíz del proyecto:
  python3 herramientas/constructor_mapas/atlas_mazmorra_reina.py
"""
from pathlib import Path

from PIL import Image, ImageEnhance

ROOT = Path(__file__).resolve().parents[2]
MAZMORRA = ROOT / "graficos/terceros/plataformas_mazmorra/dungeontilesetfull.png"
CASTLE = ROOT / "graficos/terceros/gothicvania/castillo_viejo/tileset.png"
DTS = ROOT / "graficos/terceros/baldosas_mazmorra/Dungeon Tile Set.png"
RAOU = ROOT / "graficos/terceros/raou_castillo/tileset_castillo.png"
OUT = ROOT / "graficos/terceros/gothicvania/castillo_viejo/tileset_mazmorra_reina.png"
T = 16

# Destino en el atlas (pieza de arriba a la izquierda) de cada grupo.
LAYOUT = {
    "bloques": (0, 16),     # juego de 4x4
    "pasarela": (4, 16),    # izquierda, medio, derecha
    "escalera": (7, 16),
    "piedra": (8, 16),      # pared, 6x4
    "cloaca": (14, 16),     # pared, 6x4
    "cadena": (20, 16),     # g, 1x4 (cuelga)
    "arco": (21, 16),       # U, 6x3
    "reja": (27, 16),       # w, 2x2
}

# Juego de bloques "mazmorra_reina". El pack dibuja la piedra en losas
# redondeadas que sobresalen a la celda vecina; solo se toman celdas macizas
# (las 4 esquinas opacas). Arriba, el remate de musgo de los pilares del pack
# ((32,10) y, en la esquina derecha, (33,10), con su sombra); el resto, la
# piedra verde (10,6), que se repite como un aparejo de bloques y es el doble
# de clara que la pared (el ladrillo oscuro de los pilares es igual de oscuro
# que la pared y la roca se leería como un hueco). Pieza (columna, fila) del
# pack para cada casilla del juego de 4x4.
CAP, CAP_RIGHT, STONE = (32, 10), (33, 10), (10, 6)
STONES = {
    (0, 0): CAP, (1, 0): CAP, (2, 0): CAP_RIGHT, (3, 0): CAP_RIGHT,
    (0, 1): STONE, (1, 1): STONE, (2, 1): STONE, (3, 1): STONE,
    (0, 2): STONE, (1, 2): STONE, (2, 2): STONE, (3, 2): STONE,
}
# Pasarela de madera (el puente entre losas del pack): las tablas empiezan a
# 10 px de la fila 5, así que se recorta desde su borde de arriba, con la
# viga de debajo. La misma pieza a la izquierda, en medio y a la derecha.
PLANK = (144, 90, 160, 106)
# Pared "piedra": la pared del pack (19,2)-(28,5), 6x4: la pilastra (19,3)-
# (20,4), sin el remate de arriba, repetida para que siga sin cortes, y cuatro
# columnas de pared lisa con la hilada de ladrillo de abajo. "cloaca" es la
# misma, oscurecida.
WALL = (21, 2, 4, 4)            # x, y, ancho, alto en piezas
PILASTER_ROWS = (3, 4, 3, 4)
PILASTER_X = 19
CLOACA_BRIGHTNESS = 0.6
# La cadena y el arco del desagüe vienen pintados sobre la pared lisa: se quita
# ese color plano para que sirvan también sobre "cloaca" y sin pared.
WALL_FLAT = (12, 29, 28, 255)
CHAIN = (45, 3, 1, 4)
ARCH = (5, 9, 6, 3)
# Reja de celda de Raou: las piezas (17,16)-(18,17) del atlas del castillo.
BARS = (17, 16, 2, 2)


def tile(img, tx, ty, w=1, h=1):
    return img.crop((tx * T, ty * T, (tx + w) * T, (ty + h) * T))


def place(atlas, piece, dest, dx=0, dy=0):
    atlas.alpha_composite(piece, (dest[0] * T + dx, dest[1] * T + dy))


def dark(img, brightness):
    rgb = ImageEnhance.Brightness(img.convert("RGB")).enhance(brightness)
    out = rgb.convert("RGBA")
    out.putalpha(img.getchannel("A"))
    return out


def no_wall(img):
    """Quita el color plano de la pared (pasa a transparente)."""
    out = img.copy()
    px = out.load()
    for y in range(out.height):
        for x in range(out.width):
            if px[x, y] == WALL_FLAT:
                px[x, y] = (0, 0, 0, 0)
    return out


def solid(piece, name):
    assert piece.getchannel("A").getextrema() == (255, 255), ("no maciza", name)
    return piece


def main():
    mazmorra = Image.open(MAZMORRA).convert("RGBA")
    assert mazmorra.size == (512, 256), mazmorra.size
    atlas = Image.new("RGBA", (512, 320))
    atlas.paste(mazmorra, (0, 0))
    castle = Image.open(CASTLE).convert("RGBA")
    assert castle.size == (832, 240), castle.size
    dts = Image.open(DTS).convert("RGBA")
    raou = Image.open(RAOU).convert("RGBA")

    # Bloques: las tres primeras filas, tal cual; la cuarta (tiras de una
    # pieza de alto y la pieza suelta) une la mitad de arriba de la fila 0
    # con la de abajo de la fila 2, como el calabozo y las minas.
    bx, by = LAYOUT["bloques"]
    for (i, j), (sx, sy) in STONES.items():
        place(atlas, solid(tile(castle, sx, sy), (sx, sy)), (bx + i, by + j))
    half = T // 2
    for i in range(4):
        p = Image.new("RGBA", (T, T))
        p.paste(tile(castle, *STONES[(i, 0)]).crop((0, 0, T, half)), (0, 0))
        p.paste(tile(castle, *STONES[(i, 2)]).crop((0, half, T, T)), (0, half))
        place(atlas, solid(p, ("tira", i)), (bx + i, by + 3))

    # Pasarela.
    px_, py_ = LAYOUT["pasarela"]
    for i in range(3):
        place(atlas, castle.crop(PLANK), (px_ + i, py_))

    # Escalera de madera del Dungeon Tile Set, la pieza (5,9), como el calabozo.
    place(atlas, tile(dts, 5, 9), LAYOUT["escalera"])

    # Paredes "piedra" y "cloaca".
    wall = Image.new("RGBA", (6 * T, 4 * T))
    wall.alpha_composite(tile(castle, *WALL), (2 * T, 0))
    for j, row in enumerate(PILASTER_ROWS):
        wall.alpha_composite(tile(castle, PILASTER_X, row, 2, 1), (0, j * T))
    solid(wall, "piedra")
    place(atlas, wall, LAYOUT["piedra"])
    place(atlas, dark(wall, CLOACA_BRIGHTNESS), LAYOUT["cloaca"])

    # Decorados.
    place(atlas, no_wall(tile(castle, *CHAIN)), LAYOUT["cadena"])
    place(atlas, no_wall(tile(castle, *ARCH)), LAYOUT["arco"])
    place(atlas, tile(raou, *BARS), LAYOUT["reja"])

    atlas.save(OUT)
    print("atlas:", OUT.relative_to(ROOT), atlas.size)


if __name__ == "__main__":
    main()
