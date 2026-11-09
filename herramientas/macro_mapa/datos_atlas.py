# Genera los datos del Atlas de UnderKingdom (el artefacto con el mapa del mundo
# unido) desde el repo: zonas.txt, conexiones.txt, el ASCII de cada zona y el
# mundo que saca verificar_mundo.py --unir (docs/P46_MACRO_MAPA.md, sección 9).
#   python3 herramientas/macro_mapa/datos_atlas.py atlas.html
# Sustituye la línea "const D = {...};" del HTML del atlas por los datos de hoy.
# Sin archivo, escribe la línea por la salida estándar.
import json
import os
import subprocess
import sys
import tempfile

RAIZ = os.path.normpath(os.path.join(os.path.dirname(__file__), '..', '..'))
ZONAS = os.path.join(RAIZ, 'mapas_texto', 'macro', 'zonas.txt')
CONEXIONES = os.path.join(RAIZ, 'mapas_texto', 'macro', 'conexiones.txt')
VERIFICADOR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'verificar_mundo.py')
PREFIJO = 'const D = '


def filas(ruta: str) -> list[list[str]]:
    with open(ruta, encoding='utf-8') as f:
        return [l.split() for l in f if l.strip() and not l.lstrip().startswith(';')]


def leer_fuente(ruta: str) -> tuple[list[str], str, dict[str, str]]:
    """Mapa (como verificar_mundo.py), comentarios de la cabecera y opciones."""
    with open(ruta, encoding='utf-8') as f:
        lineas = f.read().splitlines()
    limpias = [l.strip() for l in lineas]
    corte = limpias.index('---') if '---' in limpias else -1
    cabecera = lineas[:corte] if corte >= 0 else []
    notas: list[str] = []
    opciones: dict[str, str] = {}
    for l in cabecera:
        s = l.strip()
        if s.startswith(';'):
            s = s[1:]
            notas.append(s[1:] if s.startswith(' ') else s)
        elif ':' in s:
            k, v = s.split(':', 1)
            opciones[k.strip()] = v.strip()
    mapa = [l.rstrip(' \t') for l in lineas[corte + 1:] if l.strip()]
    ancho = max(len(l) for l in mapa)
    return [l.ljust(ancho, '.') for l in mapa], '\n'.join(notas).strip('\n'), opciones


def mundo_unido() -> list[str]:
    with tempfile.TemporaryDirectory() as tmp:
        salida = os.path.join(tmp, 'mundo.txt')
        r = subprocess.run([sys.executable, VERIFICADOR, '--unir', salida], capture_output=True, text=True)
        if r.returncode != 0 or not os.path.exists(salida):
            sys.exit('verificar_mundo.py dio errores; no se generan los datos del atlas:\n' + r.stdout)
        with open(salida, encoding='utf-8') as f:
            return f.read().rstrip('\n').split('\n')


def num(v: str) -> int | None:
    return None if v in ('?', '-') else int(v)


def celdas_borde(z: dict, lado: str, pos: int, ancho: int) -> list[int]:
    x, y, w, h = z['x'], z['y'], z['w'], z['h']
    if lado == 'arriba': return [x + pos, y, x + pos + ancho - 1, y]
    if lado == 'abajo': return [x + pos, y + h - 1, x + pos + ancho - 1, y + h - 1]
    if lado == 'izq': return [x, y + pos, x, y + pos + ancho - 1]
    return [x + w - 1, y + pos, x + w - 1, y + pos + ancho - 1]


def datos() -> dict:
    zonas: list[dict] = []
    por_id: dict[str, dict] = {}
    for zid, escena, fuente, x, y in filas(ZONAS):
        z: dict = {'id': zid, 'escena': escena, 'colocada': False, 'fuente': fuente}
        ruta = os.path.join(RAIZ, fuente)
        if fuente != '-' and os.path.exists(ruta):
            mapa, notas, opciones = leer_fuente(ruta)
            if num(x) is not None and num(y) is not None:
                z.update(colocada=True, x=int(x), y=int(y), w=len(mapa[0]), h=len(mapa))
            z['notas'] = notas
            z['tileset'] = opciones.get('tileset', '')
            z['bloques'] = opciones.get('bloques', '')
        zonas.append(z)
        por_id[zid] = z

    colocadas = [z for z in zonas if z['colocada']]
    x0 = min(z['x'] for z in colocadas)
    y0 = min(z['y'] for z in colocadas)

    conexiones: list[dict] = []
    tuneles: list[list] = []
    for cid, tipo, za, la, pa, zb, lb, pb, ancho, coloca in filas(CONEXIONES):
        c = {'id': cid, 'tipo': tipo, 'a': [za, la, pa], 'b': [zb, lb, pb], 'ancho': ancho, 'coloca': coloca, 'rects': []}
        a, b = por_id.get(za), por_id.get(zb)
        n = num(ancho)
        if a and b and a['colocada'] and b['colocada'] and None not in (num(pa), num(pb), n):
            ra = celdas_borde(a, la, int(pa), n)
            rb = celdas_borde(b, lb, int(pb), n)
            c['rects'] = [[v - (x0 if i % 2 == 0 else y0) for i, v in enumerate(r)] for r in (ra, rb)]
            if la in ('arriba', 'abajo'):
                ini, fin = (a['y'] + a['h'], b['y']) if la == 'abajo' else (b['y'] + b['h'], a['y'])
                for k in range(ini, fin):
                    for d in range(n):
                        tuneles.append([a['x'] + int(pa) + d - x0, k - y0, cid])
            else:
                ini, fin = (a['x'] + a['w'], b['x']) if la == 'der' else (b['x'] + b['w'], a['x'])
                for k in range(ini, fin):
                    for d in range(n):
                        tuneles.append([k - x0, a['y'] + int(pa) + d - y0, cid])
        conexiones.append(c)

    mundo = mundo_unido()
    for z in colocadas:
        z['x'] -= x0
        z['y'] -= y0
    w = max(z['x'] + z['w'] for z in colocadas)
    h = max(z['y'] + z['h'] for z in colocadas)
    return {'w': w, 'h': h, 'origen': [x0, y0], 'mundo': mundo, 'zonas': zonas,
            'conexiones': conexiones, 'tuneles': tuneles}


def main() -> None:
    linea = PREFIJO + json.dumps(datos(), ensure_ascii=False) + ';'
    if len(sys.argv) < 2:
        print(linea)
        return
    ruta = sys.argv[1]
    with open(ruta, encoding='utf-8') as f:
        lineas = f.read().split('\n')
    i = [k for k, l in enumerate(lineas) if l.startswith(PREFIJO)]
    if len(i) != 1:
        sys.exit(f'{ruta}: no hay exactamente una línea que empiece por "{PREFIJO}"')
    cambia = lineas[i[0]] != linea
    lineas[i[0]] = linea
    with open(ruta, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lineas))
    print(f'{ruta}: datos del atlas {"actualizados" if cambia else "sin cambios"} (línea {i[0] + 1})')


if __name__ == '__main__':
    main()
