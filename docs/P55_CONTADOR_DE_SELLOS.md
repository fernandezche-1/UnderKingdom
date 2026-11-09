# P55 - Contador de sellos que abre una puerta

- Primera pieza del paso del cementerio en la Fase 2 de `TASK.md`: las tres tumbas sello de `[S3]` (cementerio) y los tres altares de `[S7]` (profundidades).
- Decisiones de `docs/FASE2_DECISIONES.md` que aplica: S1, S2, S3, G3, G4 y G5.
- Piezas:
  - `scripts/environment/seal.gd` (`UnderkingdomSeal`), que hereda de `lever.gd` (P49): mismo aviso, cuadro y tecla E;
  - `escenas/objetos/sello.tscn`, que hereda de `palanca.tscn`;
  - `open_on_seal_group` en `arena_barrier.gd` (sirve también a `locked_door.gd` y `roll_gate.gd`);
  - `GameManager`: `seal_key`, `seal_group_encounter` y `get_seal_count`.

## 1. El sello

- Exportaciones: `seal_group` (por ejemplo `cementerio_s3`), `seal_id` (único en su grupo), `seal_total` (3 por defecto), `listen_encounter` (vacío), `seal_message` ("SELLO %d/%d") y `all_open_message` ("ALGO SE HA ABIERTO"). Las de la palanca (radio, cuadros, sacudida) siguen valiendo.
- Dos formas de activarse (S1):
  - con E al llegar a él (la tumba de las plataformas); el aviso es "E  Activar";
  - solo, cuando `GameManager` marca `listen_encounter` (la fosa, el Capitán). Con `listen_encounter` la E no hace nada. Si ese encuentro ya estaba superado al cargar la escena, el sello nace encendido, sin aviso ni sacudida.
- Al activarse: cambia de cuadro, "SELLO n/3" y una sacudida ligera; con el último, "ALGO SE HA ABIERTO" y sacudida doble (S2).

## 2. El contador y la puerta

- Cada sello activado se guarda en `completed_encounters` como `sello:<grupo>:<id>`; `get_seal_count(grupo)` cuenta esas entradas. Al llegar a `seal_total`, el último sello marca `sellos:<grupo>`.
- Toda barrera con `open_on_seal_group = <grupo>` escucha ese encuentro (es lo mismo que `open_on_encounter = "sellos:<grupo>"`, que manda si se rellenan los dos). Se abre aunque esté fuera de pantalla o en otra escena, y empieza abierta si ya estaba completo (S3).
- No hace falta un nodo contador: los sellos de un grupo pueden estar en escenas distintas.

## 3. Guardado

- Usa `completed_encounters`, que ya se guardaba y se reiniciaba: `SAVE_FORMAT_VERSION` no cambia.

## 4. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Objetos`, sobre el techo de los corrales (se sube por la escalera de la columna 69, tras tirar de la palanca, o por las plataformas): `Sello1` a `Sello3` en `(1200, 144)`, `(1232, 144)` y `(1264, 144)`, grupo `pruebas_sellos`, y `PuertaSellos` en `(1328, 128)` con `open_on_seal_group`.
- `Sello3` escucha `pruebas_sello_3_escucha`: no se activa con E. Para probarlo a mano, Modo dev o la consola: `GameManager.mark_encounter_completed("pruebas_sello_3_escucha")`.
- **Cierra:** con 0, 1 o 2 sellos la reja sigue cerrada; un sello ya activado no cuenta dos veces; lejos del sello la E no hace nada.
- **Abre:** con el tercero (aquí, el que escucha) la reja se abre y no vuelve a cerrarse al recargar.

## 5. Pruebas

- Escena temporal sin ventana (borrada al terminar): cargó la zona de pruebas y comprobó
  - puerta cerrada con cuenta 0; lejos, `interact` devuelve `false`; el sello que escucha no admite E;
  - sello 1 y sello 2: cuentas 1 y 2 con la puerta cerrada, sello repetido ignorado;
  - al marcar el encuentro de escucha: sello 3 activado, cuenta 3, puerta abierta y colisión desactivada;
  - al recargar la escena: puerta abierta y sellos encendidos; el guardado trae los tres; `reset_for_new_game` deja la cuenta en 0;
  - con el encuentro de escucha ya marcado antes de cargar: el sello 3 nace encendido, cuenta 1 y puerta cerrada.
- Arrancan sin errores el juego y la zona de pruebas. `mundo_1` también (su aviso de "SpawnPoint con suelo seguro" ya salía antes); no se tocó Player, enemigos ni Capitán, solo `GameManager` y `arena_barrier.gd`.

## 6. Pendiente

- Arte propio del sello. Provisional: la palanca de P49 teñida de violeta (`self_modulate`).
- Montar los sellos en el cementerio y en las profundidades es de la Fase 3: la tumba 1 escucha la arena de la fosa, la 2 se activa con E y la 3 escucha al Capitán.
