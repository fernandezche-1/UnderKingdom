# P35 - Desbloqueo de habilidades

- Antes el Player tenía todo desde el inicio. Ahora las habilidades se ganan jugando, por tres vías:
  - **reliquias** escondidas en el mapa;
  - **jefes y minijefes**, que sueltan una reliquia al caer;
  - **la tienda del Barquero** (pendiente, ver abajo).
- **Regla de reparto:** nada que haga falta para avanzar se compra. Las monedas solo salen de cofres y rompibles, y una habilidad necesaria en la tienda podría dejar al jugador atascado. Por eso la tienda queda para refinamientos y pasivas.
- **Solo bloquea en una partida.** El bloqueo se activa con "Nueva partida" (`GameManager.reset_for_new_game`). Si un mapa se abre directo desde el editor (F6), o se juega el Mundo 1 viejo, el Player tiene todo, como antes.

## 1. Datos en `GameManager`

- `ABILITY_DEFINITIONS`: por cada id, su `name` y su `hint` (tecla o forma de usarla). Los ids son `roll`, `combo_2`, `combo_3`, `air_attack`, `parry`, `ultimate`, `lifesteal` y `adrenaline`.
- `STARTING_ABILITIES`: las que se tienen al empezar. Por ahora están aquí las que todavía no tienen dónde conseguirse: `air_attack`, `parry`, `lifesteal` y `adrenaline`. Cuando se coloque su fuente, se quitan de esta lista.
- `abilities_locked` y `unlocked_abilities`. Se reinician en `reset_abilities_for_new_game()`, que llama `reset_for_new_game()`.
- Funciones:
  - `has_ability(id)`: si el Player puede usarla ahora; siempre `true` fuera de una partida;
  - `is_ability_unlocked(id)`: si ya se consiguió; las reliquias lo usan para no reaparecer;
  - `unlock_ability(id)`, con la señal `ability_unlocked(id)`;
  - `get_ability_name(id)` y `get_ability_hint(id)`.

## 2. Qué bloquea cada una en `player.gd`

| Id | Efecto sin la habilidad |
|---|---|
| `roll` | `request_roll()` no hace nada. |
| `combo_2`, `combo_3` | `_max_combo_step()` sustituye el `3` fijo del buffer del combo: sin `combo_2`, solo sale el primer tajo; con `combo_2`, hasta la ráfaga; con las dos, el combo completo. |
| `air_attack` | Atacar en el aire no hace nada. |
| `parry` | La guardia bloquea, pero nunca hace parry. |
| `ultimate` | `request_ultimate()` no hace nada; el HUD oculta la barra y la pestaña de estadísticas dice "Sin conseguir". |
| `lifesteal` | `is_lifesteal_active()` (nueva) combina el `@export lifesteal_enabled` con la habilidad. |
| `adrenaline` | `is_adrenaline_active()` exige además la habilidad. |

## 3. Reliquia

- Escena `escenas/items/reliquia_habilidad.tscn` (orbe azul de `items_.png`, 16x16, escala 1). Script `scripts/items/ability_pickup.gd` (`UnderkingdomAbilityPickup`).
- `@export ability_id`. Al tocarla, `GameManager.unlock_ability` y el destello de recoger. Si la habilidad ya se tenía, la reliquia no aparece.
- Al conseguir una habilidad, el HUD (`player_hud.gd`) muestra arriba al centro "NUEVA HABILIDAD: <NOMBRE>" y su `hint` durante 3 s.

## 4. Jefes

- `boss_arena.gd` tiene dos `@export` nuevos:
  - `ability_reward`: id de la habilidad que da;
  - `ability_offset`: separación respecto a `PuntoLlave`, por defecto 24 px a la izquierda, para que la reliquia no tape la llave.
- Al vencer al jefe la reliquia cae junto a la llave. Si se muere o se sale del mapa sin recogerla, vuelve a estar ahí, igual que la llave. Señal nueva: `ability_dropped`.

## 5. Reparto actual

| Habilidad | Dónde |
|---|---|
| Moverse, saltar, escalar, poción, primer tajo, guardia | Desde el inicio |
| Rodar | Reliquia en el nicho de la biblioteca del castillo, junto al cofre: (1208, 756) en px, columna 75, fila 47, en `tiles_castillo_combate.tscn`. Es camino obligatorio antes del Rey Caído. Antes estaba en el mismo punto del cementerio (ver `P40_CASTILLO_CON_TILES.md`). |
| Ráfaga (`combo_2`) | Capitán (`tiles_cementerio_combate.tscn`) |
| Golpe final (`combo_3`) | Caballero de la Reina (`tiles_mineria_combate.tscn`) |
| Ultimate | La Reina (`tiles_mazmorra_combate.tscn`) |
| Tajo aéreo, parry, robo de vida, adrenalina | Desde el inicio, de forma provisional |

## 6. Pendiente

- **Tienda:**
  - parry y robo de vida como compras de un solo nivel al Barquero;
  - la mejora de enfriamiento de la Ultimate visible solo si se tiene la Ultimate;
  - generar las filas de la pestaña Mejoras desde `UPGRADE_DEFINITIONS`; hoy están fijas en `menu_pausa.tscn`.
- **Minijefe de las minas** para el tajo aéreo: un enemigo de esa profundidad (tabla P33), con más vida, en una cámara con `boss_arena.gd` sin llave.
- **Reliquia secreta de la adrenalina** en la mazmorra o la ruina. La posición la decide una persona.
- **Pestaña "Habilidades"** en el menú de pausa, con huecos "???" para las que faltan.
- **Decidir** si la tienda se limita al Barquero: hoy también se compra desde el menú de pausa.
- **Guardado:** no hay guardado en disco. `unlocked_abilities` debe entrar cuando se haga.

## 7. DevMode

- Opción nueva "Desbloquear habilidades" (tecla 9 con el panel abierto).

## Comprobado sin ventana

- Una escena temporal, ya borrada, con el Player sobre un suelo de prueba:
  - sin partida, se puede rodar, el combo llega a 3 y sale la Ultimate;
  - tras `reset_for_new_game()`, no rueda, el combo se queda en 1 y no hay Ultimate;
  - con `combo_2` el combo llega a 2, con `combo_3` a 3, y con `ultimate` sale la Ultimate;
  - la reliquia de rodar se recoge al tocarla, el aviso muestra "NUEVA HABILIDAD: RODAR", y una segunda reliquia de rodar se borra sola.
- Cementerio cargado tras una partida nueva con la sala del Capitán ya superada: están la reliquia de rodar y la de `combo_2`.
- Arranque, cementerio, minas, mazmorra y `mundo_1` sin errores.
