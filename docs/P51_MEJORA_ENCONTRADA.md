# P51 - Mejora encontrada: la empuñadura del alcaide (+0.25 de daño en los tajos)

- Cuarta pieza de la Fase 2 de `TASK.md` (paso del calabozo): una mejora que se recoge en el mapa y suma a una estadística del Player, sin precio y sin niveles.
- Sirve a la empuñadura del depósito del alcaide y, después, al amuleto de la guardia (+0.25 en pociones): los dos usan la misma tabla.
- Decisiones de `docs/FASE2_DECISIONES.md` que aplica: C7, C8, G3 y G4.
- Piezas:
  - `GameManager.FOUND_UPGRADE_DEFINITIONS` y `found_upgrades`, aparte de las mejoras de la tienda (`UPGRADE_DEFINITIONS`);
  - `escenas/items/mejora_encontrada.tscn`, con `scripts/items/found_upgrade_pickup.gd` (`UnderkingdomFoundUpgradePickup`), que hereda de `ability_pickup.gd`.

## 1. La tabla

- Cada entrada: `name`, `stat` (lo que mejora), `bonus` (lo que suma) y `hint` (texto del aviso y del menú).
- Hoy solo existe `empunadura_alcaide` (`stat` `slash_damage`, `bonus` 0.25). El amuleto añadirá su fila con `stat` `potion_heal`.
- API de `GameManager`:
  - `grant_found_upgrade(id)`: la marca, emite `found_upgrade_collected` y `upgrades_changed`, y pide autoguardado;
  - `has_found_upgrade(id)`;
  - `get_found_upgrade_bonus(stat)`: suma de los bonos de las mejoras encontradas para esa estadística.

## 2. Qué hace en el Player

- `_start_attack` suma `get_found_upgrade_bonus("slash_damage")` al daño de `attack`, `attack 2` (con Golpe final incluido) y `air attack`.
- No afecta a los puñetazos (`puch`) ni a la Ultimate (C7). Sin espada la mejora se queda guardada y se nota al tenerla.
- Los daños siguen siendo múltiplos de 0.25: tajo 0.5 → 0.75, golpe final 1.0 → 1.25, aéreo 0.75 → 1.0.
- `attack_started` emite ya el daño con la mejora.

## 3. El objeto

- `mejora_encontrada.tscn` es una reliquia: se recoge al tocarla, con el destello de siempre, y no vuelve a salir una vez recogida (la comprueba contra `found_upgrades`).
- `upgrade_id` (en la escena, `empunadura_alcaide`) se cambia por instancia. Con un id desconocido avisa con `push_warning` y desaparece.
- Para reutilizar la recogida de las reliquias, `ability_pickup.gd` pasa a tener dos métodos que las subclases cambian, `_already_owned()` y `_grant()`. La reliquia de habilidad se comporta igual.
- Al recoger, el HUD muestra "MEJORA: EMPUÑADURA DEL ALCAIDE" con su `hint`.
- **Pendiente:** arte propio de la empuñadura. Provisional: el orbe de la reliquia, teñido de ámbar.

## 4. Menú de pausa

- En la pestaña de mejoras, debajo de las de la tienda, aparece una fila por cada mejora encontrada, con su nombre, su texto y "Encontrada". Las que no se tienen no se muestran.

## 5. Guardado

- `found_upgrades` (id → verdadero) se guarda en `_make_save_data` como `found_upgrades`, se lee en `_restore_game_state` y se vacía en `reset_for_new_game`.
- `SAVE_FORMAT_VERSION` sube a 3. Las partidas guardadas con la 2 ya no cargan (G1).

## 6. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Objetos`: `MejoraEncontrada` en `(328, 304)`, tramo de inicio, al lado del objeto de lore.
- Con espada (Modo dev, "Dar espada"), un tajo hace 0.5 antes de recogerla y 0.75 después. Cada reinicio con F6 empieza sin ella.
- **Cierra:** antes de tocarla el bonus es 0 y no cuenta como encontrada; recogida una vez, el objeto no vuelve a aparecer.
- **Abre:** al caminar sobre ella se recoge y sube el daño.

## 7. Pruebas

- Escena temporal sin ventana (borrada al terminar) que carga la zona de pruebas, da la espada y:
  - sin la mejora, el tajo emite 0.5; lejos del objeto no se recoge;
  - caminando hasta el objeto se recoge, el objeto se libera y el bonus es 0.25;
  - los tajos `attack` y `attack 2` emiten 0.75; el puñetazo, sin espada, sigue en 0.25;
  - el guardado trae `format_version` 3 y `found_upgrades`; al restaurarlo la mejora vuelve y `reset_for_new_game` la quita.
- Arrancan sin errores el juego, la zona de pruebas y `mundo_1` (su aviso de "SpawnPoint con suelo seguro" ya salía antes de este cambio).
