# P57 - `locked_door` con otro dibujo y apertura con E

- Tercera pieza del paso del cementerio en la Fase 2 de `TASK.md`: las velas de la cripta, el hielo de `[P6]` (ruina) y el hielo negro (profundidades/ruina).
- Decisiones de `docs/FASE2_DECISIONES.md` que aplica: S7, S8, G3, G4 y G5.
- No hay escena nueva: se amplía `scripts/environment/locked_door.gd` (`UnderkingdomLockedDoor`). Con los valores por defecto las puertas de siempre no cambian.

## 1. Exportaciones nuevas

- `require_interact` (false): con true la puerta no se abre al acercarse; hace falta E delante (grupo `interactable`, `can_interact` / `interact`, como `npc.gd`). Sin la llave, E saca `locked_message`. Aviso flotante `prompt_text` ("E  Abrir"; el hielo usa "E  Derretir") y `interact_margin` (24 px).
- `open_effect`: `FADE` (por defecto, el de siempre), `CANDLES` (las piezas se encienden, más claras y cálidas, con chispas naranjas que suben) o `MELT` (el bloque se encoge hacia su base con gotas azules). Dura `effect_time` (0.9 s); la colisión se quita al instante. También vale si se abre por `open_on_encounter`.
- `piece_tint`: color que multiplica a cada pieza (hielo, hielo negro, velas) sobre las `piece_*` de siempre.
- Los textos siguen siendo `locked_message` y `opened_message` por instancia: "LA LLAMA NO BASTA" (hielo negro), "NECESITAS LA LLAVE..." etc.

## 2. Guardado

Sin cambios: la puerta abierta se guarda como objeto consumido (`mark_object_consumed`), como antes. `SAVE_FORMAT_VERSION` no cambia.

## 3. Zona de pruebas

En `zona_pruebas_combate.tscn`, `Objetos`, suelo bajo las plataformas de una vía (x 760 a 936):
- `LlaveVelas` (760, 296) y `LlaveLlama` (800, 296): llaves genéricas `pruebas_velas` y `pruebas_llama`.
- `PuertaVelas` (872, 296) y `HieloLlama` (936, 296): 1 x 3 piezas, `require_interact`, efectos `CANDLES` y `MELT`.
- **Cierra:** sin llave, acercarse no hace nada y E dice "FALTA LA LLAMA DE LAS VELAS" / "LA LLAMA NO BASTA".
- **Abre:** con la llave, E enciende las velas o derrite el hielo y deja pasar.

## 4. Pruebas

- Escena temporal sin ventana (borrada), sobre la zona de pruebas: ambas empiezan cerradas; acercarse sin E no abre; E sin llave no abre; E con llave abre (colisión desactivada, piezas ocultas tras el efecto); el hielo se encoge a mitad del efecto (escala Y 0.79) y la puerta queda consumida.
- Arrancan sin errores el juego, la zona de pruebas y `tiles_ruina_combate` (usa `locked_door`) y `mundo_1` (su aviso de "SpawnPoint con suelo seguro" ya salía; no se tocó Player, enemigos, GameManager ni Capitán).

## 5. Pendiente

- Arte propio: velas y hielo (hoy, la reja del castillo teñida) y partículas con arte. Provisional: cuadrados de 2 px.
- La llama eterna (objeto que da `antorcha`) y la luz de la antorcha son de la pieza de la ruina; montar las puertas en cada zona, de la Fase 3.
