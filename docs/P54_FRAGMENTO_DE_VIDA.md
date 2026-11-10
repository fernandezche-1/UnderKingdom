# P54 - Fragmento de vida: cuatro dan un corazón

- Tercera pieza del paso del castillo en la Fase 2 de `TASK.md`: los cuatro fragmentos de vida de las puertas hacia atrás (aposentos de la Reina, cripta de la primera reina, hielo negro y jaula del rey encadenado) que suben el sexto corazón.
- Decisiones de `docs/historial/FASE2_DECISIONES.md` que aplica: K4, K5, K6, G1, G3 y G4.
- Piezas:
  - `GameManager`: `life_fragments`, `LIFE_FRAGMENTS_PER_HEART` (4), `MAX_HEARTS_CAP` (6.0) y la API de abajo;
  - `escenas/items/fragmento_vida.tscn`, con `scripts/items/life_fragment_pickup.gd` (`UnderkingdomLifeFragmentPickup`), que hereda de `ability_pickup.gd` como la mejora encontrada (P51).

## 1. API de `GameManager`

- `grant_life_fragment(id) -> bool`: marca el fragmento, emite `life_fragment_collected(id, count, completed)` y `upgrades_changed`, y pide autoguardado. Devuelve `false` si ese id ya estaba recogido.
- `get_life_fragment_count()`: de 0 a 4 (los ids de más no cuentan).
- `has_life_fragment(id)`.
- `get_max_health_value()`: vida máxima de la tienda (4 o 5) más 1 con los 4 fragmentos, con tope 6. `apply_upgrades_to_player` y el guardado la usan en vez de leer solo la tienda.
- Con el cuarto fragmento la vida máxima sube 1 y la vida se llena (K4).
- Con tienda comprada (5) más los 4 fragmentos, 6 corazones.

## 2. El objeto

- `fragment_id` (exportado, vacío por defecto) es único en toda la partida; la convención para las zonas es `<zona>_<n>`. Con el id vacío avisa con `push_warning` y desaparece. Un id repetido no cuenta dos veces (K6), pero su objeto sí desaparece al recogerse.
- Una vez recogido no vuelve a salir al recargar el mapa (se comprueba contra `life_fragments`).
- Aviso en el HUD: "FRAGMENTO DE VIDA n/4"; con el cuarto añade "+1 CORAZÓN DE VIDA MÁXIMA" (G3, en mayúsculas).
- **Pendiente:** arte propio. Provisional: el orbe de la reliquia (el de la empuñadura), teñido de rosa.

## 3. Menú de pausa

- Pestaña de estadísticas: fila "Fragmentos de vida" con "n/4" (K5). No va en el HUD.

## 4. Guardado

- `life_fragments` se guarda como lista de ids (`"life_fragments"` en `_make_save_data`), se lee en `_restore_game_state` (ignora entradas que no sean texto) y se vacía en `reset_for_new_game`.
- `SAVE_FORMAT_VERSION` sube a 4. Las partidas con la 3 ya no cargan (G1).
- La vida máxima sigue sin leerse del guardado (P47): sale de la tienda más los fragmentos.

## 5. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Objetos`: `FragmentoVida1` a `FragmentoVida4` en `(120, 304)`, `(152, 304)`, `(184, 304)` y `(216, 304)`, ids `prueba_1` a `prueba_4`, en el tramo de inicio.
- **Cierra:** con 1 a 3 fragmentos la vida máxima sigue en 4 y no se cura; un id ya recogido no vuelve a contar.
- **Abre:** el cuarto sube a 5 corazones y llena la vida.

## 6. Pruebas

- Escena temporal sin ventana (borrada al terminar) que carga la zona de pruebas, reinicia la partida y:
  - con el Player a 1 de vida, recoge los cuatro caminando: cuentas 1, 2, 3 y 4, avisos con `completed` solo en el último, vida máxima 4, 4, 4 y 5, y vida 1 hasta el cuarto, que la deja en 5;
  - un id repetido devuelve `false` y no suma;
  - con la mejora de la tienda más los 4 fragmentos, la vida máxima es 6; con 3 fragmentos, 4;
  - el guardado trae `format_version` 4 y `life_fragments`; `reset_for_new_game` los borra y al restaurar vuelven.
- Arrancan sin errores el juego, la zona de pruebas y `mundo_1` (su aviso de "SpawnPoint con suelo seguro" ya salía antes).

## 7. Pendiente

- El HUD sigue dibujando la barra de vida sobre la textura de 4 corazones: con 5 o 6 corazones las divisiones no coinciden (ya pasaba con la tienda desde P47). Se arregla aparte, con el arte del HUD.
- Colocar los cuatro fragmentos en las zonas es de la Fase 3.
