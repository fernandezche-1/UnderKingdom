"""Galería de piezas de la zona de pruebas (P71).

Escribe el mapa de letras de mapas_texto/zona_pruebas.txt (deja igual el tramo
de arriba, filas 0-23, y su cabecera) y reescribe ENTERA
escenas/mapas/zona_pruebas_galeria.tscn: un cuarto por pieza de la Fase 2, con
sus nodos y sus carteles. zona_pruebas_combate.tscn la instancia en `Objetos`
y no se toca: lo que se ponga a mano allí para probar se conserva.
Para añadir o cambiar un cuarto, se edita este script (lista de room(...)) y
se vuelve a correr; no se edita la escena de la galería a mano.

El piso D tiene un cuarto por tileset nuevo (P73, paso de las piezas): cada uno
instancia una muestra que el constructor genera con ese tileset ("muestra: si",
sin Player ni límites). galeria.py escribe su texto en
mapas_texto/zona_pruebas_muestra_<tileset>.txt.

Uso, desde la raíz del proyecto:
  python3 herramientas/zona_pruebas/galeria.py [cabecera.txt]
  ~/.local/bin/godot --headless res://herramientas/constructor_mapas/construir_mapa.tscn -- mapas_texto/zona_pruebas_muestra_calabozo.txt
  ~/.local/bin/godot --headless res://herramientas/constructor_mapas/construir_mapa.tscn -- mapas_texto/zona_pruebas_muestra_castillo.txt
  ~/.local/bin/godot --headless res://herramientas/constructor_mapas/construir_mapa.tscn -- mapas_texto/zona_pruebas_muestra_castillo_salas.txt
  ~/.local/bin/godot --headless res://herramientas/constructor_mapas/construir_mapa.tscn -- mapas_texto/zona_pruebas_muestra_cementerio.txt
  ~/.local/bin/godot --headless res://herramientas/constructor_mapas/construir_mapa.tscn -- mapas_texto/zona_pruebas.txt
"""
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
TXT = ROOT / "mapas_texto/zona_pruebas.txt"
TSCN = ROOT / "escenas/mapas/zona_pruebas_galeria.tscn"
T = 16
COLS = 146
ROWS = 101

# ---------------------------------------------------------------- mapa viejo
raw = TXT.read_text(encoding="utf-8")
head, body = raw.split("\n---\n", 1)
old = [l for l in body.split("\n") if l.strip()][:24]
assert len(old) == 24 and all(len(l) == COLS for l in old), "mapa viejo inesperado"
g = [list(l) for l in old] + [["#"] * COLS for _ in range(ROWS - 24)]


def put(r, c, ch):
    g[r][c] = ch


# Pisos de la galería: (fila de arriba del pasillo, fila del techo de los
# cuartos, fila del suelo de los cuartos, sentido).
PISOS = {
    "A": dict(corr=24, techo=29, suelo=42, dir=1),
    "B": dict(corr=43, techo=48, suelo=61, dir=-1),
    "C": dict(corr=62, techo=67, suelo=80, dir=1),
    "D": dict(corr=81, techo=86, suelo=99, dir=-1),
}
for p in PISOS.values():
    for r in range(p["corr"], p["corr"] + 5):
        for c in range(2, COLS - 2):
            put(r, c, ".")


def ladder(col, top, bottom):
    """Escalera que baja por un piso: en la fila `top` (el piso) una plataforma
    de una vía de tres piezas tapa la boca, para cruzarla caminando sin caer; se
    baja con S y se sube trepando (la zona de la escalera llega una pieza más
    arriba). De `top + 1` a `bottom`, la escalera con sus dos columnas libres."""
    for cc in (col - 1, col, col + 1):
        put(top, cc, "=")
    for r in range(top + 1, bottom + 1):
        put(r, col, "H")
        put(r, col - 1, ".")
        put(r, col + 1, ".")


# Bajada desde el inicio (al lado del spawn) hasta el pasillo A.
ladder(3, 20, 28)
# Pozo del piso A al B (a la derecha) y del B al C (a la izquierda).
ladder(139, 29, 47)
ladder(4, 48, 66)
ladder(139, 67, 85)
# Checkpoints de la galería.
put(28, 6, "S")
put(47, 141, "S")
put(66, 6, "S")
put(85, 141, "S")

# ---------------------------------------------------------------- cuartos
# Cada cuarto: zona, nombre corto (cartel del pasillo), texto, ancho y piezas.
ROOMS = {"A": [], "B": [], "C": [], "D": []}


def room(piso, zona, nombre, texto, ancho, build, **extra):
    ROOMS[piso].append(dict(zona=zona, nombre=nombre, texto=texto, W=ancho, build=build, **extra))


nodes = []        # texto de nodos para la _combate
carteles = []     # (nombre, x, y, w, h, texto, variacion, alinear)


class Ctx:
    """Coordenadas de un cuarto. u = columna contada desde la escalera."""

    def __init__(self, piso, x0, W):
        self.p = PISOS[piso]
        self.x0 = x0
        self.W = W
        self.dir = self.p["dir"]
        self.techo = self.p["techo"]
        self.F = self.p["suelo"]
        self.CW = W - 3

    def col(self, u):
        if self.dir == 1:
            return self.x0 + 3 + u
        return self.x0 + self.W - 4 - u

    def cx(self, u):
        return self.col(u) * T + 8

    def fy(self, row=None):
        return (self.F if row is None else row) * T

    def solid(self, u, r0, r1):
        for r in range(r0, r1 + 1):
            put(r, self.col(u), "#")

    def cell(self, u, r, ch):
        put(r, self.col(u), ch)


def node(text):
    nodes.append(text.strip("\n"))


def barrier(name, parent, x, y, shape, extra="", disabled=False):
    node(f'''
[node name="{name}" type="StaticBody2D" parent="{parent}"]
position = Vector2({x}, {y})
script = ExtResource("7_barrera")
piece_start = SubResource("AtlasTexture_reja_tope")
piece_middle = SubResource("AtlasTexture_reja_medio")
piece_end = SubResource("AtlasTexture_reja_base")
{extra}''')
    node(f'''
[node name="CollisionShape2D" type="CollisionShape2D" parent="{parent}/{name}"]
shape = SubResource("{shape}")''' + ("\ndisabled = true" if disabled else ""))


def palanca(name, x, floor_y, encounter):
    node(f'''
[node name="{name}" parent="Objetos" instance=ExtResource("6_palanca")]
position = Vector2({x}, {floor_y - 32})
encounter_id = "{encounter}"''')


# Columna que cierra el hueco encima de una puerta: de la fila techo+5 hasta
# justo encima de la puerta. Por encima queda aire para el cartel; desde el
# suelo no se llega (8 piezas).
def column_above(c, u, door_rows):
    c.solid(u, c.techo + 5, c.F - door_rows - 1)


# ---- 1. Calabozo
def b_pared(c):
    u = 3
    column_above(c, u, 3)
    node(f'''
[node name="ParedAgrietada" parent="Objetos" instance=ExtResource("5_pared_agrietada")]
position = Vector2({c.col(u) * T}, {c.fy() - 48})''')
    c.cell(5, c.F - 1, "$")


room("A", "Calabozo", "PARED AGRIETADA",
     "PARED AGRIETADA (P48)\nVa en: calabozo y profundidades.\n"
     "Rómpela a golpes, también a puños.", 14, b_pared)


def b_palanca(c):
    palanca("Palanca", c.cx(0), c.fy(), "pruebas_palanca_reja")
    column_above(c, 3, 6)
    barrier("RejaPalanca", "Objetos", c.cx(3), c.fy() - 48, "RectangleShape2D_reja",
            'start_closed = true\nopen_on_encounter = "pruebas_palanca_reja"')
    c.cell(5, c.F - 1, "$")


room("A", "Calabozo", "PALANCA Y BARRERA",
     "PALANCA Y BARRERA (P49)\nVa en: atajos :B: a :F:, la compuerta y la jaula del rey.\n"
     "Tira la palanca (E): se abre la reja.", 14, b_palanca)


def b_lore(c):
    node(f'''
[node name="ObjetoLore" parent="Objetos" instance=ExtResource("9_lore")]
position = Vector2({c.cx(3)}, {c.fy() - 10})''')


room("A", "Calabozo", "OBJETO DE LORE",
     "OBJETO DE LORE (P50)\nVa en: calabozo (acta del preso) y el lore de todas las zonas.\n"
     "Léelo con E. Se puede releer.", 10, b_lore)


def b_empunadura(c):
    node(f'''
[node name="MejoraEmpunadura" parent="Objetos" instance=ExtResource("10_mejora")]
position = Vector2({c.cx(3)}, {c.fy() - 16})''')


room("A", "Calabozo", "EMPUÑADURA",
     "EMPUÑADURA DEL ALCAIDE (P51)\nVa en: calabozo, depósito del alcaide.\n"
     "Recógela: +0.25 de daño en los tajos con espada.", 10, b_empunadura)


def b_espada(c):
    node(f'''
[node name="EspadaOxidada" parent="Objetos" instance=ExtResource("33_espada_oxidada")]
position = Vector2({c.cx(3)}, {c.fy() - 34})
requires_sword_mission = false''')


room("A", "Calabozo", "ESPADA Y HARAPOS (E1)",
     "ESPADA OXIDADA Y HARAPOS, E1 (P69)\nVa en: calabozo, junto al preso muerto.\n"
     "Tómala con E. Mira la pestaña Equipo del menú de pausa (P70).", 10, b_espada)


# ---- 2. Castillo
def b_reja_baja(c):
    u = 4
    column_above(c, u, 3)
    node(f'''
[node name="RejaBaja" type="StaticBody2D" parent="Objetos"]
position = Vector2({c.cx(u)}, {c.fy() - 24})
script = ExtResource("11_reja")
piece_start = SubResource("AtlasTexture_reja_tope")
piece_middle = SubResource("AtlasTexture_reja_medio")
piece_end = SubResource("AtlasTexture_reja_base")
start_closed = true''')
    node('''
[node name="CollisionShape2D" type="CollisionShape2D" parent="Objetos/RejaBaja"]
shape = SubResource("RectangleShape2D_puerta")''')
    c.cell(7, c.F - 1, "$")


room("A", "Castillo", "REJA BAJA",
     "REJA BAJA (P52)\nVa en: castillo [H2] e infierno.\n"
     "Solo se pasa rodando. Pide espada.", 14, b_reja_baja)


def b_mostrar(c):
    palanca("PalancaMostrar", c.cx(0), c.fy(), "pruebas_mostrar_ocultar")
    for name, scene, u, key in (("AncianoAparece", "12_anciano", 3, "show_when_encounter"),
                                ("BarqueroDesaparece", "13_barquero", 7, "hide_when_encounter")):
        node(f'''
[node name="{name}" parent="Objetos" instance=ExtResource("{scene}")]
position = Vector2({c.cx(u)}, {c.fy() - 20})''')
        node(f'''
[node name="Visibilidad" type="Node" parent="Objetos/{name}"]
script = ExtResource("14_visibilidad")
{key} = "pruebas_mostrar_ocultar"''')


room("A", "Castillo", "MOSTRAR U OCULTAR",
     "MOSTRAR U OCULTAR (P53)\nVa en: castillo sin hechizo y rey encadenado (profundidades).\n"
     "Tira la palanca: aparece el anciano y se va el barquero.", 12, b_mostrar)


def b_fragmentos(c):
    for i in range(4):
        node(f'''
[node name="FragmentoVida{i + 1}" parent="Objetos" instance=ExtResource("15_fragmento")]
position = Vector2({c.cx(i * 2)}, {c.fy() - 16})
fragment_id = "prueba_{i + 1}"''')


room("A", "Castillo", "FRAGMENTOS DE VIDA",
     "FRAGMENTOS DE VIDA (P54)\nVan en: castillo 1/4, cementerio 2/4, ruina 3/4, profundidades 4/4.\n"
     "Los 4 dan un corazón más.", 10, b_fragmentos)


def b_soldado(c):
    node(f'''
[node name="AtuendoSoldado" parent="Objetos" instance=ExtResource("32_atuendo")]
position = Vector2({c.cx(3)}, {c.fy() - 10})''')


room("A", "Castillo", "ATUENDO SOLDADO (E2)",
     "ATUENDO DEL SOLDADO, E2 (P69)\nVa en: castillo, la armería (opcional).\n"
     "Tómalo con E. Su arte está pendiente.", 10, b_soldado)


# ---- 3. Cementerio
def b_sellos(c):
    for i in range(3):
        extra = '\nlisten_encounter = "pruebas_sello_3_escucha"' if i == 2 else ""
        node(f'''
[node name="Sello{i + 1}" parent="Objetos" instance=ExtResource("16_sello")]
position = Vector2({c.cx(i * 2)}, {c.fy() - 32})
seal_group = "pruebas_sellos"
seal_id = "{i + 1}"
seal_total = 3{extra}''')
    palanca("PalancaSello3", c.cx(6), c.fy(), "pruebas_sello_3_escucha")
    column_above(c, 8, 6)
    barrier("PuertaSellos", "Objetos", c.cx(8), c.fy() - 48, "RectangleShape2D_reja",
            'start_closed = true\nopen_on_seal_group = "pruebas_sellos"')
    c.cell(10, c.F - 1, "$")


room("B", "Cementerio", "SELLOS",
     "SELLOS (P55)\nVa en: cementerio y profundidades.\n"
     "Pulsa E en dos. El tercero lo enciende la palanca (en el juego, el Capitán).\nCon los 3 se abre la reja.",
     16, b_sellos)


def b_selectivo(c):
    node(f'''
[node name="LosaGolpeFinal" parent="Objetos" instance=ExtResource("17_selectivo")]
position = Vector2({c.col(2) * T}, {c.fy() - 48})
coin_drop_count = 2''')
    node(f'''
[node name="EstatuaUltimate" parent="Objetos" instance=ExtResource("17_selectivo")]
position = Vector2({c.col(8) * T}, {c.fy() - 48})
accepted_hit = 1
coin_drop_count = 2''')


room("B", "Cementerio", "ROMPIBLE SELECTIVO",
     "ROMPIBLE SELECTIVO (P56)\nVa en: cementerio (losa de la cripta y estatua de la Reina).\n"
     "La losa cede al tajo ascendente con Golpe final; la estatua, a la Ultimate. Pide espada.",
     14, b_selectivo)


def b_velas(c):
    node(f'''
[node name="LlaveVelas" parent="Objetos" instance=ExtResource("19_llave")]
position = Vector2({c.cx(1)}, {c.fy() - 24})
key_id = "pruebas_velas"''')
    column_above(c, 5, 3)
    node(f'''
[node name="PuertaVelas" type="StaticBody2D" parent="Objetos"]
position = Vector2({c.cx(5)}, {c.fy() - 24})
script = ExtResource("18_puerta")
piece_start = SubResource("AtlasTexture_reja_tope")
piece_middle = SubResource("AtlasTexture_reja_medio")
piece_end = SubResource("AtlasTexture_reja_base")
key_id = "pruebas_velas"
locked_message = "FALTA LA LLAMA DE LAS VELAS"
opened_message = "LAS VELAS SE ENCIENDEN"
require_interact = true
open_effect = 1
piece_tint = Color(0.85, 0.7, 0.55, 1)''')
    node('''
[node name="CollisionShape2D" type="CollisionShape2D" parent="Objetos/PuertaVelas"]
shape = SubResource("RectangleShape2D_puerta")''')
    c.cell(7, c.F - 1, "$")


room("B", "Cementerio", "PUERTA DE VELAS",
     "PUERTA DE VELAS (P57)\nVa en: cripta de la primera reina.\n"
     "Toma la llave y abre con E. Es la misma pieza que el hielo de la ruina.", 14, b_velas)


def b_amuleto(c):
    node(f'''
[node name="MejoraAmuleto" parent="Objetos" instance=ExtResource("10_mejora")]
position = Vector2({c.cx(3)}, {c.fy() - 16})
upgrade_id = "amuleto_guardia"''')


room("B", "Cementerio", "AMULETO",
     "AMULETO DE LA GUARDIA (P58)\nVa en: cementerio, estatua de la Reina.\n"
     "Recógelo: cada poción cura 0.25 más.", 10, b_amuleto)


# ---- 4. Minas
def b_ascensor(c):
    palanca("PalancaCorriente", c.cx(0), c.fy(), "pruebas_ascensor_corriente")
    ledge = c.F - 6
    for u in range(7, c.CW):
        c.cell(u, ledge, "#")
    node(f'''
[node name="AscensorAbajo" parent="Objetos" instance=ExtResource("20_ascensor")]
position = Vector2({c.cx(4)}, {c.fy()})
target_scene_path = "res://escenas/mapas/zona_pruebas_combate.tscn"
target_spawn_id = &"AscensorArriba"
arrival_spawn_id = &"AscensorAbajo"
requires_encounter = "pruebas_ascensor_corriente"
prompt_text = "E  Subir"''')
    node(f'''
[node name="AscensorArriba" parent="Objetos" instance=ExtResource("20_ascensor")]
position = Vector2({c.cx(9)}, {c.fy(ledge)})
target_scene_path = "res://escenas/mapas/zona_pruebas_combate.tscn"
target_spawn_id = &"AscensorAbajo"
arrival_spawn_id = &"AscensorArriba"
prompt_text = "E  Bajar"''')


# Enemigos nuevos del cementerio (ficha de P73): el cuervo vuela desde el
# principio; el ánima duerme como una brizna hasta que el Player se acerca.
def b_cuervo_anima(c):
    c.cell(4, c.F - 4, "o")
    c.cell(10, c.F - 3, "N")


room("B", "Cementerio", "CUERVO Y ÁNIMA",
     "CUERVO Y ÁNIMA (P73)\nVan en: cementerio, el cuervo fuera y el ánima en la cripta honda.\n"
     "El cuervo se lanza en picado (0.25). El ánima aparece al acercarte y embiste gritando (0.5).",
     16, b_cuervo_anima)


room("B", "Minas", "ASCENSOR",
     "ASCENSOR MINERO (P60)\nVa en: minas, atajo :C:.\n"
     "Sin corriente no sube: tira la palanca y sube con E a la cornisa.", 14, b_ascensor)


def b_fuego(c):
    for u in (3, 4, 5):
        c.solid(u, c.techo + 5, c.F - 5)
    left = min(c.col(3), c.col(5))
    node(f'''
[node name="FuegoInfernal" parent="Objetos" instance=ExtResource("21_fuego_infernal")]
position = Vector2({left * T}, {c.fy() - 64})
width_tiles = 3
height_tiles = 4''')
    c.cell(7, c.F - 1, "$")


room("B", "Minas", "FUEGO INFERNAL",
     "FUEGO INFERNAL (P61)\nVa en: gruta de cristal, santuario de las profundidades e infierno.\n"
     "Sin E5 quema 0.5 y empuja; con E5, nada (Modo dev, Siguiente atuendo).", 14, b_fuego)


def b_mauler(c):
    base = "Objetos/SalaMauler"
    node('''
[node name="SalaMauler" type="Node2D" parent="Objetos"]
script = ExtResource("23_sala")
encounter_id = "pruebas_sala_mauler"
boss_scene = ExtResource("22_mauler")
ability_reward = "adrenaline"
boss_message = "CRYSTAL MAULER"''')
    node(f'''
[node name="Activador" type="Area2D" parent="{base}"]
position = Vector2({c.cx(3)}, {c.fy() - 48})
collision_layer = 0
monitorable = false''')
    node(f'''
[node name="CollisionShape2D" type="CollisionShape2D" parent="{base}/Activador"]
shape = SubResource("RectangleShape2D_reja")''')
    node(f'[node name="Puertas" type="Node2D" parent="{base}"]')
    column_above(c, 1, 6)
    barrier("PuertaEntrada", f"{base}/Puertas", c.cx(1), c.fy() - 48, "RectangleShape2D_reja", disabled=True)
    node(f'[node name="Atajos" type="Node2D" parent="{base}"]')
    column_above(c, 16, 6)
    barrier("PuertaSalida", f"{base}/Atajos", c.cx(16), c.fy() - 48, "RectangleShape2D_reja", "start_closed = true")
    node(f'[node name="PuntosJefe" type="Node2D" parent="{base}"]')
    node(f'''
[node name="JefeEste" type="Marker2D" parent="{base}/PuntosJefe"]
position = Vector2({c.cx(13)}, {c.fy() - 79})''')
    node(f'''
[node name="PuntoLlave" type="Marker2D" parent="{base}"]
position = Vector2({c.cx(9)}, {c.fy() - 32})''')
    node(f'''
[node name="UI" type="CanvasLayer" parent="{base}"]
layer = 9''')
    node(AVISO.format(parent=f"{base}/UI"))
    c.cell(17, c.F - 1, "$")


AVISO = '''
[node name="Aviso" type="Label" parent="{parent}"]
anchors_preset = 10
anchor_right = 1.0
offset_top = 40.0
offset_bottom = 60.0
grow_horizontal = 2
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_constants/outline_size = 4
theme_override_font_sizes/font_size = 16
horizontal_alignment = 1
vertical_alignment = 1'''

room("B", "Minas", "CRYSTAL MAULER",
     "CRYSTAL MAULER Y SU SALA (P62, P63)\nVa en: minas, gruta de cristal (jefe opcional).\n"
     "Al entrar se cierra la reja. Al vencerlo da la Adrenalina y se abre la salida.", 22, b_mauler)


# ---- 5. Mazmorra
def b_derrumbe(c):
    top = c.F - 5          # fila de arriba de la plataforma y del suelo que se hunde
    # Plataforma maciza del lado de la escalera (u -3 a 2).
    for u in range(-3, 3):
        for r in range(top, c.F):
            c.cell(u, r, "#")
    # Reja que se cierra detrás (u 2, encima de la plataforma) y su columna.
    c.solid(2, c.techo + 1, top - 4)
    barrier("SelloDerrumbe", "Objetos", c.cx(2), c.fy(top) - 24, "RectangleShape2D_puerta", disabled=True)
    # Segunda escalera, la de salida, al otro extremo del cuarto.
    exit_col = c.x0 + c.W - 2
    ladder(exit_col, c.techo, c.F - 1)
    first = c.col(3)
    width = (exit_col - 2) - first + 1
    palanca("PalancaDerrumbe", c.cx(5), c.fy(top), "pruebas_derrumbe_palanca")
    ox, oy = first * T, c.fy(top)
    node(f'''
[node name="Derrumbe" type="Node2D" parent="Objetos"]
position = Vector2({ox}, {oy})
script = ExtResource("24_derrumbe")
trigger_encounter = "pruebas_derrumbe_palanca"
collapse_id = "pruebas_derrumbe"
sealed_barriers = Array[NodePath]([NodePath("../SelloDerrumbe")])
exit_area_path = NodePath("Salida")
floor_width_tiles = {width}
piece_texture = SubResource("AtlasTexture_losa_medio")''')
    node('[node name="Escombros" type="Node2D" parent="Objetos/Derrumbe"]')
    lower = c.fy() - oy
    for i, dx in enumerate((48, 112, 176)):
        node(f'''
[node name="Punto{i + 1}" type="Marker2D" parent="Objetos/Derrumbe/Escombros"]
position = Vector2({dx}, {lower})''')
    node(f'''
[node name="Salida" type="Area2D" parent="Objetos/Derrumbe"]
position = Vector2({exit_col * T + 8 - ox}, {lower - 32})
collision_layer = 0
monitorable = false''')
    node('''
[node name="CollisionShape2D" type="CollisionShape2D" parent="Objetos/Derrumbe/Salida"]
shape = SubResource("RectangleShape2D_salida_huida")''')
    return dict(label_from=c.col(3))


room("C", "Mazmorra", "DERRUMBE",
     "SUELO QUE SE HUNDE Y DERRUMBE (P64)\nVa en: mazmorra, tras la Reina [!5].\n"
     "Tira la palanca: se cierra la reja y el suelo cae. Huye a la derecha, esquiva los escombros (0.5) y sube por la escalera. Para repetir, F6.",
     24, b_derrumbe)


# ---- 6. Ruina
def b_llama(c):
    node(f'''
[node name="LlamaEterna" parent="Objetos" instance=ExtResource("25_llama")]
position = Vector2({c.cx(1)}, {c.fy() - 16})''')
    left = min(c.col(5), c.col(14))
    node(f'''
[node name="ZonaOscura" type="Node2D" parent="Objetos"]
position = Vector2({left * T}, {c.fy(c.techo + 5)})
script = ExtResource("26_oscuridad")
width_tiles = 10
height_tiles = {c.F - c.techo - 5}''')
    column_above(c, 10, 3)
    node(f'''
[node name="HieloAntorcha" type="StaticBody2D" parent="Objetos"]
position = Vector2({c.cx(10)}, {c.fy() - 24})
script = ExtResource("18_puerta")
piece_start = SubResource("AtlasTexture_reja_tope")
piece_middle = SubResource("AtlasTexture_reja_medio")
piece_end = SubResource("AtlasTexture_reja_base")
key_id = "antorcha"
locked_message = "NECESITAS LA LLAMA ETERNA"
opened_message = "EL HIELO SE DERRITE"
prompt_text = "E  Derretir"
require_interact = true
open_effect = 2
piece_tint = Color(0.6, 0.85, 1, 1)''')
    node('''
[node name="CollisionShape2D" type="CollisionShape2D" parent="Objetos/HieloAntorcha"]
shape = SubResource("RectangleShape2D_puerta")''')
    c.cell(13, c.F - 1, "$")


room("C", "Ruina", "LLAMA ETERNA Y HIELO",
     "LLAMA ETERNA, HIELO Y ZONA OSCURA (P65)\nVa en: ruina [P6]; el hielo negro, en las profundidades.\n"
     "Sin la llama la zona oscura apenas se ve y el hielo no cede. Tómala y derrite el hielo con E.",
     18, b_llama)


def b_dash(c):
    # Suelo una pieza más alto en todo el cuarto, pasillo de 4 de alto y foso de 6.
    for u in range(-3, c.CW):
        c.cell(u, c.F - 1, "#")
    ladder(c.col(-2), c.techo, c.F - 2)
    for u in range(3, c.CW):
        for r in range(c.techo + 5, c.F - 5):
            c.cell(u, r, "#")
    for u in range(7, 13):
        c.cell(u, c.F - 1, "^")
    node(f'''
[node name="ReliquiaDash" parent="Objetos" instance=ExtResource("27_reliquia")]
position = Vector2({c.cx(0)}, {c.fy(c.F - 1) - 16})
ability_id = "air_dash"''')


room("C", "Ruina", "DASH EN EL AIRE",
     "DASH EN EL AIRE (P66)\nVa en: ruina, premio del Guardián.\n"
     "Toma la reliquia. Con espada, Shift en el aire. El foso de 6 no se cruza sin el dash. Los pinchos matan: R.",
     24, b_dash)


# ---- 7. Profundidades
def b_profundidades(c):
    node(f'''
[node name="ManiquiFireKnight" type="AnimatedSprite2D" parent="Objetos"]
z_index = -1
position = Vector2({c.cx(4)}, {c.fy() - 63})
sprite_frames = ExtResource("31_fire_knight")
animation = &"idle"
autoplay = "idle"''')


room("C", "Profundidades", "ATUENDO FIRE KNIGHT (E5)",
     "PROFUNDIDADES\nNo pide piezas nuevas: reutiliza las de arriba.\n"
     "Maniquí: el Fire Knight, E5 (P68). Llevarlo: Modo dev, Siguiente atuendo.",
     16, b_profundidades)


# ---- 8. Infierno
def b_oleadas(c):
    base = "Objetos/ArenaOleadas"
    node('''
[node name="ArenaOleadas" type="Node2D" parent="Objetos"]
script = ExtResource("29_oleadas")
encounter_id = "pruebas_arena_oleadas"''')
    node(f'''
[node name="Activador" type="Area2D" parent="{base}"]
position = Vector2({c.cx(3)}, {c.fy() - 48})
collision_layer = 0
monitorable = false''')
    node(f'''
[node name="CollisionShape2D" type="CollisionShape2D" parent="{base}/Activador"]
shape = SubResource("RectangleShape2D_reja")''')
    node(f'[node name="Puertas" type="Node2D" parent="{base}"]')
    column_above(c, 1, 6)
    barrier("PuertaEntrada", f"{base}/Puertas", c.cx(1), c.fy() - 48, "RectangleShape2D_reja", disabled=True)
    node(f'[node name="Atajos" type="Node2D" parent="{base}"]')
    column_above(c, 18, 6)
    barrier("PuertaSalida", f"{base}/Atajos", c.cx(18), c.fy() - 48, "RectangleShape2D_reja", "start_closed = true")
    node(f'[node name="Oleadas" type="Node2D" parent="{base}"]')
    node(f'[node name="Oleada1" type="Node2D" parent="{base}/Oleadas"]')
    node(f'''
[node name="Rata" parent="{base}/Oleadas/Oleada1" instance=ExtResource("2_rata")]
position = Vector2({c.cx(8)}, {c.fy() - 20})''')
    node(f'''
[node name="Slime" parent="{base}/Oleadas/Oleada1" instance=ExtResource("3_slime")]
position = Vector2({c.cx(13)}, {c.fy() - 20})''')
    node(f'[node name="Oleada2" type="Node2D" parent="{base}/Oleadas"]')
    node(f'''
[node name="EsqueletoLanza" parent="{base}/Oleadas/Oleada2" instance=ExtResource("4_esqueleto_lanza")]
position = Vector2({c.cx(11)}, {c.fy() - 20})''')
    node(f'''
[node name="UI" type="CanvasLayer" parent="{base}"]
layer = 9''')
    node(AVISO.format(parent=f"{base}/UI"))
    c.cell(19, c.F - 1, "$")


room("C", "Infierno", "ARENA CON OLEADAS",
     "ARENA CON OLEADAS (P67)\nVa en: infierno (coliseo y salón de los verdugos) y coliseo de ceniza.\n"
     "Al entrar se cierra. Vence las 2 oleadas y se abre la salida. Si mueres, empieza de nuevo.",
     24, b_oleadas)


# ---- 9. Tilesets de las zonas vestidas (piso D, P73)
# Muestra de cada tileset: la escribe este script y la genera el constructor.
# Ocupa el cuarto menos las tres columnas de su escalera (a la derecha en el
# piso D), del techo al suelo incluido; el cuarto queda hueco en el mapa base y
# la muestra pone sus bloques, su fondo y sus decorados encima.
MUESTRAS = []


def muestra_tileset(c, tileset, filas, ext_id, label_from, sufijo="", cabecera="", fondo=None):
    """sufijo: para una segunda muestra del mismo tileset; cabecera: líneas
    más para su .txt (por ejemplo fondo_sala); fondo: la pared de la muestra,
    si el tileset no tiene una con su nombre."""
    assert c.dir == -1 and len(filas) == c.F - c.techo, (tileset, len(filas))
    assert all(len(f) == c.W - 3 for f in filas), tileset
    nombre = f"zona_pruebas_muestra_{tileset}{sufijo}"
    MUESTRAS.append((tileset, nombre, filas, ext_id, cabecera, fondo or tileset))
    node(f'''
[node name="Muestra{(tileset + sufijo).title().replace('_', '')}" parent="Objetos" instance=ExtResource("{ext_id}")]
position = Vector2({c.x0 * T}, {(c.techo + 1) * T})''')
    return {"label_from": c.x0 + label_from}


# Calabozo (ficha de P73): techo bajo a la izquierda con la telaraña (C), la
# cadena (g), la jaula (h) y una columna colgada; viga (=) con antorcha (t)
# encima y rejilla del desagüe (r); en el suelo rejas (f), barril (b), caja
# (x), estantería (E), un escalón de una pieza, la escalera (H) a una repisa
# de una pieza de alto y la armadura (T). A la derecha, aire para el cartel.
MUESTRA_CALABOZO = [
    "###########............",
    "###########............",
    "###########............",
    "###########............",
    "###########............",
    ".C........#............",
    "......g.h.#...H####....",
    "...t..........H........",
    "..............H.....t..",
    ".====...r.....H........",
    "..............H........",
    "f..bx.E...#...H..T.....",
    "#######################",
]


def b_tileset_calabozo(c):
    return muestra_tileset(c, "calabozo", MUESTRA_CALABOZO, "34_muestra_calabozo", 11)


room("D", "Calabozo", "TILESET CALABOZO",
     "TILESET CALABOZO (P73)\nBloques, viga (=), escalera, fondo y decorados del Dungeon Tile Set; "
     "antorcha de Raou. Las luces no se ven aquí (sin MapAmbience).", 26, b_tileset_calabozo)


# Castillo (ficha de P73): techo a la izquierda con el estandarte (h), el
# cuadro (Q) y el trofeo de cráneo de dragón (D) en la pared con pilastras;
# dos tablones (=) a distinta altura, el de abajo con antorcha (t); en el suelo
# el armero (A), el estante con provisiones (O), el cofre del Mimic (c), la
# armadura (T), la estantería (E) y un barril (b), y la escalera (H) a una
# repisa. A la derecha, arriba, aire para el cartel.
MUESTRA_CASTILLO = [
    "#############..............",
    "#############..............",
    "#############..............",
    "#############..............",
    "#############..............",
    "...........................",
    "..h............===.........",
    ".....Q................H####",
    "........D...........t.H....",
    "..............=====...H....",
    "......................H....",
    ".A..O...c..T...E......H..b.",
    "###########################",
]


def b_tileset_castillo(c):
    return muestra_tileset(c, "castillo", MUESTRA_CASTILLO, "35_muestra_castillo", 13)


room("D", "Castillo", "TILESET CASTILLO",
     "TILESET CASTILLO (P73)\nPared con pilastras, tablón (=) y estandarte (h) de Raou y craftpix; "
     "armero (A), trofeo (D), provisiones (O), cuadro (Q) y el cofre del Mimic (c).", 30, b_tileset_castillo)


# Castillo, ficha revisada (P73): una pared por sala con fondo_sala, de
# izquierda a derecha libros (biblioteca), arcada (gran salón), piedra clara
# (capilla), madera oscura (aposentos) y columnas (trono); y los decorados
# nuevos: lámparas (y) colgadas del techo, tapiz (U), ventana de celosía (w),
# columna alta (K), estantería alta (l), mesas (n) y mostrador (V), con dos
# tablones (=) delante de las paredes. A la derecha, arriba, aire para el cartel.
MUESTRA_CASTILLO_SALAS = [
    "...y.............y...............",
    ".................................",
    ".................................",
    ".................................",
    "........U........................",
    "...............w.................",
    ".......................=====.....",
    ".====............................",
    ".................................",
    ".................................",
    "............................U....",
    ".l..n......K.........V...n.......",
    "#################################",
]
FONDOS_CASTILLO_SALAS = (
    "fondo_sala: libros 0 0 6 12\n"
    "fondo_sala: arcada 7 0 13 12\n"
    "fondo_sala: piedra_clara 14 0 19 12\n"
    "fondo_sala: madera_oscura 20 0 25 12\n"
    "fondo_sala: columnas 26 0 32 12\n"
)


def b_castillo_salas(c):
    return muestra_tileset(c, "castillo", MUESTRA_CASTILLO_SALAS, "36_muestra_castillo_salas", 20,
                           sufijo="_salas", cabecera=FONDOS_CASTILLO_SALAS)


room("D", "Castillo", "CASTILLO, SALAS",
     "CASTILLO, SALAS (P73)\nUna pared por sala (fondo_sala): libros, arcada, piedra clara, madera oscura "
     "y columnas; lámpara (y), tapiz (U), celosía (w), columna (K), estantería (l), mesa (n) y mostrador (V).",
     36, b_castillo_salas)


# Cementerio (ficha de P73): a la izquierda el exterior, sin pared (aquí se ve
# la de la zona de pruebas; en el mapa, el parallax), con la lápida inclinada
# (Q), el árbol muerto (D), la cruz (K) y el arbusto (O); a la derecha la
# cripta (bloques_sala cripta, sin pasto), con pared de tierra y de ladrillo,
# una columna, una tira y una pieza suelta (macizas), la repisa de piedra (=),
# el arco con calavera (U), la gárgola (A), las calaveras amontonadas (E), el
# nicho con llama (V) y las calaveras en la pared (n). Sin parallax: un
# Parallax2D dentro de la muestra taparía la galería.
MUESTRA_CEMENTERIO = [
    ".................................",
    ".................................",
    ".................................",
    ".................................",
    ".................................",
    ".................................",
    "........................###......",
    "....................#U.......A...",
    "....................#........===.",
    "....................#..#.........",
    "....................#............",
    "Q.D..........K.O....#E..V..n.....",
    "#################################",
]
CABECERA_CEMENTERIO = (
    "fondo_sala: ninguno 0 0 19 12\n"
    "fondo_sala: ladrillo 26 0 32 11\n"
    "bloques_sala: cripta 20 0 32 12\n"
)


def b_tileset_cementerio(c):
    return muestra_tileset(c, "cementerio", MUESTRA_CEMENTERIO, "37_muestra_cementerio", 13,
                           cabecera=CABECERA_CEMENTERIO, fondo="tierra")


room("D", "Cementerio", "TILESET CEMENTERIO",
     "TILESET CEMENTERIO (P73)\nExterior con pasto; cripta sin pasto (bloques_sala), paredes de tierra y "
     "ladrillo, repisa de piedra (=), cruz (K), lápida (Q), árbol (D), arbusto (O), arco (U), gárgola (A), "
     "calaveras (E, n) y nicho con llama (V).", 36, b_tileset_cementerio)


# ---------------------------------------------------------------- colocar
def add_label(name, x, y, w, h, text, variation=None, align=0, header=False):
    carteles.append((name, x, y, w, h, text, variation, align, header))


label_n = 0
for piso, rooms in ROOMS.items():
    p = PISOS[piso]
    zona_prev = None
    if p["dir"] == 1:
        x = 22 if piso == "A" else 7
    else:
        x = 136
    for rm in rooms:
        W = rm["W"]
        if zona_prev is not None:
            gap = 3 if rm["zona"] != zona_prev else 1
            x += gap * p["dir"]
        x0 = x if p["dir"] == 1 else x - W + 1
        # Vaciar el cuarto.
        for r in range(p["techo"] + 1, p["suelo"]):
            for cc in range(x0, x0 + W):
                put(r, cc, ".")
        c = Ctx(piso, x0, W)
        ladder(c.col(-2), p["techo"], p["suelo"] - 1)
        info = rm["build"](c) or {}
        label_n += 1
        rx, rw = x0 * T, W * T
        corr_y = p["corr"] * T
        if rm["zona"] != zona_prev:
            add_label(f"Zona{label_n}", rx + 2, corr_y + 1, max(rw, 200), 24,
                      rm["zona"], "Encabezado", 0 if p["dir"] == 1 else 0, header=True)
        add_label(f"Nombre{label_n}", rx + 2, corr_y + 30, rw - 4, 20,
                  rm["nombre"], "TextoAcento", 1)
        lx = info.get("label_from", x0) * T
        add_label(f"Texto{label_n}", lx + 4, (p["techo"] + 1) * T + 2,
                  (x0 + W) * T - lx - 8, 76, rm["texto"])
        zona_prev = rm["zona"]
        x = (x0 + W) if p["dir"] == 1 else x0 - 1

# Carteles fijos.
add_label("Inicio", 5 * T, 14 * T, 160, 40,
          "GALERIA DE PIEZAS\nBaja por la escalera (S).", "TextoAcento", 0)
add_label("Galeria", 6 * T, 24 * T + 2, 240, 24,
          "Galería de piezas", "Encabezado", 0, header=True)
add_label("GaleriaTexto", 6 * T, 24 * T + 30, 240, 30,
          "Un cuarto por pieza, en el orden de la ruta. Baja a cada cuarto con S en su escalera. Espada: Modo dev (º), Dar espada.")

# ---------------------------------------------------------------- salida .txt
for r in range(ROWS):
    assert g[r][0] == "#" and g[r][COLS - 1] == "#", r
mapa = "\n".join("".join(row) for row in g)
header = Path(sys.argv[1]).read_text(encoding="utf-8") if len(sys.argv) > 1 else head + "\n"
TXT.write_text(header + "---\n" + mapa + "\n", encoding="utf-8")
for tileset, nombre, filas, _, cabecera, fondo in MUESTRAS:
    (ROOT / f"mapas_texto/{nombre}.txt").write_text(
        f"; Muestra del tileset {tileset} para la galería de la zona de pruebas (P73).\n"
        "; La escribe herramientas/zona_pruebas/galeria.py: no se edita a mano.\n"
        f"escena: res://escenas/mapas/{nombre}.tscn\n"
        f"tileset: {tileset}\nbloques: {tileset}\nfondo: {fondo}\n{cabecera}muestra: si\n---\n"
        + "\n".join(filas) + "\n", encoding="utf-8")

# ---------------------------------------------------------------- salida .tscn
ext = '''[ext_resource type="PackedScene" path="res://escenas/enemigos/rata.tscn" id="2_rata"]
[ext_resource type="PackedScene" path="res://escenas/enemigos/slime.tscn" id="3_slime"]
[ext_resource type="PackedScene" path="res://escenas/enemigos/esqueleto_lanza.tscn" id="4_esqueleto_lanza"]
[ext_resource type="PackedScene" path="res://escenas/objetos/pared_agrietada.tscn" id="5_pared_agrietada"]
[ext_resource type="PackedScene" path="res://escenas/objetos/palanca.tscn" id="6_palanca"]
[ext_resource type="Script" path="res://scripts/environment/arena_barrier.gd" id="7_barrera"]
[ext_resource type="Texture2D" path="res://assets/terceros/raou_castillo/tileset_castillo.png" id="8_tileset"]
[ext_resource type="PackedScene" path="res://escenas/objetos/objeto_lore.tscn" id="9_lore"]
[ext_resource type="PackedScene" path="res://escenas/items/mejora_encontrada.tscn" id="10_mejora"]
[ext_resource type="Script" path="res://scripts/environment/roll_gate.gd" id="11_reja"]
[ext_resource type="PackedScene" path="res://escenas/npc/anciano.tscn" id="12_anciano"]
[ext_resource type="PackedScene" path="res://escenas/npc/barquero.tscn" id="13_barquero"]
[ext_resource type="Script" path="res://scripts/environment/encounter_visibility.gd" id="14_visibilidad"]
[ext_resource type="PackedScene" path="res://escenas/items/fragmento_vida.tscn" id="15_fragmento"]
[ext_resource type="PackedScene" path="res://escenas/objetos/sello.tscn" id="16_sello"]
[ext_resource type="PackedScene" path="res://escenas/objetos/rompible_selectivo.tscn" id="17_selectivo"]
[ext_resource type="Script" path="res://scripts/environment/locked_door.gd" id="18_puerta"]
[ext_resource type="PackedScene" path="res://escenas/items/llave_jefe_m1.tscn" id="19_llave"]
[ext_resource type="PackedScene" path="res://escenas/objetos/ascensor.tscn" id="20_ascensor"]
[ext_resource type="PackedScene" path="res://escenas/sistemas/fuego_infernal.tscn" id="21_fuego_infernal"]
[ext_resource type="PackedScene" path="res://escenas/jefes/crystal_mauler.tscn" id="22_mauler"]
[ext_resource type="Script" path="res://scripts/combat/boss_arena.gd" id="23_sala"]
[ext_resource type="Script" path="res://scripts/environment/collapse_sequence.gd" id="24_derrumbe"]
[ext_resource type="PackedScene" path="res://escenas/items/llama_eterna.tscn" id="25_llama"]
[ext_resource type="Script" path="res://scripts/environment/dark_zone.gd" id="26_oscuridad"]
[ext_resource type="PackedScene" path="res://escenas/items/reliquia_habilidad.tscn" id="27_reliquia"]
[ext_resource type="Script" path="res://scripts/combat/wave_arena.gd" id="29_oleadas"]
[ext_resource type="SpriteFrames" path="res://escenas/atuendos/fire_knight.tres" id="31_fire_knight"]
[ext_resource type="PackedScene" path="res://escenas/objetos/atuendo.tscn" id="32_atuendo"]
[ext_resource type="PackedScene" path="res://escenas/objetos/espada_oxidada.tscn" id="33_espada_oxidada"]
''' + "".join(
    f'[ext_resource type="PackedScene" path="res://escenas/mapas/{nombre}.tscn" id="{ext_id}"]\n'
    for _, nombre, _, ext_id, _, _ in MUESTRAS)
sub = '''[sub_resource type="AtlasTexture" id="AtlasTexture_losa_medio"]
atlas = ExtResource("8_tileset")
region = Rect2(16, 304, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_reja_tope"]
atlas = ExtResource("8_tileset")
region = Rect2(48, 256, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_reja_medio"]
atlas = ExtResource("8_tileset")
region = Rect2(48, 272, 16, 16)

[sub_resource type="AtlasTexture" id="AtlasTexture_reja_base"]
atlas = ExtResource("8_tileset")
region = Rect2(48, 288, 16, 16)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_reja"]
size = Vector2(16, 96)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_puerta"]
size = Vector2(16, 48)

[sub_resource type="RectangleShape2D" id="RectangleShape2D_salida_huida"]
size = Vector2(48, 64)
'''
# Raíz de la galería. `Enemigos` recibe al jefe de la sala del Mauler
# (spawn_parent_path "../../Enemigos" de boss_arena.gd).
first_nodes = '''[node name="Galeria" type="Node2D"]

[node name="Enemigos" type="Node2D" parent="."]

[node name="Objetos" type="Node2D" parent="."]'''


def esc(s):
    return s.replace("\\", "\\\\").replace('"', '\\"')


labels = ['[node name="Carteles" type="Node2D" parent="."]']
for name, x, y, w, h, text, var, align, header in carteles:
    lines = [f'[node name="{name}" type="Label" parent="Carteles"]',
             f"offset_left = {float(x)}", f"offset_top = {float(y)}",
             f"offset_right = {float(x + w)}", f"offset_bottom = {float(y + h)}"]
    if var:
        lines.append(f'theme_type_variation = &"{var}"')
    if not header:
        lines += ["theme_override_colors/font_outline_color = Color(0, 0, 0, 1)",
                  "theme_override_constants/outline_size = 3"]
    lines.append(f'text = "{esc(text)}"')
    if align:
        lines.append(f"horizontal_alignment = {align}")
    if not header:
        lines.append("autowrap_mode = 3")
    labels.append("\n".join(lines))

out = "[gd_scene format=3]\n\n" + ext + "\n" + sub + "\n" + first_nodes + "\n\n" + \
    "\n\n".join(nodes) + "\n\n" + "\n\n".join(labels) + "\n"
TSCN.write_text(out, encoding="utf-8")
print("cuartos:", {k: len(v) for k, v in ROOMS.items()}, "nodos:", len(nodes), "carteles:", len(carteles))
