# Verifica que los ASCII de cada zona encajen con mapas_texto/macro/conexiones.txt
# y, con --unir, los pega en un solo mapa del mundo (docs/P46_MACRO_MAPA.md, sección 9).
#   python3 herramientas/macro_mapa/verificar_mundo.py [--unir archivo.txt]
# Sale con código 1 si hay errores.
import os
import sys

RAIZ = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', '..'))
ZONAS = os.path.join(RAIZ, 'mapas_texto', 'macro', 'zonas.txt')
CONEXIONES = os.path.join(RAIZ, 'mapas_texto', 'macro', 'conexiones.txt')
SOLIDO = set('#/\\')
LADOS = ('arriba', 'abajo', 'izq', 'der')
OPUESTO = {'arriba': 'abajo', 'abajo': 'arriba', 'izq': 'der', 'der': 'izq'}

errores: list[str] = []
avisos: list[str] = []


def filas(ruta: str) -> list[list[str]]:
    with open(ruta, encoding='utf-8') as f:
        return [l.split() for l in f if l.strip() and not l.lstrip().startswith(';')]


def num(v: str) -> int | None:
    return None if v in ('?', '-') else int(v)


def leer_mapa(ruta: str) -> list[str]:
    # Igual que el constructor: lo que va después de la línea ---.
    with open(ruta, encoding='utf-8') as f:
        lineas = f.read().splitlines()
    if '---' in [l.strip() for l in lineas]:
        lineas = lineas[[l.strip() for l in lineas].index('---') + 1:]
    mapa = [l.rstrip(' \t') for l in lineas if l.strip()]
    ancho = max(len(l) for l in mapa)
    return [l.ljust(ancho, '.') for l in mapa]


def borde(mapa: list[str], lado: str) -> str:
    if lado == 'arriba': return mapa[0]
    if lado == 'abajo': return mapa[-1]
    col = 0 if lado == 'izq' else len(mapa[0]) - 1
    return ''.join(l[col] for l in mapa)


def huecos(linea: str) -> list[tuple[int, int]]:
    # Tramos abiertos de un borde: (primera pieza, ancho).
    res, ini = [], None
    for i, c in enumerate(linea + '#'):
        if c not in SOLIDO and ini is None: ini = i
        elif c in SOLIDO and ini is not None: res.append((ini, i - ini)); ini = None
    return res


# Zonas
zonas: dict[str, dict] = {}
for z, escena, fuente, x, y in filas(ZONAS):
    zona = {'escena': escena, 'x': num(x), 'y': num(y), 'mapa': None}
    if fuente != '-':
        ruta = os.path.join(RAIZ, fuente)
        if os.path.exists(ruta):
            zona['mapa'] = leer_mapa(ruta)
        else:
            avisos.append(f'{z}: sin dibujar todavía ({fuente})')
    zonas[z] = zona

# Conexiones
conexiones = []
for fila in filas(CONEXIONES):
    cid, tipo, za, la, pa, zb, lb, pb, ancho, coloca = fila
    # pos "-": la conexión no es una apertura del borde (p. ej. llega a un spawn).
    c = dict(id=cid, tipo=tipo, a=(za, la, pa if pa == '-' else num(pa)), b=(zb, lb, pb if pb == '-' else num(pb)),
             ancho=num(ancho), coloca=coloca)
    conexiones.append(c)
    for z, lado, _ in (c['a'], c['b']):
        if z not in zonas: errores.append(f'{cid}: zona desconocida "{z}"')
        if lado not in LADOS: errores.append(f'{cid}: lado desconocido "{lado}"')
    if la in LADOS and lb != OPUESTO[la]:
        errores.append(f'{cid}: sale por {la} de {za} y entra por {lb} de {zb}; deben ser lados opuestos')
    if coloca == 'constructor' and la not in ('izq', 'der'):
        errores.append(f'{cid}: el constructor solo pone salidas en los bordes izq/der; usar "combate"')

# Cada apertura, en su zona
usados: dict[tuple[str, str], list[tuple[int, int]]] = {}
for c in conexiones:
    for z, lado, pos in (c['a'], c['b']):
        mapa = zonas.get(z, {}).get('mapa')
        if mapa is None or lado not in LADOS or pos == '-': continue
        if pos is None or c['ancho'] is None:
            avisos.append(f'{c["id"]}: falta posición o ancho en {z} ({lado})')
            continue
        usados.setdefault((z, lado), []).append((pos, c['ancho']))
        if (pos, c['ancho']) not in huecos(borde(mapa, lado)):
            errores.append(f'{c["id"]}: en {z} no hay una apertura de {c["ancho"]} piezas en {lado}, pieza {pos}')
        if c['coloca'] == 'constructor':
            marca = '>' if (z, lado) == c['a'][:2] else '<'
            if marca not in borde(mapa, lado)[pos:pos + c['ancho']]:
                errores.append(f'{c["id"]}: en {z} falta la salida "{marca}" en {lado}, pieza {pos}')

# Aperturas del borde que no están en la tabla
for z, zona in zonas.items():
    if zona['mapa'] is None: continue
    for lado in LADOS:
        for h in huecos(borde(zona['mapa'], lado)):
            if h not in usados.get((z, lado), []):
                avisos.append(f'{z}: apertura en {lado}, pieza {h[0]}, ancho {h[1]}, que no está en conexiones.txt')

# Constructor: una salida > y una < por zona como mucho
for z in zonas:
    sig = [c['id'] for c in conexiones if c['coloca'] == 'constructor' and c['a'][0] == z]
    ant = [c['id'] for c in conexiones if c['coloca'] == 'constructor' and c['b'][0] == z]
    if len(sig) > 1 or len(ant) > 1:
        errores.append(f'{z}: el constructor solo tiene un destino "siguiente" y uno "anterior" ({sig + ant})')


# Mundo: rectángulos sin solaparse y aperturas alineadas
def rect(z: str) -> tuple[int, int, int, int] | None:
    zona = zonas[z]
    if zona['mapa'] is None or zona['x'] is None or zona['y'] is None: return None
    return zona['x'], zona['y'], len(zona['mapa'][0]), len(zona['mapa'])


colocadas = [z for z in zonas if rect(z)]
for i, z1 in enumerate(colocadas):
    x1, y1, w1, h1 = rect(z1)
    for z2 in colocadas[i + 1:]:
        x2, y2, w2, h2 = rect(z2)
        if x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1:
            errores.append(f'{z1} y {z2} se solapan en el mundo')

tuneles = []
for c in conexiones:
    (za, la, pa), (zb, lb, pb) = c['a'], c['b']
    ra, rb = rect(za) if za in zonas else None, rect(zb) if zb in zonas else None
    if not ra or not rb or not isinstance(pa, int) or not isinstance(pb, int): continue
    xa, ya, wa, ha = ra
    xb, yb, wb, hb = rb
    if la in ('arriba', 'abajo'):
        if xa + pa != xb + pb:
            errores.append(f'{c["id"]}: columna del mundo distinta ({za} {xa + pa}, {zb} {xb + pb})')
        y0, y1 = (ya + ha, yb) if la == 'abajo' else (yb + hb, ya)
        if y1 < y0: errores.append(f'{c["id"]}: {zb} no está {"debajo" if la == "abajo" else "encima"} de {za}')
        else: tuneles.append((c, 'v', xa + pa, y0, y1))
    else:
        if ya + pa != yb + pb:
            errores.append(f'{c["id"]}: fila del mundo distinta ({za} {ya + pa}, {zb} {yb + pb})')
        x0, x1 = (xa + wa, xb) if la == 'der' else (xb + wb, xa)
        if x1 < x0: errores.append(f'{c["id"]}: {zb} no está a la {"derecha" if la == "der" else "izquierda"} de {za}')
        else: tuneles.append((c, 'h', ya + pa, x0, x1))

for c, eje, fijo, ini, fin in tuneles:
    if fin > ini:
        avisos.append(f'{c["id"]}: las zonas no se tocan; túnel de {fin - ini} piezas entre ellas')
    for z in colocadas:
        x, y, w, h = rect(z)
        dentro = (x <= fijo < x + w and ini < y + h and y < fin) if eje == 'v' else \
                 (y <= fijo < y + h and ini < x + w and x < fin)
        if dentro: errores.append(f'{c["id"]}: el túnel atraviesa {z}')

# Unir
if '--unir' in sys.argv:
    salida = sys.argv[sys.argv.index('--unir') + 1]
    if not colocadas:
        errores.append('--unir: ninguna zona tiene ASCII y posición todavía')
    else:
        x0 = min(rect(z)[0] for z in colocadas); y0 = min(rect(z)[1] for z in colocadas)
        x1 = max(rect(z)[0] + rect(z)[2] for z in colocadas)
        y1 = max(rect(z)[1] + rect(z)[3] for z in colocadas)
        g = [[' '] * (x1 - x0) for _ in range(y1 - y0)]
        for z in colocadas:
            x, y, _, _ = rect(z)
            for j, linea in enumerate(zonas[z]['mapa']):
                for i, ch in enumerate(linea): g[y - y0 + j][x - x0 + i] = ch
        for c, eje, fijo, ini, fin in tuneles:
            for k in range(ini, fin):
                for d in range(c['ancho']):
                    if eje == 'v': g[k - y0][fijo + d - x0] = '|'
                    else: g[fijo + d - y0][k - x0] = '-'
        with open(salida, 'w', encoding='utf-8') as f:
            f.write('\n'.join(''.join(r).rstrip() for r in g) + '\n')
        print(f'Mundo unido en {salida} ({x1 - x0} x {y1 - y0} piezas)')

for a in avisos: print('AVISO', a)
for e in errores: print('ERROR', e)
print(f'{len(errores)} errores, {len(avisos)} avisos')
sys.exit(1 if errores else 0)
