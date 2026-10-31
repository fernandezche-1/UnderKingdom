#!/usr/bin/env python3
"""Convierte una tira de la IA sobre fondo magenta en una hoja de 288x128 por cuadro.

Uso: tira_ia_a_hoja.py original.png salida.png --cuadros 8 --factor 6

Quita el fondo y su halo, alinea los cuadros por los pies y reduce con una paleta
común para que el color no parpadee. --factor es la altura de la figura en la tira
entre 40, el tamaño de la caja de colisión. Al reducir, cada píxel toma un color
de la paleta en vez de un promedio: así el contorno no se emborrona.
El pie queda en la fila que usan las hojas 288x128 del Player.
"""
import argparse

import numpy as np
from PIL import Image

MAGENTA = np.array([253.0, 0.0, 248.0])
ANCHO_CUADRO = 288
ALTO_CUADRO = 128
FILA_PIES = 126
FILAS_PIES = 6  # Filas de la hoja final, desde abajo, con las que se alinea.
PROPORCION_OSCURA = 0.3  # Parte de un bloque que debe ser oscura para contar como contorno.
LUMA_OSCURA = 0.55  # Suma de canales, en 0..3, por debajo de la que un color es oscuro.
TONO_PARECIDO = 0.75  # Distancia, suma de canales en 0..3, que se considera ruido entre cuadros.


def quitar_fondo(rgb: np.ndarray) -> np.ndarray:
    """Devuelve RGBA en 0..1: alfa por cantidad de magenta y color sin el halo."""
    cantidad = np.clip((np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1] - 40.0) / 150.0, 0.0, 1.0)
    alfa = 1.0 - cantidad
    color = (rgb - cantidad[..., None] * MAGENTA) / np.maximum(alfa, 0.05)[..., None]
    return np.dstack((np.clip(color, 0.0, 255.0) / 255.0, alfa))


def desplazamiento_pies(cuadro: np.ndarray, referencia: np.ndarray, franja: int) -> tuple[int, int]:
    """Busca el desplazamiento entero que mejor encaja los pies con los de referencia."""
    alto = cuadro.shape[0]
    mejor = (0, 0)
    mejor_error = float("inf")
    for dy in range(-6, 7):
        for dx in range(-20, 21):
            movido = np.roll(np.roll(cuadro, dy, axis=0), dx, axis=1)
            error = np.abs(movido[alto - franja:] - referencia[alto - franja:]).sum()
            if error < mejor_error:
                mejor_error = error
                mejor = (dx, dy)
    return mejor


def crear_paleta(cuadros: list[np.ndarray], colores: int) -> tuple[Image.Image, np.ndarray]:
    """Paleta común a todos los cuadros, con sus colores en 0..1."""
    tira = np.hstack(cuadros)
    opacos = tira[tira[..., 3] > 0.5, :3]  # Solo la figura: el fondo gastaría colores.
    imagen = Image.fromarray((opacos[:, None] * 255.0).round().astype(np.uint8), "RGB")
    paleta = imagen.quantize(colores, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    return paleta, np.array(paleta.getpalette()[:colores * 3]).reshape(-1, 3) / 255.0


def reducir(cuadro: np.ndarray, paleta: Image.Image, tabla: np.ndarray, factor: int) -> np.ndarray:
    """Da a cada bloque el color más frecuente, salvo que tenga bastante contorno."""
    imagen = Image.fromarray((cuadro[..., :3] * 255.0).round().astype(np.uint8), "RGB")
    indices = np.array(imagen.quantize(palette=paleta, dither=Image.Dither.NONE))
    oscuros = tabla.sum(axis=1) < LUMA_OSCURA
    alto = cuadro.shape[0] // factor
    ancho = cuadro.shape[1] // factor
    resultado = np.zeros((alto, ancho, 4))
    for fila in range(alto):
        for columna in range(ancho):
            bloque = (fila * factor, (fila + 1) * factor, columna * factor, (columna + 1) * factor)
            opaco = cuadro[bloque[0]:bloque[1], bloque[2]:bloque[3], 3] > 0.5
            if opaco.mean() < 0.5:
                continue
            cuenta = np.bincount(indices[bloque[0]:bloque[1], bloque[2]:bloque[3]][opaco], minlength=len(tabla))
            if cuenta[oscuros].sum() >= opaco.sum() * PROPORCION_OSCURA:
                cuenta = cuenta * oscuros
            resultado[fila, columna, :3] = tabla[int(cuenta.argmax())]
            resultado[fila, columna, 3] = 1.0
    return resultado


def estabilizar(cuadros: list[np.ndarray]) -> list[np.ndarray]:
    """Quita el ruido de color entre cuadros: lo parecido al color habitual del píxel lo toma."""
    pila = np.stack(cuadros)
    opacos = pila[..., 3] > 0.0
    resultado = pila.copy()
    for fila, columna in zip(*np.nonzero(opacos.sum(axis=0) > len(cuadros) // 2)):
        colores = pila[:, fila, columna]
        visibles = colores[opacos[:, fila, columna], :3]
        unicos, cuenta = np.unique(visibles, axis=0, return_counts=True)
        habitual = unicos[int(cuenta.argmax())]
        parecidos = np.abs(colores[:, :3] - habitual).sum(axis=1) < TONO_PARECIDO
        resultado[parecidos & opacos[:, fila, columna], fila, columna, :3] = habitual
    return list(resultado)


def main() -> None:
    argumentos = argparse.ArgumentParser(description=__doc__)
    argumentos.add_argument("entrada")
    argumentos.add_argument("salida")
    argumentos.add_argument("--cuadros", type=int, required=True)
    argumentos.add_argument("--factor", type=int, default=3)
    argumentos.add_argument("--colores", type=int, default=32)
    argumentos.add_argument("--centro-x", type=int, default=144, help="Columna del cuadro para el centro de los pies")
    opciones = argumentos.parse_args()

    tira = quitar_fondo(np.array(Image.open(opciones.entrada).convert("RGB")).astype(float))
    ancho_tira = tira.shape[1] // opciones.cuadros
    cuadros = [tira[:, i * ancho_tira:(i + 1) * ancho_tira] for i in range(opciones.cuadros)]
    # Margen para que alinear no recorte cabeza ni pies.
    cuadros = [np.pad(c, ((12, 12), (24, 24), (0, 0))) for c in cuadros]
    referencia = cuadros[0][..., 3]
    alineados = []
    for cuadro in cuadros:
        dx, dy = desplazamiento_pies(cuadro[..., 3], referencia, FILAS_PIES * opciones.factor)
        print(f"alineado dx={dx} dy={dy}")
        alineados.append(np.roll(np.roll(cuadro, dy, axis=0), dx, axis=1))

    # La fila del pie debe caer en el borde de un bloque de la reducción.
    fila_pies = int(np.where(alineados[0][..., 3].max(axis=(1)) > 0.5)[0].max())
    resto = (fila_pies + 1) % opciones.factor
    if resto:
        alineados = [np.roll(c, opciones.factor - resto, axis=0) for c in alineados]
    paleta, tabla = crear_paleta(alineados, opciones.colores)
    reducidos = estabilizar([reducir(c, paleta, tabla, opciones.factor) for c in alineados])

    # Eje: centro de los pies del primer cuadro, común a todos.
    pies = np.where(reducidos[0][-(FILAS_PIES + 8):, :, 3].max(axis=0) > 0)[0]
    eje_x = (int(pies.min()) + int(pies.max())) // 2
    fila_base = int(np.where(reducidos[0][..., 3].max(axis=1) > 0)[0].max())

    hoja = Image.new("RGBA", (ANCHO_CUADRO * opciones.cuadros, ALTO_CUADRO), (0, 0, 0, 0))
    for i, cuadro in enumerate(reducidos):
        imagen = Image.fromarray((cuadro * 255.0).round().astype(np.uint8), "RGBA")
        hoja.alpha_composite(imagen, (i * ANCHO_CUADRO + opciones.centro_x - eje_x, FILA_PIES - fila_base))

    hoja.save(opciones.salida)


if __name__ == "__main__":
    main()
