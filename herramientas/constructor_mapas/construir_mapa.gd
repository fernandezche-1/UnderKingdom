extends Node

## Convierte un mapa escrito como texto (una letra = una pieza) o dibujado como
## imagen (un píxel = una pieza) en una escena de Godot hecha con tiles.
##
## Uso, desde la carpeta del proyecto:
##   ~/.local/bin/godot --headless res://herramientas/constructor_mapas/construir_mapa.tscn -- mapas_texto/ejemplo_cueva.txt
## Otras órdenes (en lugar del archivo):
##   -- --paleta              escribe la paleta de colores en mapas_texto/
##   -- --a-png <mapa.txt>    convierte el mapa de texto en un PNG para dibujarlo
##   -- --desde-mapa <escena.tscn> <salida.png>
##                            calca un mapa hecho a mano (fondo y colisiones)
##                            como PNG de piezas, para rehacerlo con tiles
##
## La leyenda está en mapas_texto/LEYENDA.md. Las piezas de cada tileset
## (bloques, decorados, líquidos...) se definen en
## herramientas/constructor_mapas/tilesets/<nombre>.gd.
## Solo sobrescribe escenas que haya creado este mismo constructor.

const TILESETS_DIR := "res://herramientas/constructor_mapas/tilesets/"
const GENERATED_META := &"generado_por_constructor"
const PALETTE_PATH := "res://mapas_texto/paleta_niveles"
## Muestras por lado al calcar cada pieza de un mapa hecho a mano.
const TRACE_SAMPLES := 4

## Color de cada letra en los mapas dibujados como imagen (blanco o
## transparente = vacío). Los colores siguen las marcas del proyecto donde
## existen: verde one-way, rojo/rosado muerte, azul siguiente, morado anterior.
const COLORS := {
    "#": ["000000", "bloque sólido"],
    "/": ["404040", "rampa que sube a la derecha"],
    "\\": ["808080", "rampa que sube a la izquierda"],
    "=": ["00ff00", "plataforma de una vía"],
    "~": ["ff0000", "lava (mata)"],
    "^": ["ff80c0", "pinchos (matan)"],
    "F": ["ff8000", "trampa de fuego (quema)"],
    "%": ["0080ff", "agua (decorativa)"],
    "H": ["8b4513", "escalera"],
    "P": ["00ffff", "inicio del Player"],
    ">": ["0000ff", "salida al mapa siguiente"],
    "<": ["8000ff", "salida al mapa anterior"],
    "S": ["007000", "checkpoint"],
    "c": ["c06000", "cofre"],
    "$": ["ffd700", "moneda"],
    "!": ["ff00ff", "poción"],
    "v": ["800000", "Vanguardia"],
    "a": ["808000", "Aprendis"],
    "k": ["008080", "kolbo"],
    "j": ["000080", "kolbo2 (rápido)"],
    "q": ["800080", "kolbo3 (resistente)"],
    "d": ["c00060", "diablillo"],
    "M": ["503000", "mino"],
    "m": ["402060", "murciélago"],
    "e": ["d0d0b0", "esqueleto"],
    "u": ["706050", "esqueleto de tumba"],
    "G": ["b0b0d0", "Guardia"],
    "t": ["ffc090", "antorcha"],
    "f": ["c03000", "fogata"],
    "b": ["a08060", "barril"],
    "x": ["e0b060", "caja"],
    "h": ["c0ffc0", "hongos"],
    "g": ["60c060", "pasto"],
    "r": ["c0c0ff", "cristales"],
    "T": ["206020", "árbol (2x3)"],
    "E": ["604080", "estantería (3x3)"],
    "C": ["e0e0a0", "tienda de campaña (3x2)"],
}

const PLAYER_SCENE := "res://escenas/player.tscn"
const CHECKPOINT_SCENE := "res://escenas/sistemas/checkpoint.tscn"
const FIRE_TRAP_SCENE := "res://escenas/sistemas/trampa_fuego.tscn"
const TRANSITION_SCENE := "res://escenas/sistemas/map_transition.tscn"
const SPAWN_SCENE := "res://escenas/sistemas/spawn_point.tscn"
const CHEST_SCENE := "res://escenas/objetos/cofre.tscn"
const SPIKES_TEXTURE := "res://sprites/trampas/pinchos.png"
const PICKUPS := {
    "$": "res://escenas/objetos/coin_pickup.tscn",
    "!": "res://escenas/objetos/potion_pickup.tscn",
}
## Salidas: letra -> [opción con el mapa destino, spawn de llegada en el
## destino, spawn que se crea aquí para volver desde ese mapa].
const EXITS := {
    ">": ["siguiente", "DesdeAnterior", "DesdeSiguiente"],
    "<": ["anterior", "DesdeSiguiente", "DesdeAnterior"],
}

const ENEMIES := {
    "v": "res://escenas/enemigos/vanguardia.tscn",
    "a": "res://escenas/enemigos/aprendis.tscn",
    "k": "res://escenas/enemigos/kolbo.tscn",
    "j": "res://escenas/enemigos/kolbo2.tscn",
    "q": "res://escenas/enemigos/kolbo3.tscn",
    "d": "res://escenas/enemigos/diablillo.tscn",
    "M": "res://escenas/enemigos/mino.tscn",
    "m": "res://escenas/enemigos/murcielago.tscn",
    "e": "res://escenas/enemigos/esqueleto.tscn",
    "u": "res://escenas/enemigos/esqueleto_tumba.tscn",
    "G": "res://escenas/enemigos/guardia.tscn",
}

var _grid: Array[String] = []
var _w := 0
var _h := 0
## Tamaño de pieza en píxeles, según el tileset elegido.
var T := 16
## Datos del tileset elegido (ver tilesets/mazmorra.gd).
var _ts: Dictionary = {}


func _ready() -> void:
    var args := OS.get_cmdline_user_args()
    if args.is_empty():
        _fail("Falta el archivo de texto. Uso: ... construir_mapa.tscn -- mapas_texto/mi_mapa.txt")
        return
    var error := ""
    if args[0] == "--paleta":
        error = _write_palette()
    elif args[0] == "--a-png":
        error = _text_to_png(args[1] if args.size() > 1 else "")
    elif args[0] == "--desde-mapa":
        error = _scene_to_png(args[1] if args.size() > 1 else "", args[2] if args.size() > 2 else "")
    else:
        error = _build(args[0])
    if error != "":
        _fail(error)
        return
    get_tree().quit(0)


func _fail(message: String) -> void:
    printerr("CONSTRUCTOR: " + message)
    get_tree().quit(1)


func _res(path: String) -> String:
    return path if path.begins_with("res://") else "res://" + path


## Cabecera "clave: valor" hasta la línea ---, después el mapa de texto.
func _read_map_file(text_path: String, options: Dictionary) -> String:
    var file := FileAccess.open(_res(text_path), FileAccess.READ)
    if file == null:
        return "No se pudo abrir %s" % text_path
    var in_map := false
    while not file.eof_reached():
        var line := file.get_line()
        if not in_map:
            var clean := line.strip_edges()
            if clean == "---":
                in_map = true
            elif clean != "" and not clean.begins_with(";") and ":" in clean:
                var parts := clean.split(":", true, 1)
                options[parts[0].strip_edges()] = parts[1].strip_edges()
        elif line.strip_edges() != "":
            _grid.append(line.rstrip(" \t"))
    return ""


func _color_letters() -> Dictionary:
    var by_color := {}
    for letter in COLORS:
        by_color[COLORS[letter][0]] = letter
    return by_color


## Un píxel = una pieza. Blanco o transparente = vacío; cualquier otro color
## tiene que estar exactamente en la paleta (sin suavizado al dibujar).
func _grid_from_image(image_path: String) -> String:
    var img := Image.load_from_file(ProjectSettings.globalize_path(_res(image_path)))
    if img == null or img.is_empty():
        return "No se pudo abrir la imagen %s" % image_path
    img.convert(Image.FORMAT_RGBA8)
    var by_color := _color_letters()
    var unknown := {}
    for y in img.get_height():
        var row := ""
        for x in img.get_width():
            var c := img.get_pixel(x, y)
            var hex := c.to_html(false)
            if c.a < 0.5 or hex == "ffffff":
                row += "."
            elif by_color.has(hex):
                row += by_color[hex]
            else:
                row += "."
                if unknown.size() < 10:
                    unknown["#%s en (%d, %d)" % [hex, x, y]] = true
        _grid.append(row)
    if not unknown.is_empty():
        return "La imagen tiene colores que no están en la paleta (¿pincel con suavizado?): %s" % ", ".join(unknown.keys())
    return ""


## Paleta para Aseprite, GIMP, Krita o Piskel (.gpl) y una muestra en PNG.
func _write_palette() -> String:
    var gpl := "GIMP Palette\nName: UnderKingdom niveles\nColumns: 8\n#\n"
    gpl += "255 255 255\tvacío (.)\n"
    var letters := COLORS.keys()
    var swatches := Image.create(8 * 8, ceili((letters.size() + 1) / 8.0) * 8, false, Image.FORMAT_RGBA8)
    swatches.fill(Color.WHITE)
    for i in letters.size():
        var c := Color.html(COLORS[letters[i]][0])
        gpl += "%3d %3d %3d\t%s (%s)\n" % [c.r8, c.g8, c.b8, COLORS[letters[i]][1], letters[i]]
        swatches.fill_rect(Rect2i(((i + 1) % 8) * 8, ((i + 1) / 8) * 8, 8, 8), c)
    var file := FileAccess.open(PALETTE_PATH + ".gpl", FileAccess.WRITE)
    if file == null:
        return "No se pudo escribir %s.gpl" % PALETTE_PATH
    file.store_string(gpl)
    file.close()
    var err := swatches.save_png(ProjectSettings.globalize_path(PALETTE_PATH + ".png"))
    if err != OK:
        return "No se pudo escribir %s.png" % PALETTE_PATH
    print("CONSTRUCTOR: paleta escrita en %s.gpl y %s.png" % [PALETTE_PATH, PALETTE_PATH])
    return ""


## Convierte un mapa de texto en un PNG con los colores de la paleta, para
## seguir editándolo como dibujo. Escribe <mapa>.png junto al .txt.
func _text_to_png(text_path: String) -> String:
    if text_path == "":
        return "Uso: -- --a-png mapas_texto/mi_mapa.txt"
    var error := _read_map_file(text_path, {})
    if error != "":
        return error
    if _grid.is_empty():
        return "%s no tiene mapa de texto después de la línea ---" % text_path
    var width := 0
    for row in _grid:
        width = maxi(width, row.length())
    var img := Image.create(width, _grid.size(), false, Image.FORMAT_RGBA8)
    img.fill(Color.WHITE)
    for y in _grid.size():
        for x in _grid[y].length():
            var ch := _grid[y][x]
            if COLORS.has(ch):
                img.set_pixel(x, y, Color.html(COLORS[ch][0]))
    var out := _res(text_path).get_basename() + ".png"
    if img.save_png(ProjectSettings.globalize_path(out)) != OK:
        return "No se pudo escribir %s" % out
    print("CONSTRUCTOR: %s escrita (%d x %d). En el .txt cambia el mapa por \"imagen: %s\"." % [out, width, _grid.size(), out.trim_prefix("res://")])
    return ""


## Calca un mapa hecho a mano como dibujo de piezas: las colisiones sólidas
## pasan a bloques y rampas, las one-way a plataformas, las zonas de escalera
## a escaleras, y los enemigos y el inicio del Player a sus letras. Los
## escalones de una pieza se convierten en rampas para subirlos caminando, y
## el nivel queda cerrado por los lados y por abajo. Las salidas, cofres,
## trampas y decorados se dibujan después sobre el PNG.
func _scene_to_png(scene_path: String, out_path: String) -> String:
    if scene_path == "" or out_path == "":
        return "Uso: -- --desde-mapa res://escenas/mapas/<mapa>.tscn mapas_texto/<nivel>.png"
    scene_path = _res(scene_path)
    if not ResourceLoader.exists(scene_path):
        return "No existe %s" % scene_path
    var root: Node = (load(scene_path) as PackedScene).instantiate()
    var found := {"solid": [], "one_way": [], "climb": [], "actors": [], "start": Vector2(-1, -1), "route_start": Vector2(-1, -1)}
    _collect_trace(root, found)
    var size := Vector2.ZERO
    var bounds := root.get_node_or_null("SistemasMapa/MapBounds")
    if bounds != null:
        size = Vector2(bounds.get("right"), bounds.get("bottom"))
    root.free()
    if size == Vector2.ZERO:
        for poly: PackedVector2Array in found.solid:
            for p in poly:
                size = size.max(p)
    _w = ceili(size.x / T)
    _h = ceili(size.y / T)
    if _w < 2 or _h < 2:
        return "%s no tiene colisiones ni MapBounds que calcar." % scene_path

    var cells := PackedStringArray()
    cells.resize(_w * _h)
    cells.fill(".")
    var n := TRACE_SAMPLES
    var solid := _trace_masks(found.solid)
    var one_way := _trace_masks(found.one_way)
    for i in cells.size():
        var bits := solid[i]
        # Rampa: la altura cubierta crece de una columna de muestras a la
        # siguiente, de casi vacía a casi llena. Un piso a media pieza no cuenta.
        var heights := []
        for sx in n:
            var column := 0
            for sy in n:
                column += (bits >> (sy * n + sx)) & 1
            heights.append(column)
        if _rising(heights):
            cells[i] = "/"
        else:
            heights.reverse()
            if _rising(heights):
                cells[i] = "\\"
            elif _bit_count(bits) * 2 >= n * n:
                cells[i] = "#"
    # Plataformas one-way: solo la fila de arriba de cada una.
    for y in _h:
        for x in _w:
            var i := y * _w + x
            if cells[i] == "." and _bit_count(one_way[i]) >= n - 1 and (y == 0 or _bit_count(one_way[i - _w]) < n - 1):
                cells[i] = "="
    # Escalones de una pieza: una rampa delante, si queda espacio para pasar.
    var ramps := 0
    for y in range(3, _h):
        for x in _w:
            if not _cell_is(cells, x, y, "#") or not _cell_is(cells, x, y - 1, ".") or not _cell_is(cells, x, y - 2, ".") or not _cell_is(cells, x, y - 3, "."):
                continue
            for side in [1, -1]:
                if _cell_is(cells, x + side, y - 1, "#") and _cell_is(cells, x + side, y - 2, "."):
                    cells[(y - 1) * _w + x] = "/" if side == 1 else "\\"
                    ramps += 1
                    break
    for y in _h:
        cells[y * _w] = "#"
        cells[y * _w + _w - 1] = "#"
    for x in _w:
        cells[(_h - 1) * _w + x] = "#"
    for zone: PackedVector2Array in found.climb:
        var box := Rect2(zone[0], Vector2.ZERO)
        for p in zone:
            box = box.expand(p)
        # La columna de la zona con más piezas libres (el hueco del piso por el
        # que pasa la escalera); a igualdad, la más cercana al centro.
        var x := floori(box.get_center().x / T)
        var best := -1
        for column in range(floori(box.position.x / T), ceili(box.end.x / T)):
            var free_cells := 0
            for y in range(floori(box.position.y / T), ceili(box.end.y / T)):
                free_cells += int(_cell_is(cells, column, y, "."))
            if free_cells > best or (free_cells == best and absf(column + 0.5 - box.get_center().x / T) < absf(x + 0.5 - box.get_center().x / T)):
                best = free_cells
                x = column
        for y in range(floori(box.position.y / T), ceili(box.end.y / T)):
            if _cell_is(cells, x, y, "."):
                cells[y * _w + x] = "H"

    var letters := {PLAYER_SCENE: "P"}
    for letter in ENEMIES:
        letters[ENEMIES[letter]] = letter
    var start: Vector2 = found.start
    var skipped := []
    var placed := 0
    for actor in found.actors:
        if actor[0] == PLAYER_SCENE:
            if start.x < 0:
                start = actor[1]
        elif letters.has(actor[0]):
            placed += int(_drop_letter(cells, actor[1], letters[actor[0]]))
        else:
            skipped.append("%s en %s" % [String(actor[0]).get_file() if actor[0] != "" else "sin escena", actor[1].round()])
    if start.x < 0:
        start = found.route_start
    if start.x >= 0 and not _drop_letter(cells, start, "P"):
        start = Vector2(-1, -1)

    var img := Image.create(_w, _h, false, Image.FORMAT_RGBA8)
    img.fill(Color.WHITE)
    for y in _h:
        for x in _w:
            var ch := cells[y * _w + x]
            if ch != ".":
                img.set_pixel(x, y, Color.html(COLORS[ch][0]))
    var out := _res(out_path)
    if img.save_png(ProjectSettings.globalize_path(out)) != OK:
        return "No se pudo escribir %s" % out
    print("CONSTRUCTOR: %s calcado en %s (%d x %d piezas). Rampas añadidas en escalones: %d, enemigos: %d, escaleras: %d." % [
        scene_path, out, _w, _h, ramps, placed, found.climb.size()])
    if start.x < 0:
        print("CONSTRUCTOR: aviso, el mapa no tiene inicio del Player; dibuja la P.")
    if not skipped.is_empty():
        print("CONSTRUCTOR: sin letra (jefes, NPC...), no se calcan: %s." % ", ".join(skipped))
    print("CONSTRUCTOR: falta dibujar las salidas, cofres, trampas y decorados.")
    return ""


## Junta lo que se calca de un mapa: polígonos sólidos y one-way (capas 1 y
## 2; los rompibles no), zonas de escalera, personajes e inicio del Player.
func _collect_trace(node: Node, found: Dictionary) -> void:
    if node is StaticBody2D or node is AnimatableBody2D:
        var layer: int = (node as CollisionObject2D).collision_layer
        if layer & 3:
            for item in _body_polygons(node):
                found["one_way" if item[1] or not (layer & 1) else "solid"].append(item[0])
    elif node is Area2D:
        if node.is_in_group("climb_zone"):
            for item in _body_polygons(node):
                found.climb.append(item[0])
        return
    elif node is CharacterBody2D:
        found.actors.append([node.scene_file_path, _global_xf(node).origin])
        return
    elif node.get(&"spawn_id") == &"SpawnInicio":
        found.start = _global_xf(node).origin
    elif node.get_script() != null and "spawn_position" in node and String(node.get_script().resource_path).ends_with("world_test_route.gd"):
        found.route_start = node.get("spawn_position")
    for child in node.get_children():
        _collect_trace(child, found)


## Polígonos de las formas de un cuerpo en coordenadas del mapa: [puntos, one_way].
func _body_polygons(body: Node) -> Array:
    var result := []
    for child in body.get_children():
        var points := PackedVector2Array()
        if child is CollisionPolygon2D and not child.disabled:
            points = child.polygon
        elif child is CollisionShape2D and not child.disabled and child.shape != null:
            var shape: Shape2D = child.shape
            if shape is RectangleShape2D or shape is CapsuleShape2D:
                var half: Vector2 = shape.size * 0.5 if shape is RectangleShape2D else Vector2(shape.radius, shape.height * 0.5)
                points = PackedVector2Array([-half, Vector2(half.x, -half.y), half, Vector2(-half.x, half.y)])
            elif shape is CircleShape2D:
                for i in 12:
                    points.append(Vector2.from_angle(TAU * i / 12.0) * shape.radius)
            elif shape is ConvexPolygonShape2D:
                points = shape.points
        if points.size() >= 3:
            result.append([_global_xf(child) * points, child.one_way_collision])
    return result


## Transformación global sin que la escena esté en el árbol.
func _global_xf(node: Node) -> Transform2D:
    var xf := Transform2D.IDENTITY
    while node != null:
        if node is Node2D:
            xf = (node as Node2D).transform * xf
        node = node.get_parent()
    return xf


## Por cada pieza, una máscara de bits con las muestras que caen dentro de
## algún polígono (TRACE_SAMPLES x TRACE_SAMPLES muestras por pieza).
func _trace_masks(polygons: Array) -> PackedInt32Array:
    var masks := PackedInt32Array()
    masks.resize(_w * _h)
    var n := TRACE_SAMPLES
    for poly: PackedVector2Array in polygons:
        var box := Rect2(poly[0], Vector2.ZERO)
        for p in poly:
            box = box.expand(p)
        for y in range(clampi(floori(box.position.y / T), 0, _h - 1), clampi(floori(box.end.y / T), 0, _h - 1) + 1):
            for x in range(clampi(floori(box.position.x / T), 0, _w - 1), clampi(floori(box.end.x / T), 0, _w - 1) + 1):
                var bits := masks[y * _w + x]
                for sy in n:
                    for sx in n:
                        var p := Vector2((x + (sx + 0.5) / n) * T, (y + (sy + 0.5) / n) * T)
                        if Geometry2D.is_point_in_polygon(p, poly):
                            bits |= 1 << (sy * n + sx)
                masks[y * _w + x] = bits
    return masks


## Alturas por columna que suben de izquierda a derecha como una rampa de 45°.
func _rising(heights: Array) -> bool:
    # Un salto brusco entre columnas es una pared a media pieza, no una rampa.
    for i in range(1, heights.size()):
        if heights[i] < heights[i - 1] or heights[i] - heights[i - 1] > 2:
            return false
    return heights[0] <= 1 and heights[-1] >= TRACE_SAMPLES - 1 and heights[-1] - heights[0] >= TRACE_SAMPLES / 2


func _cell_is(cells: PackedStringArray, x: int, y: int, value: String) -> bool:
    return x >= 0 and y >= 0 and x < _w and y < _h and cells[y * _w + x] == value


func _bit_count(bits: int) -> int:
    var total := 0
    while bits != 0:
        bits &= bits - 1
        total += 1
    return total


## Pone la letra en la pieza libre que queda justo encima del suelo, bajando
## desde la posición dada (o subiendo si cae dentro de un bloque).
func _drop_letter(cells: PackedStringArray, pos: Vector2, letter: String) -> bool:
    var x := clampi(floori(pos.x / T), 1, _w - 2)
    var y := clampi(floori(pos.y / T), 0, _h - 2)
    while y > 0 and cells[y * _w + x] != ".":
        y -= 1
    while y < _h - 1 and cells[(y + 1) * _w + x] == ".":
        y += 1
    if cells[y * _w + x] != "." or not cells[(y + 1) * _w + x] in ["#", "/", "\\", "="]:
        return false
    cells[y * _w + x] = letter
    return true


func _build(text_path: String) -> String:
    var options := {
        "tileset": "mazmorra", "bloques": "", "fondo": "cueva", "escena": "", "imagen": "",
        "siguiente": "", "anterior": "", "cofre_monedas": "3", "cofre_pociones": "1", "parallax": "",
        "depuracion": "no", "jugador": PLAYER_SCENE,
    }
    var error := _read_map_file(text_path, options)
    if error != "":
        return error
    if options.imagen != "":
        if not _grid.is_empty():
            return "El archivo tiene \"imagen:\" y también un mapa de texto; usa solo uno."
        error = _grid_from_image(options.imagen)
        if error != "":
            return error
    if _grid.is_empty():
        return "El archivo no tiene mapa después de la línea --- ni una línea \"imagen:\"."
    var ts_path: String = TILESETS_DIR + options.tileset + ".gd"
    if not ResourceLoader.exists(ts_path):
        return "tileset: '%s' no existe (falta %s)" % [options.tileset, ts_path]
    _ts = (load(ts_path) as GDScript).get_script_constant_map()["DATA"]
    T = _ts.tile
    if options.bloques == "":
        options.bloques = _ts.bloques_por_defecto
    if not _ts.bloques.has(options.bloques):
        return "bloques: '%s' no existe. Opciones: %s" % [options.bloques, ", ".join(_ts.bloques.keys())]
    if options.fondo != "ninguno" and not _ts.fondos.has(options.fondo):
        return "fondo: '%s' no existe. Opciones: ninguno, %s" % [options.fondo, ", ".join(_ts.fondos.keys())]
    var out_path: String = options.escena
    if not out_path.begins_with("res://escenas/mapas/") or not out_path.ends_with(".tscn"):
        return "escena: debe ser res://escenas/mapas/<nombre>.tscn"
    if ResourceLoader.exists(out_path):
        var existing: Node = (load(out_path) as PackedScene).instantiate()
        var ours := existing.has_meta(GENERATED_META)
        existing.free()
        if not ours:
            return "%s ya existe y no la creó el constructor; no se sobrescribe." % out_path

    _h = _grid.size()
    for row in _grid:
        _w = maxi(_w, row.length())
    for letter in EXITS:
        var option: String = EXITS[letter][0]
        if _count(letter) > 0 and options[option] == "":
            return "El mapa tiene salidas '%s' pero falta \"%s: res://escenas/mapas/<mapa>.tscn\"." % [letter, option]
        var target := String(options[option]).get_slice("#", 0)
        if target != "" and not ResourceLoader.exists(target):
            print("CONSTRUCTOR: aviso, %s todavía no existe; la salida funcionará cuando se cree." % target)
    # parallax: "<imagen> <velocidad> [x2]; ...", de la más lejana a la más
    # cercana. Velocidad 0 = quieta en pantalla, 1 = se mueve con el mapa.
    # x2 dibuja la imagen al doble (escala entera) si es más baja que la pantalla.
    var parallax_layers := []
    for spec in String(options.parallax).split(";", false):
        var words := spec.strip_edges().split(" ", false)
        var scale := 1
        if words.size() > 2 and words[-1] in ["x1", "x2", "x3"]:
            scale = int(words[-1].substr(1))
            words.remove_at(words.size() - 1)
        if words.size() < 2 or not words[-1].is_valid_float():
            return "parallax: falta la velocidad en '%s' (por ejemplo \"fondos/cielo.png 0.2\")." % spec.strip_edges()
        var image_path := _res(" ".join(words.slice(0, -1)))
        if not ResourceLoader.exists(image_path):
            return "parallax: no existe la imagen %s" % image_path
        parallax_layers.append([image_path, float(words[-1]), scale])
    if not parallax_layers.is_empty() and options.fondo != "ninguno":
        print("CONSTRUCTOR: aviso, el fondo '%s' tapa el parallax; usa \"fondo: ninguno\" para verlo." % options.fondo)

    var tex: Texture2D = load(_ts.textura)
    var img := tex.get_image()
    img.convert(Image.FORMAT_RGBA8)

    var root := Node2D.new()
    root.name = out_path.get_file().get_basename().to_pascal_case()
    root.set_meta(GENERATED_META, true)
    root.set_meta(&"texto_fuente", text_path)

    var screen := Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
    for i in parallax_layers.size():
        var layer_tex: Texture2D = load(parallax_layers[i][0])
        var scale: int = parallax_layers[i][2]
        var layer_size := layer_tex.get_size() * scale
        var parallax := Parallax2D.new()
        # En vertical la imagen recorre el mapa: su borde de arriba se ve con la
        # cámara arriba del todo y el de abajo con la cámara abajo del todo.
        var spare_y := _h * T - screen.y
        var follow_y := clampf((layer_size.y - screen.y) / spare_y, 0.0, 1.0) if spare_y > 0 else 0.0
        parallax.scroll_scale = Vector2(parallax_layers[i][1], follow_y)
        parallax.repeat_size = Vector2(layer_size.x, 0)
        parallax.repeat_times = ceili(screen.x / layer_size.x) + 1
        parallax.z_index = -20 + i
        _child(root, parallax, "Parallax%d" % (i + 1))
        var picture := Sprite2D.new()
        picture.texture = layer_tex
        picture.centered = false
        picture.scale = Vector2(scale, scale)
        _child(parallax, picture, "Imagen")
        if layer_size.y < screen.y:
            print("CONSTRUCTOR: aviso, %s mide %d px de alto y la pantalla %d; usa x2." % [parallax_layers[i][0], layer_size.y, screen.y])

    var fondo := _layer(root, "Fondo", _tileset(tex, img, "decorado"), -10)
    var liquidos := _layer(root, "Liquidos", _tileset(tex, img, "decorado"), 2)
    var terreno := _layer(root, "Terreno", _tileset(tex, img, "solido"), 0)
    var plataformas := _layer(root, "Plataformas", _tileset(tex, img, "plataforma"), 0)
    var decorado := _layer(root, "Decorado", _tileset(tex, img, "decorado"), 1)

    var sistemas := _child(root, Node2D.new(), "SistemasMapa")
    var kill_zones := _child(sistemas, Node2D.new(), "KillZones")
    var climb_zones := _child(sistemas, Node2D.new(), "Escaleras")
    var enemies := _child(root, Node2D.new(), "Enemigos")
    var player_feet := _feet_offset(String(options.jugador))

    var set_base: Vector2i = _ts.bloques[options.bloques][0]
    var slope_base: Vector2i = _ts.bloques[options.bloques][1]
    var decor: Dictionary = _ts.decorados
    var spawn := Vector2(-1, -1)
    var counts := {}

    if options.fondo != "ninguno":
        var pattern_base: Vector2i = _ts.fondos[options.fondo][0]
        var pattern_size: Vector2i = _ts.fondos[options.fondo][1]
        for y in _h:
            for x in _w:
                fondo.set_cell(Vector2i(x, y), 0, pattern_base + Vector2i(x % pattern_size.x, y % pattern_size.y))

    for y in _h:
        for x in _w:
            var ch := _at(x, y)
            var cell := Vector2i(x, y)
            counts[ch] = counts.get(ch, 0) + 1
            match ch:
                "#":
                    terreno.set_cell(cell, 0, set_base + _block_piece(x, y))
                "/":
                    terreno.set_cell(cell, 0, slope_base + Vector2i(1, 1))
                "\\":
                    terreno.set_cell(cell, 0, slope_base + Vector2i(0, 1))
                "=":
                    var left := _at(x - 1, y) == "="
                    var right := _at(x + 1, y) == "="
                    var piece := 1 if left and right else (0 if right else (2 if left else 1))
                    plataformas.set_cell(cell, 0, set_base + Vector2i(piece, 3))
                "~":
                    liquidos.set_cell(cell, 0, _ts.lava[1])
                    if not _is_liquid(x, y - 1):
                        liquidos.set_cell(cell + Vector2i(0, -1), 0, _ts.lava[0])
                "%":
                    liquidos.set_cell(cell, 0, _ts.agua[1])
                    if not _is_liquid(x, y - 1):
                        liquidos.set_cell(cell + Vector2i(0, -1), 0, _ts.agua[0])
                "H":
                    decorado.set_cell(cell, 0, _ts.escalera)
                "P":
                    spawn = Vector2((x + 0.5) * T, (y + 1) * T)
                "F":
                    var fire: Node2D = _instance(_group(sistemas, "BurnZones"), FIRE_TRAP_SCENE, "Fuego")
                    fire.position = Vector2((x + 0.5) * T, (y + 1) * T)
                "S":
                    # El checkpoint queda donde reaparece el Player, de pie en la pieza.
                    decorado.set_cell(cell, 0, _ts.checkpoint)
                    var checkpoint: Node2D = _instance(_group(sistemas, "Checkpoints"), CHECKPOINT_SCENE, "Checkpoint")
                    checkpoint.position = Vector2((x + 0.5) * T, (y + 1) * T - player_feet)
                "c":
                    var chest: Node2D = _instance(_group(root, "Objetos"), CHEST_SCENE, "Cofre")
                    chest.position = Vector2((x + 0.5) * T, (y + 1) * T - _sprite_half_height(chest))
                    chest.set("coin_count", int(options.cofre_monedas))
                    chest.set("potion_count", int(options.cofre_pociones))
                _:
                    if decor.has(ch):
                        var base: Vector2i = decor[ch][0]
                        var size: Vector2i = decor[ch][1]
                        # La letra marca la pieza de abajo a la izquierda.
                        for dy in size.y:
                            for dx in size.x:
                                decorado.set_cell(
                                    Vector2i(x + dx, y - size.y + 1 + dy), 0,
                                    base + Vector2i(dx, -size.y + 1 + dy)
                                )
                    elif ENEMIES.has(ch):
                        var enemy_name := String(ENEMIES[ch]).get_file().get_basename().capitalize()
                        _place_on_floor(enemies, ENEMIES[ch], x, y, "%s%d" % [enemy_name, enemies.get_child_count() + 1])
                    elif PICKUPS.has(ch):
                        var pickup: Node2D = _instance(_group(root, "Objetos"), PICKUPS[ch], "Moneda" if ch == "$" else "Pocion")
                        pickup.position = Vector2((x + 0.5) * T, (y + 0.5) * T)

    # Zonas de muerte sobre cada tramo horizontal de lava.
    _add_runs(kill_zones, "~", true, "res://escenas/sistemas/kill_zone.tscn", "Lava", Vector2(0, 6))
    # Pinchos: zona de muerte en la parte baja de la pieza y el dibujo repetido.
    for run in _add_runs(kill_zones, "^", true, "res://escenas/sistemas/kill_zone.tscn", "Pinchos", Vector2(1, T - 8)):
        var spikes_tex: Texture2D = load(SPIKES_TEXTURE)
        var zone: Node2D = run[0]
        var rect: Rect2 = run[1]
        var sprite := Sprite2D.new()
        sprite.texture = spikes_tex
        sprite.centered = false
        sprite.region_enabled = true
        sprite.region_rect = Rect2(0, 0, rect.size.x + 2, spikes_tex.get_height())
        sprite.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
        sprite.position = Vector2(rect.position.x - 1, rect.end.y - spikes_tex.get_height()) - zone.position
        _child(zone, sprite, "Dibujo")
    # Zonas para trepar en cada columna de escalera (una pieza extra arriba).
    _add_runs(climb_zones, "H", false, "res://escenas/sistemas/climb_zone.tscn", "Escalera", Vector2.ZERO)
    # Salidas: una transición por columna y un spawn dos piezas hacia dentro
    # para llegar desde ese mapa sin volver a tocar la salida.
    for letter in EXITS:
        if _count(letter) == 0:
            continue
        var exit: Array = EXITS[letter]
        var target: String = options[exit[0]]
        for run in _add_runs(_group(sistemas, "Transiciones"), letter, false, TRANSITION_SCENE, "Salida" + String(exit[0]).capitalize(), Vector2.ZERO):
            var transition: Node2D = run[0]
            var rect: Rect2 = run[1]
            transition.set("target_scene_path", target.get_slice("#", 0))
            transition.set("target_spawn_id", StringName(target.get_slice("#", 1)) if "#" in target else StringName(exit[1]))
            var inward := 1.0 if rect.get_center().x < _w * T * 0.5 else -1.0
            var arrival: Node2D = _instance(sistemas, SPAWN_SCENE, String(exit[2]))
            arrival.set("spawn_id", StringName(exit[2]))
            arrival.position = Vector2(rect.get_center().x + inward * 2 * T, rect.end.y - player_feet)

    var bounds := _child(sistemas, Node2D.new(), "MapBounds")
    bounds.set_script(load("res://scripts/camera/map_bounds.gd"))
    bounds.set("right", _w * T)
    bounds.set("bottom", _h * T)
    var controller := _child(sistemas, Node.new(), "SpawnController")
    controller.set_script(load("res://scripts/transitions/map_spawn_controller.gd"))

    if spawn.x < 0:
        root.free()
        return "Falta la P (inicio del Player) en el mapa."
    var marker: Node2D = _child(sistemas, (load(SPAWN_SCENE) as PackedScene).instantiate(), "SpawnInicio")
    marker.position = spawn - Vector2(0, player_feet)
    var player := _place_on_floor(root, String(options.jugador), int(spawn.x / T), int(spawn.y / T) - 1, "player")
    # Teclas de depuración (R/H/J/K) y panel solo en mapas de prueba ("depuracion: si").
    if String(options.depuracion) == "si":
        player.set("enable_debug_keys", true)
        player.set("show_debug_hud", true)

    var packed := PackedScene.new()
    var err := packed.pack(root)
    if err == OK:
        err = ResourceSaver.save(packed, out_path)
    root.free()
    if err != OK:
        return "No se pudo guardar %s (error %d)" % [out_path, err]
    print("CONSTRUCTOR: %s creada (%d x %d piezas, %d x %d px). Bloques: %d, rampas: %d, plataformas: %d, lava: %d, escaleras: %d, enemigos: %d." % [
        out_path, _w, _h, _w * T, _h * T, counts.get("#", 0), counts.get("/", 0) + counts.get("\\", 0),
        counts.get("=", 0), counts.get("~", 0), counts.get("H", 0), ENEMIES.keys().reduce(func(total, key): return total + counts.get(key, 0), 0)])
    var extras := []
    for pair in [["^", "pinchos"], ["F", "fuego"], ["S", "checkpoints"], ["c", "cofres"], ["$", "monedas"], ["!", "pociones"], [">", "salida siguiente"], ["<", "salida anterior"]]:
        if counts.get(pair[0], 0) > 0:
            extras.append("%s: %d" % [pair[1], counts[pair[0]]])
    if not extras.is_empty():
        print("CONSTRUCTOR: además %s." % ", ".join(extras))
    return ""


func _at(x: int, y: int) -> String:
    if y < 0 or y >= _h or x < 0:
        return ""
    var row := _grid[y]
    return row[x] if x < row.length() else "."


func _is_liquid(x: int, y: int) -> bool:
    return _at(x, y) in ["~", "%"]


func _solid(x: int, y: int) -> bool:
    # Fuera del mapa cuenta como sólido: así los bordes del nivel no llevan contorno.
    if x < 0 or y < 0 or x >= _w or y >= _h:
        return true
    return _at(x, y) in ["#", "/", "\\"]


## Elige esquina, borde, interior, plataforma o columna según los vecinos.
func _block_piece(x: int, y: int) -> Vector2i:
    var n := _solid(x, y - 1)
    var s := _solid(x, y + 1)
    var w := _solid(x - 1, y)
    var e := _solid(x + 1, y)
    if not w and not e:
        if not n and not s:
            return Vector2i(3, 3)
        return Vector2i(3, 0 if not n else (2 if not s else 1))
    if not n and not s:
        return Vector2i(0 if not w else (2 if not e else 1), 3)
    return Vector2i(0 if not w else (2 if not e else 1), 0 if not n else (2 if not s else 1))


func _feet_offset(scene_path: String) -> float:
    var node: Node = (load(scene_path) as PackedScene).instantiate()
    var offset := 0.0
    var shape_node := node.get_node_or_null("CollisionShape2D") as CollisionShape2D
    if shape_node != null and shape_node.shape is RectangleShape2D:
        offset = shape_node.position.y + (shape_node.shape as RectangleShape2D).size.y * 0.5
    elif shape_node != null and shape_node.shape is CapsuleShape2D:
        offset = shape_node.position.y + (shape_node.shape as CapsuleShape2D).height * 0.5
    node.free()
    return offset


## Coloca una escena con los pies sobre el borde inferior de la celda (x, y).
func _place_on_floor(parent: Node, scene_path: String, x: int, y: int, node_name: String) -> Node2D:
    var node: Node2D = (load(scene_path) as PackedScene).instantiate()
    node.position = Vector2((x + 0.5) * T, (y + 1) * T - _feet_offset(scene_path))
    _child(parent, node, node_name)
    return node


## Una zona por cada tramo seguido de la letra (horizontal o vertical).
## Devuelve [zona, rectángulo en píxeles] de cada una.
func _add_runs(parent: Node, letter: String, horizontal: bool, scene_path: String, base_name: String, inset: Vector2) -> Array:
    var created := []
    var seen := {}
    var index := 0
    for y in _h:
        for x in _w:
            if _at(x, y) != letter or seen.has(Vector2i(x, y)):
                continue
            var length := 0
            while _at(x + (length if horizontal else 0), y + (0 if horizontal else length)) == letter:
                seen[Vector2i(x + (length if horizontal else 0), y + (0 if horizontal else length))] = true
                length += 1
            var rect := Rect2(x * T, y * T, (length if horizontal else 1) * T, (1 if horizontal else length) * T)
            if not horizontal:
                rect = rect.grow_individual(4, T, 4, 0)
            rect = rect.grow_individual(-inset.x, -inset.y, -inset.x, 0)
            index += 1
            var zone: Node2D = _child(parent, (load(scene_path) as PackedScene).instantiate(), "%s%d" % [base_name, index])
            zone.position = rect.get_center()
            var shape := RectangleShape2D.new()
            shape.size = rect.size
            (zone.get_node("CollisionShape2D") as CollisionShape2D).shape = shape
            # Sin "hijos editables" la escena guardada ignora la forma nueva y
            # la zona queda con el tamaño por defecto de su escena.
            zone.owner.set_editable_instance(zone, true)
            created.append([zone, rect])
    return created


func _count(letter: String) -> int:
    var total := 0
    for row in _grid:
        total += row.count(letter)
    return total


## Contenedor con ese nombre dentro de parent; se crea la primera vez.
func _group(parent: Node, group_name: String) -> Node:
    var existing := parent.get_node_or_null(group_name)
    return existing if existing != null else _child(parent, Node2D.new(), group_name)


func _instance(parent: Node, scene_path: String, base_name: String) -> Node:
    return _child(parent, (load(scene_path) as PackedScene).instantiate(), "%s%d" % [base_name, parent.get_child_count() + 1])


func _sprite_half_height(node: Node) -> float:
    var sprite := node as AnimatedSprite2D
    if sprite == null or sprite.sprite_frames == null:
        return T * 0.5
    return sprite.sprite_frames.get_frame_texture(sprite.animation, 0).get_height() * 0.5


func _child(parent: Node, node: Node, node_name: String) -> Node:
    node.name = node_name
    parent.add_child(node)
    var root := parent if parent.owner == null else parent.owner
    node.owner = root
    return node


func _layer(root: Node, layer_name: String, ts: TileSet, z: int) -> TileMapLayer:
    var layer := TileMapLayer.new()
    layer.tile_set = ts
    layer.z_index = z
    return _child(root, layer, layer_name)


func _opaque(img: Image, cell: Vector2i, px: Vector2i) -> bool:
    return img.get_pixel(cell.x * T + px.x, cell.y * T + px.y).a > 0.5


## Colisión deducida de la pieza: cuadrado si sus 4 esquinas son sólidas,
## triángulo (rampa) si son 3, ninguna si son menos.
func _collision_points(img: Image, cell: Vector2i) -> PackedVector2Array:
    var h := T * 0.5
    var corners := [
        [Vector2(-h, -h), Vector2i(1, 1)], [Vector2(h, -h), Vector2i(T - 2, 1)],
        [Vector2(h, h), Vector2i(T - 2, T - 2)], [Vector2(-h, h), Vector2i(1, T - 2)],
    ]
    var pts := PackedVector2Array()
    for c in corners:
        if _opaque(img, cell, c[1]):
            pts.append(c[0])
    return pts if pts.size() >= 3 else PackedVector2Array()


func _tileset(tex: Texture2D, img: Image, mode: String) -> TileSet:
    var ts := TileSet.new()
    ts.tile_size = Vector2i(T, T)
    if mode != "decorado":
        ts.add_physics_layer()
        ts.set_physics_layer_collision_layer(0, 1 if mode == "solido" else 2)
        ts.set_physics_layer_collision_mask(0, 0)
    var src := TileSetAtlasSource.new()
    src.texture = tex
    src.texture_region_size = Vector2i(T, T)
    ts.add_source(src, 0)

    var taken := {}
    if mode == "decorado":
        var animated: Dictionary = _ts.animadas
        for base in animated:
            var anim: Array = animated[base]
            src.create_tile(base)
            src.set_tile_animation_columns(base, anim[1])
            src.set_tile_animation_frames_count(base, anim[0])
            src.set_tile_animation_speed(base, anim[2])
            for i in int(anim[0]):
                taken[base + (Vector2i(0, i) if anim[1] == 1 else Vector2i(i, 0))] = true

    var grid := src.get_atlas_grid_size()
    for y in grid.y:
        for x in grid.x:
            var cell := Vector2i(x, y)
            if taken.has(cell) or img.get_region(Rect2i(cell * T, Vector2i(T, T))).is_invisible():
                continue
            src.create_tile(cell)
            if mode == "decorado":
                continue
            var pts := _collision_points(img, cell)
            if pts.is_empty():
                continue
            var data := src.get_tile_data(cell, 0)
            data.add_collision_polygon(0)
            if mode == "plataforma":
                var h := T * 0.5
                pts = PackedVector2Array([Vector2(-h, -h), Vector2(h, -h), Vector2(h, -h + 6), Vector2(-h, -h + 6)])
                data.set_collision_polygon_one_way(0, 0, true)
            data.set_collision_polygon_points(0, 0, pts)
    return ts
