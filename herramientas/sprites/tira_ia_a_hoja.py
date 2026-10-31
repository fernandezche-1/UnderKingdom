#!/usr/bin/env python3
"""Convierte una tira de la IA sobre fondo magenta en una hoja de 288x128 por cuadro.

Uso: tira_ia_a_hoja.py original.png salida.png --cuadros 8

Quita el fondo y su halo, reduce 3:1 (el mismo tamaño de la caja de colisión),
alinea los cuadros por los pies y comparte paleta para que el color no parpadee.
El pie queda en la fila que usan las hojas 288x128 del Player.
"""
import argparse

import numpy as np
from PIL import Image

MAGENTA = np.array([253.0, 0.0, 248.0])
ANCHO_CUADRO = 288
ALTO_CUADRO = 128
FILA_PIES = 126
FRANJA_PIES = 18  # Filas de la tira, desde abajo, con las que se alinea.


def quitar_fondo(rgb: np.ndarray) -> np.ndarray:
    """Devuelve RGBA en 0..1: alfa por cantidad de magenta y color sin el halo."""
    cantidad = np.clip((np.minimum(rgb[..., 0], rgb[..., 2]) - rgb[..., 1] - 40.0) / 150.0, 0.0, 1.0)
    alfa = 1.0 - cantidad
    color = (rgb - cantidad[..., None] * MAGENTA) / np.maximum(alfa, 0.05)[..., None]
    return np.dstack((np.clip(color, 0.0, 255.0) / 255.0, alfa))


def desplazamiento_pies(cuadro: np.ndarray, referencia: np.ndarray) -> tuple[int, int]:
    """Busca el desplazamiento entero que mejor encaja los pies con los de referencia."""
    alto = cuadro.shape[0]
    mejor = (0, 0)
    mejor_error = float("inf")
    for dy in range(-6, 7):
        for dx in range(-20, 21):
            movido = np.roll(np.roll(cuadro, dy, axis=0), dx, axis=1)
            error = np.abs(movido[alto - FRANJA_PIES:] - referencia[alto - FRANJA_PIES:]).sum()
            if error < mejor_error:
                mejor_error = error
                mejor = (dx, dy)
    return mejor


def reducir(cuadro: np.ndarray, factor: int) -> np.ndarray:
    """Promedia con alfa premultiplicado para que el borde no arrastre el fondo."""
    alto = cuadro.shape[0] - cuadro.shape[0] % factor
    ancho = cuadro.shape[1] - cuadro.shape[1] % factor
    bloques = cuadro[:alto, :ancho].reshape(alto // factor, factor, ancho // factor, factor, 4)
    alfa = bloques[..., 3:].mean(axis=(1, 3))
    color = (bloques[..., :3] * bloques[..., 3:]).mean(axis=(1, 3)) / np.maximum(alfa, 0.01)
    return np.dstack((color, (alfa >= 0.5).astype(float)))


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
        dx, dy = desplazamiento_pies(cuadro[..., 3], referencia)
        print(f"alineado dx={dx} dy={dy}")
        alineados.append(np.roll(np.roll(cuadro, dy, axis=0), dx, axis=1))

    # La fila del pie debe caer en el borde de un bloque de la reducción.
    fila_pies = int(np.where(alineados[0][..., 3].max(axis=(1)) > 0.5)[0].max())
    resto = (fila_pies + 1) % opciones.factor
    if resto:
        alineados = [np.roll(c, opciones.factor - resto, axis=0) for c in alineados]
    reducidos = [reducir(c, opciones.factor) for c in alineados]

    # Eje: centro de los pies del primer cuadro, común a todos.
    pies = np.where(reducidos[0][-(FRANJA_PIES // opciones.factor + 8):, :, 3].max(axis=0) > 0)[0]
    eje_x = (int(pies.min()) + int(pies.max())) // 2
    fila_base = int(np.where(reducidos[0][..., 3].max(axis=1) > 0)[0].max())

    hoja = Image.new("RGBA", (ANCHO_CUADRO * opciones.cuadros, ALTO_CUADRO), (0, 0, 0, 0))
    for i, cuadro in enumerate(reducidos):
        imagen = Image.fromarray((cuadro * 255.0).round().astype(np.uint8), "RGBA")
        hoja.alpha_composite(imagen, (i * ANCHO_CUADRO + opciones.centro_x - eje_x, FILA_PIES - fila_base))

    # Paleta común: mismo color en todos los cuadros y alfa binario.
    alfa = hoja.getchannel("A")
    paleta = hoja.convert("RGB").quantize(opciones.colores, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE)
    resultado = paleta.convert("RGBA")
    resultado.putalpha(alfa)
    resultado.save(opciones.salida)


if __name__ == "__main__":
    main()
