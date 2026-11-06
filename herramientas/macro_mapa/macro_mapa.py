# Macro mapa ASCII de UnderKingdom (docs/P46_MACRO_MAPA.md). Para mover zonas o
# atajos, cambia las coordenadas y ejecuta: python3 herramientas/macro_mapa/macro_mapa.py
W, H = 74, 54
g = [[' '] * W for _ in range(H)]

def put(x, y, t):
    for i, c in enumerate(t): g[y][x + i] = c

def box(x0, y0, x1, y1, *lines):
    for x in range(x0, x1 + 1): g[y0][x] = g[y1][x] = '#'
    for y in range(y0, y1 + 1): g[y][x0] = g[y][x1] = '#'
    mid = (y0 + y1) // 2 - (len(lines) - 1) // 2
    for i, t in enumerate(lines):
        put((x0 + x1 + 1) // 2 - len(t) // 2, mid + i, t)

def vert(a, b, y0, y1, label=''):
    for y in range(y0 + 1, y1): g[y][a - 1] = g[y][b + 1] = '#'
    for y in range(y0, y1 + 1):
        for x in range(a, b + 1): g[y][x] = ' '
    if label: put(a + (b - a + 1 - len(label)) // 2, (y0 + y1) // 2, label)

def horiz(x0, x1, a, b, label=''):
    for x in range(x0 + 1, x1): g[a - 1][x] = g[b + 1][x] = '#'
    for x in range(x0, x1 + 1):
        for y in range(a, b + 1): g[y][x] = ' '
    if label: put((x0 + x1 + 1) // 2 - len(label) // 2, a, label)

box(0, 0, W - 1, H - 1)
box(3, 2, 14, 5, 'PRISIÓN')
box(3, 8, 18, 13, 'CALABOZO', '(carcelero)')
box(22, 2, 44, 11, 'CASTILLO', '(Rey Caído)')
# Cementerio: exterior arriba y cripta abajo, en una misma zona.
box(50, 2, 70, 18)
put(51, 9, '#' * 8 + '   ' + '#' * 8)  # suelo con la bajada a la cripta
put(55, 4, 'CEMENTERIO')
put(53, 5, '(3 tumbas sello)')
put(53, 7, 'casa sepulturero')
put(57, 12, 'CRIPTA')
put(56, 13, '(osarios)')
box(38, 22, 70, 27, 'MINAS', '(Caballero de la Reina)')
box(3, 22, 32, 27, 'MAZMORRA', '(la Reina)')
box(3, 31, 70, 35, 'RUINA HELADA', '(Guardián de hielo)')
box(8, 39, 66, 43, 'PROFUNDIDADES', '(Demon Slime + 3 altares)')
box(18, 47, 56, 51, 'INFIERNO', '(prueba final, Cthulhu)')

vert(8, 9, 5, 8)                    # prisión -> calabozo
horiz(18, 22, 9, 10, '[L1]')        # calabozo -> castillo: llave del carcelero
horiz(44, 50, 5, 6, '[H2]')         # castillo -> cementerio: rodar bajo la reja del trono
vert(58, 61, 18, 22, '[S3]')        # cripta -> minas: 3 tumbas sello
vert(40, 42, 11, 22, ':C:')         # atajo castillo <-> minas (ascensor minero)
horiz(32, 38, 24, 25, '[L4]')       # minas -> mazmorra: llave del Caballero
vert(10, 12, 13, 22, ':B:')         # atajo calabozo <-> mazmorra (desagüe)
vert(10, 13, 27, 31, '[!5]')        # mazmorra -> ruina: derrumbe y huida
vert(64, 66, 27, 31, ':D:')         # atajo minas <-> ruina
vert(50, 53, 35, 39, '[P6]')        # ruina -> profundidades: romper el hielo
vert(14, 16, 35, 39, ':E:')         # atajo ruina <-> profundidades
vert(30, 33, 43, 47, '[S7]')        # profundidades -> infierno: 3 altares + jefe
print('\n'.join(''.join(r) for r in g))
