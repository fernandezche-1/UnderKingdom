"""Sintetiza el banco original de UnderKingdom con la biblioteca estándar.

Ejecutar desde cualquier carpeta con Python 3.10 o posterior.
La semilla depende del nombre de cada archivo. Todo WAV es mono PCM de 16 bits.
"""
from array import array
from math import exp, pi, sin
from pathlib import Path
from random import Random
from sys import byteorder
from wave import open as open_wave
from zlib import crc32

RATE = 22050
AUDIO = Path(__file__).resolve().parents[1]
TAU = 2 * pi

# Duración, frecuencias inicial/final, ruido, cola, resonancia, filtro.
EFFECTS = {
    "paso": (.13, 157, 68, .70, 4.0, .24, .23),
    "carrera": (.12, 193, 65, .62, 4.8, .31, .28),
    "salto": (.20, 168, 390, .38, 3.2, .29, .28),
    "aterrizaje": (.23, 119, 40, .67, 4.1, .34, .26),
    "rodar": (.47, 245, 60, .89, 2.6, .11, .13),
    "escalera": (.19, 248, 81, .54, 3.8, .52, .32),
    "punetazo": (.15, 211, 63, .62, 4.6, .14, .35),
    "tajo": (.21, 634, 113, .79, 4.2, .31, .57),
    "tajo_ascendente": (.27, 230, 904, .69, 3.6, .37, .61),
    "tajo_aereo": (.25, 892, 331, .64, 3.1, .42, .48),
    "golpe_final": (.35, 927, 79, .62, 3.8, .47, .54),
    "defensa": (.25, 501, 315, .44, 3.5, .57, .42),
    "bloqueo": (.36, 692, 239, .51, 4.2, .78, .58),
    "guardia_rota": (.45, 485, 63, .72, 4.5, .74, .59),
    "parry": (.34, 760, 1143, .25, 3.3, .66, .54),
    "dano": (.27, 241, 75, .51, 4.3, .37, .41),
    "muerte": (.76, 243, 43, .38, 2.6, .48, .24),
    "reaparicion": (.40, 196, 592, .16, 2.8, .49, .24),
    "habilidad": (.59, 339, 771, .12, 2.2, .47, .32),
    "adrenalina": (.39, 89, 435, .42, 3.0, .28, .22),
    "dash": (.33, 489, 155, .78, 3.4, .38, .52),
    "resistencia": (.37, 668, 299, .28, 3.2, .77, .49),
    "pocion": (.40, 316, 497, .22, 3.1, .53, .35),
    "robo_vida": (.30, 292, 584, .14, 3.0, .47, .32),
    "fuego_carga": (.34, 94, 468, .72, 2.4, .50, .32),
    "fuego_lanza": (.34, 386, 91, .80, 3.8, .28, .37),
    "fuego_impacto": (.34, 176, 55, .88, 4.1, .27, .52),
    "flecha_lanza": (.17, 1300, 320, .53, 4.6, .27, .62),
    "flecha_impacto": (.19, 1170, 86, .68, 5.0, .38, .40),
    "ultimate_inicio": (.73, 67, 395, .50, 1.9, .59, .29),
    "ultimate_golpe": (.25, 478, 108, .83, 3.5, .46, .45),
    "ultimate_explosion": (.43, 261, 35, .78, 3.3, .46, .42),
    "ultimate_fin": (.39, 255, 66, .77, 3.7, .25, .22),
    "jefe_fase_1": (.65, 91, 254, .27, 2.2, .58, .24),
    "jefe_fase_2": (.70, 102, 420, .35, 2.3, .65, .29),
    "jefe_fase_3": (.84, 108, 613, .48, 2.1, .72, .31),
    "jefe_ultimate": (.95, 186, 48, .65, 2.5, .79, .28),
    "jefe_lluvia": (.44, 885, 228, .64, 3.1, .37, .58),
    "jefe_curacion": (.58, 246, 719, .28, 2.0, .66, .36),
    "jefe_victoria": (.81, 274, 568, .16, 2.2, .60, .44),
    "oleada": (.47, 141, 318, .25, 2.7, .57, .32),
    "moneda": (.15, 1320, 1710, .12, 4.2, .58, .52),
    "recogible": (.29, 496, 789, .13, 3.4, .58, .41),
    "punto_control": (.55, 254, 493, .16, 2.8, .55, .31),
    "palanca": (.27, 348, 142, .66, 3.1, .61, .41),
    "puerta": (.34, 190, 63, .78, 3.4, .24, .28),
    "cofre": (.32, 393, 139, .58, 3.0, .40, .32),
    "derrumbe": (.76, 143, 35, .86, 2.1, .24, .37),
    "ritual": (.82, 374, 733, .38, 2.0, .63, .33),
    "cadenas": (.58, 818, 309, .65, 3.4, .76, .56),
}

UI = {
    "seleccion": (.055, 648, 544),
    "confirmar": (.112, 670, 998),
    "cancelar": (.124, 603, 338),
    "pausa": (.17, 399, 742),
    "reanudar": (.15, 570, 375),
    "ajuste": (.055, 804, 838),
}

# Una familia comparte material, cada criatura tiene afinación propia en Godot.
ENEMIES = {
    "armadura": (545, .63, .74, .51),
    "hueso": (718, .79, .33, .57),
    "bestia": (177, .55, .37, .32),
    "ala": (841, .62, .20, .56),
    "espiritu": (471, .35, .88, .32),
    "viscoso": (182, .47, .56, .19),
    "demonio": (288, .64, .69, .41),
}

VOICES = {
    "grave": (.063, 219, .16, .53),
    "clara": (.048, 480, .10, .37),
    "metalica": (.055, 351, .19, .75),
    "aire": (.075, 309, .23, .26),
}

# Tónica, tempo, modo, energía. Las melodías y acompañamientos son originales.
MUSIC = {
    "menu": (45, 88, 0, .28),
    "introduccion": (43, 76, 0, .19),
    "prision": (38, 74, 0, .23),
    "calabozo": (43, 92, 0, .41),
    "castillo": (47, 98, 1, .48),
    "cementerio": (42, 83, 0, .26),
    "minas": (40, 100, 1, .45),
    "mazmorra": (44, 84, 0, .30),
    "ruina": (50, 85, 1, .31),
    "profundidades": (39, 91, 0, .48),
    "infierno": (36, 120, 0, .69),
    "pruebas": (48, 104, 1, .35),
    "arena": (43, 131, 0, .71),
    "jefe": (38, 142, 0, .86),
    "jefe_abismo": (34, 151, 0, .97),
}

# Soplido, agua, fuego, hielo, fondo acústico.
AMBIENCE = {
    "prision": (.14, .25, .11, .00, .65),
    "calabozo": (.14, .35, .31, .00, .73),
    "castillo": (.36, .07, .24, .00, .36),
    "cementerio": (.73, .12, .04, .00, .33),
    "minas": (.35, .37, .04, .17, .36),
    "mazmorra": (.21, .88, .06, .00, .49),
    "ruina": (.85, .12, .03, .55, .17),
    "profundidades": (.20, .16, .66, .07, .57),
    "infierno": (.29, .00, .94, .00, .63),
    "pruebas": (.20, .08, .00, .02, .21),
}


def save(folder, name, seconds, sample, peak, fade=.008):
    file = AUDIO / folder / (name + ".wav")
    file.parent.mkdir(parents=True, exist_ok=True)
    noise = Random(crc32(name.encode("ascii")))
    count = round(seconds * RATE)
    pcm = array("h")
    for index in range(count):
        t = index / RATE
        edge = min(t / fade, (count - index - 1) / RATE / fade, 1.0)
        pcm.append(round(max(-1.0, min(1.0, sample(t, noise) * peak * edge)) * 32767))
    if byteorder == "big":
        pcm.byteswap()
    with open_wave(str(file), "wb") as wav:
        wav.setparams((1, 2, RATE, 0, "NONE", "not compressed"))
        wav.writeframes(pcm.tobytes())


def effect(spec):
    duration, start, end, grit, decay, resonant, cutoff = spec
    filtered = 0.0

    def sample(t, rng):
        nonlocal filtered
        progress = t / duration
        filtered += cutoff * (rng.uniform(-1, 1) - filtered)
        phase = TAU * (start * t + (end - start) * t * progress / 2)
        body = sin(phase + .32 * sin(phase * .47))
        overtone = sin(phase * 1.83) + .45 * sin(phase * 2.91)
        transient = .28 * exp(-progress * 23) * rng.uniform(-1, 1)
        wave = (1 - grit) * (body * .68 + overtone * .29 * resonant) + filtered * grit
        return (wave + transient) * exp(-progress * decay)

    return sample


def midi(note):
    return 440 * 2 ** ((note - 69) / 12)


def music_sample(root, tempo, bright, energy):
    beat = 60 / tempo
    chords = (0, 3, 8, 5) if bright else (0, 8, 3, 7)
    arpeggio = (0, 7, 12, 15, 12, 7, 19, 15)
    pitches = {n: midi(root + n) for n in range(-12, 36)}

    def sample(t, rng):
        bar = int(t / (4 * beat))
        chord = chords[bar % len(chords)]
        bar_t = t % (4 * beat)
        subdivision = int(bar_t / (.5 * beat))
        note = chord + arpeggio[subdivision]
        note_t = bar_t % (.5 * beat)
        phase = TAU * pitches[note] * note_t
        attack = min(note_t * 78, 1.0)
        lead = (sin(phase) + .22 * sin(2 * phase)) * attack * exp(-note_t * (8 - energy))
        bass_t = t % beat
        bass = sin(TAU * pitches[chord - 12] * bass_t) * min(bass_t * 36, 1.0) * exp(-bass_t * 4)
        pad_gate = min(bar_t * 4, (4 * beat - bar_t) * 4, 1.0)
        pad = (sin(TAU * pitches[chord] * t) + sin(TAU * pitches[chord + 7] * t) * .61) * pad_gate
        kick = .17 * energy * sin(TAU * (94 * bass_t - 53 * bass_t ** 2)) * exp(-bass_t * 25)
        hat = energy * .14 * rng.uniform(-1, 1) * exp(-note_t * 50)
        return .32 * lead + .28 * bass + .125 * pad + kick + hat

    return 16 * beat, sample


def ambience_sample(wind, water, fire, ice, room, duration):
    slow, fast, crackle = 0.0, 0.0, 0.0

    def sample(t, rng):
        nonlocal slow, fast, crackle
        noise = rng.uniform(-1, 1)
        slow += .016 * (noise - slow)
        fast += .35 * (noise - fast)
        crackle = max(crackle * .972, max(0.0, rng.random() - .9990) * 552)
        gust = .70 + .23 * sin(TAU * 2 * t / duration) + .07 * sin(TAU * 5 * t / duration)
        drip_t = (t + .38) % 1.67
        drip = sin(TAU * (1220 * drip_t - 120 * drip_t ** 2)) * exp(-drip_t * 31) * min(220 * drip_t, 1)
        frost_t = (t + .88) % 2.3
        frost = sin(TAU * 1870 * frost_t) * exp(-frost_t * 22) * min(230 * frost_t, 1)
        rumble = .11 * sin(TAU * 39 * t) + .07 * sin(TAU * 57 * t)
        return (
            wind * gust * slow * 3.9 + water * (fast * .32 + drip * .24)
            + fire * (fast * .39 + noise * crackle) + ice * frost * .26
            + room * rumble
        )

    return sample


def main():
    for name, spec in EFFECTS.items():
        save("efectos", name, spec[0], effect(spec), .62, fade=.004)
    for name, (length, start, end) in UI.items():
        spec = (length, start, end, .10, 2.7, .42, .45)
        save("interfaz", name, length, effect(spec), .48, fade=.003)
    for family, (pitch, grit, metal, cutoff) in ENEMIES.items():
        for action, (length, interval, fall, decay) in {
            "ataque": (.24, 1.16, .49, 3.5),
            "dano": (.22, .85, .53, 4.3),
            "muerte": (.52, 1.00, .23, 2.8),
        }.items():
            spec = (length, pitch * interval, pitch * fall, grit, decay, metal, cutoff)
            save("efectos/enemigos", family + "_" + action, length, effect(spec), .59, fade=.004)
    for name, (length, pitch, grit, metal) in VOICES.items():
        spec = (length, pitch, pitch * 1.17, grit, 1.45, metal, .49)
        save("dialogos", name, length, effect(spec), .44, fade=.004)
    for name, config in MUSIC.items():
        length, sample = music_sample(*config)
        save("musica", name, length, sample, .70, fade=.08)
    length = 7.0
    for name, config in AMBIENCE.items():
        save("ambiente", name, length, ambience_sample(*config, length), .53, fade=.10)
    save("efectos", "ultimate_bucle", 1.8,
         ambience_sample(.23, .00, .88, .00, .54, 1.8), .49, fade=.045)


if __name__ == "__main__":
    main()
