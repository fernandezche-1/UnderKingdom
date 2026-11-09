# P65 - Llama eterna, hielo de `[P6]` y luz de la antorcha

- Primera pieza del paso 6 (Ruina) de la Fase 2 de `TASK.md`. Sirve a la capilla de la ruina (la llama), a las criptas oscuras (la luz) y al hielo de `[P6]`.
- Decisiones de `docs/FASE2_DECISIONES.md` que aplica: R1, R2, S7, S8, G3, G4 y G5; las nuevas están al final de ese archivo.
- Piezas nuevas: `escenas/items/llama_eterna.tscn` (`scripts/items/eternal_flame_pickup.gd`, `UnderkingdomEternalFlamePickup`, hereda de `ability_pickup.gd`) y `scripts/environment/dark_zone.gd` (`UnderkingdomDarkZone`, `Node2D`). El hielo no necesita script nuevo: es la `locked_door.gd` de P57.
- Sin guardado nuevo: la llama es la llave genérica `antorcha` (`collected_keys`) y el hielo derretido es un objeto consumido. `SAVE_FORMAT_VERSION` sigue en 5.

## 1. La llama eterna

- Se recoge al tocarla (igual que las reliquias) y da `grant_key(key_id)`, con `key_id` `antorcha`. Sale "LLAMA ETERNA" (`pickup_message`). No se equipa ni se gasta: sigue valiendo para siempre.
- Una vez recogida no reaparece. Exporta `key_id`, `pickup_message` y `flame_tint`, además de lo de la reliquia (`bob_height`, `pickup_radius`…).
- La pestaña de llaves del menú de pausa la lista siempre como "Llama eterna" (`KEY_NAMES`).

## 2. El hielo de `[P6]`

Una `locked_door.gd` con `key_id` `antorcha`, `require_interact` (E delante, "E  Derretir"), `open_effect` `MELT` y `piece_tint` azul claro. Sin la llama, E dice "NECESITAS LA LLAMA ETERNA". Con ella, el bloque se derrite hacia su base con gotas y queda abierto para toda la partida. El hielo negro de las profundidades usa lo mismo con `profundidades_ascua`.

## 3. La luz: `dark_zone.gd`

| Exportación | Por defecto | Para qué |
|---|---|---|
| `width_tiles`, `height_tiles` | 10, 6 | tamaño en piezas; origen arriba a la izquierda |
| `key_id` | `antorcha` | llave que da la luz; vacía = siempre con luz |
| `light_radius_tiles` | 5 | radio de luz con la llave |
| `dark_radius` | 20 px | halo sin la llave |
| `dark_color` | azul casi negro, alfa 0.94 | color de la oscuridad |
| `edge_width`, `light_steps` | 24 px, 4 | borde difuso en escalones, para el pixel art |
| `flicker_px` | 2 | parpadeo del radio |

Es un `ColorRect` con shader (`z_index` 50, bajo el HUD) que sigue al Player y deja un círculo claro. Oscurece también a los enemigos y objetos de dentro. No usa `CanvasModulate`, así que puede haber varias zonas en una escena. En la Fase 3 se cubren con ella las criptas (x 32-62, filas 50-64 de la ruina).

## 4. Zona de pruebas

En `zona_pruebas_combate.tscn`, `Objetos`, sobre la galería alta (suelo en y 176): `LlamaEterna` (1216, 160), `ZonaOscura` (1248, 80, 8 x 6 piezas) y `HieloAntorcha` (1392, 152, 1 x 3).
- **Cierra:** sin la llama, la zona queda casi negra (halo de 20 px) y E ante el hielo dice "NECESITAS LA LLAMA ETERNA".
- **Abre:** al recoger la llama la luz pasa a 5 piezas y E derrite el hielo.

## 5. Pruebas

- Escena temporal sin ventana (borrada): sin llama, radio 20, hielo cerrado y E no lo abre; el Player de pie sobre la galería recoge la llama (llave `antorcha`, radio 80, uniform a 81 por el parpadeo, luz sobre el Player); E con llama abre el hielo (escala Y 0.44 a medio efecto, colisión desactivada, objeto consumido) y la llave queda en `collected_keys`.
- Arrancan sin errores el juego y la zona de pruebas, también con ventana (se compila el shader). No se tocó Player, enemigos, `GameManager` ni el Capitán, así que no se probó `mundo_1`.

## 6. Pendiente

- Arte: la llama usa el sprite del fuego rojo teñido de azul; el hielo, la reja teñida (P57). Falta el altar.
- Ver el resultado de la luz jugando y ajustar radio, borde y color.
- Montar llama, criptas y hielo en la ruina (Fase 3).
