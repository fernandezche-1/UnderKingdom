# P58 - Amuleto de la guardia: las pociones curan 0.25 más

- Cuarta y última pieza del paso del cementerio en la Fase 2 de `TASK.md`: el amuleto que se encuentra en la cueva de la estatua de la Reina.
- Decisiones de `docs/historial/FASE2_DECISIONES.md` que aplica: S9, C8, G3 y G4.
- No hay escena nueva: es una segunda fila de `FOUND_UPGRADE_DEFINITIONS` (P51) y un punto de lectura en el Player. `mejora_encontrada.tscn` se reutiliza con `upgrade_id` `amuleto_guardia`.

## 1. La tabla

- `amuleto_guardia`: `name` "Amuleto de la guardia", `stat` `potion_heal`, `bonus` 0.25, `hint` "Tus pociones curan 0.25 más".
- Al recogerlo el HUD muestra "MEJORA: AMULETO DE LA GUARDIA" con su `hint`, y la pestaña de mejoras del menú de pausa lo lista como "Encontrada" (ambos ya leen la tabla entera, sin cambios).

## 2. Qué hace en el Player

- `get_potion_heal_amount()` devuelve `potion_heal_amount` (1.0) más `GameManager.get_found_upgrade_bonus("potion_heal")`. `drink_potion()` cura con ese valor: 1.0 sin amuleto, 1.25 con él (múltiplo de 0.25).
- La curación no se pasa de la vida máxima, y la poción sigue sin gastarse con la vida llena.
- No cambia nada más: ni las pociones del inventario, ni el robo de vida, ni la curación de la Reina.

## 3. Guardado

- Sin cambios: `found_upgrades` ya se guarda, restaura y reinicia (P51). `SAVE_FORMAT_VERSION` se queda en 4.

## 4. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Objetos`: `MejoraAmuleto` en `(360, 304)`, junto a la empuñadura.
- **Cierra:** antes de recogerlo, una poción cura 1.0 y el bono es 0.
- **Abre:** al caminar sobre él se recoge, el objeto desaparece y la poción cura 1.25.
- **Pendiente:** arte propio del amuleto. Provisional: el orbe ámbar de la mejora encontrada (G4).

## 5. Pruebas

- Escena temporal sin ventana (borrada): con la zona de pruebas cargada, vida 1.0 y una poción: vida 2.0 sin amuleto; se coloca al Player sobre el amuleto, se recoge (se libera el objeto, `has_found_upgrade` verdadero, bono 0.25) y la siguiente poción deja la vida en 2.25. El guardado trae `amuleto_guardia: true` y `reset_for_new_game` lo quita.
- Arrancan sin errores el juego, la zona de pruebas y `mundo_1`.
