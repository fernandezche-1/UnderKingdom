# P46 - Macro mapa: plan para rehacer las zonas

- **Es un plan, no el estado actual.** Dice cómo se van a conectar las zonas cuando se rehagan una a una como mapas reales. Lo que todavía no se ha rehecho sigue como lo describen `CLAUDE.md` ("Mapas en uso") y `TASK.md`.
- Al rehacer una zona, se sigue este plan: dónde está, por qué lado entra y sale, cómo se abre su salida y qué atajos tiene.
- Si al rehacerla se cambia algo del plan, se cambia aquí primero (el dibujo con el script de la sección 8) y se anota en la sección 6.

## 1. El mapa

Cuanto más abajo está una zona, más profunda es: el juego se recorre bajando.

```
##########################################################################
#                                                                        #
#  ############       #######################     #####################  #
#  #  PRISIÓN #       #                     #     #                   #  #
#  #          #       #                     #######    CEMENTERIO     #  #
#  #####  #####       #                      [H2]    (3 tumbas sello) #  #
#      #  #           #      CASTILLO                                 #  #
#      #  #           #     (Rey Caído)     #######  casa sepulturero #  #
#  #####  #############                     #     #                   #  #
#  #              [L1]                      #     #########   #########  #
#  #   CALABOZO                             #     #                   #  #
#  #  (carcelero) ######################   ##     #                   #  #
#  #              #                    #   #      #      CRIPTA       #  #
#  #######   ######                    #   #      #     (osarios)     #  #
#        #   #                         #   #      #                   #  #
#        #   #                         #   #      #                   #  #
#        #   #                         #:C:#      #                   #  #
#        #:B:#                         #   #      #                   #  #
#        #   #                         #   #      ########    #########  #
#        #   #                         #   #             #    #          #
#        #   #                         #   #             #[S3]#          #
#        #   #                         #   #             #    #          #
#  #######   ####################     ##   ###############    #########  #
#  #                            #######                               #  #
#  #          MAZMORRA           [L4]               MINAS             #  #
#  #         (la Reina)                    (Caballero de la Reina)    #  #
#  #                            #######                               #  #
#  #######    ###################     ##########################   ####  #
#        #    #                                                #   #     #
#        #[!5]#                                                #:D:#     #
#        #    #                                                #   #     #
#  #######    ##################################################   ####  #
#  #                                                                  #  #
#  #                           RUINA HELADA                           #  #
#  #                        (Guardián de hielo)                       #  #
#  ###########   #################################    #################  #
#            #   #                               #    #                  #
#            #:E:#                               #[P6]#                  #
#            #   #                               #    #                  #
#       ######   #################################    #############      #
#       #                                                         #      #
#       #                      PROFUNDIDADES                      #      #
#       #                (Demon Slime + 3 altares)                #      #
#       ######################    #################################      #
#                            #    #                                      #
#                            #[S7]#                                      #
#                            #    #                                      #
#                 ############    #######################                #
#                 #                                     #                #
#                 #              INFIERNO               #                #
#                 #          (Cthulhu, final)           #                #
#                 #######################################                #
#                                                                        #
##########################################################################
```

| Marca | Significado |
|---|---|
| hueco en la pared | paso libre |
| `[L]` | llave del jefe |
| `[H]` | habilidad como llave |
| `[S]` | sellos o piezas repartidos por la zona |
| `[P]` | puzle del entorno |
| `[!]` | derrumbe o huida |
| `:B:` … `:E:` | atajo que se abre desde el lado de abajo |

El número de cada marca es el orden de la transición en la ruta.

## 2. Variedad al avanzar

- "Vencer al jefe, que caiga la llave y abrir la puerta" se mantiene, pero solo en algunas transiciones (`[L1]` y `[L4]`). Repetida en todas sería monótona.
- Las demás salidas se abren de otras formas, cada una ligada al tema de su zona y a su jefe.
- Las salas de jefe siguen cerrándose al entrar (`boss_arena.gd`); lo que cambia es qué abre la salida de la zona.

## 3. Zonas y ruta

| # | Zona | Escena de hoy | Cómo se sale (plan) | Por qué |
|---|---|---|---|---|
| 1 | Prisión | `prologo_prision/camara_sellado_alma.tscn` | paso libre hacia abajo | Inicio, sin jefe. |
| 2 | Calabozo | `tiles_calabozo_combate.tscn` | `[L1]` llave del carcelero, hacia el castillo | El carcelero tiene las llaves. **Ya está así.** |
| 3 | Castillo | `tiles_castillo_combate.tscn` | `[H2]` reja baja bajo el trono: solo se pasa rodando | La reliquia de rodar se consigue en el castillo. |
| 4 | Cementerio | `tiles_cementerio_combate.tscn` | `[S3]` tres tumbas sello abren el fondo de la cripta, que baja a las minas | Usa la exploración de la zona. |
| 5 | Minas | `tiles_mineria_combate.tscn` | `[L4]` llave del Caballero de la Reina, hacia la mazmorra | El Caballero guarda la mazmorra de su señora. |
| 6 | Mazmorra | `tiles_mazmorra_combate.tscn` | `[!5]` al morir la Reina la mazmorra se derrumba: huida hacia abajo | Cierre de capítulo con otro ritmo. |
| 7 | Ruina helada | `tiles_ruina_combate.tscn` | `[P6]` hielo que se rompe con fuego o con un ataque hacia abajo; se debilita al vencer al Guardián de hielo | Usa el tema de la zona. |
| 8 | Profundidades | `tiles_profundidades_combate.tscn` | `[S7]` tres altares demoníacos con un minijefe cada uno, más el Demon Slime | Sube la tensión antes del final. |
| 9 | Infierno | `tiles_jefe_combate.tscn` | sin salida: Cthulhu, jefe final | |

Detalles de la colocación:

- **El castillo y el cementerio están en la superficie, uno al lado del otro.** `[H2]` es un paso lateral.
- **El cementerio es una sola zona con dos pisos:**
  - arriba, el exterior al pie del castillo, con las tumbas sello y la casa del sepulturero;
  - abajo, la cripta y los osarios.

  Se baja de uno a otro dentro del mapa. La salida `[S3]` está en el fondo de la cripta.
- **Las minas y la mazmorra están a la misma profundidad.** `[L4]` es el único tramo lateral bajo tierra.
- **Casa:** pasa a ser la casa del sepulturero, dentro del cementerio, y puede tener tienda o un NPC. `tiles_casa` sigue fuera de la ruta; no hace falta usarlo para esto.

## 4. Atajos

Están cerrados y se abren desde el lado de abajo, cuando el jugador ya llegó por la ruta. Así ninguna zona se alcanza antes de tiempo.

| Atajo | Une | Se abre desde | Idea |
|---|---|---|---|
| `:B:` | Calabozo ↔ Mazmorra | la mazmorra | desagüe entre las dos prisiones |
| `:C:` | Castillo ↔ Minas | las minas | ascensor minero |
| `:D:` | Minas ↔ Ruina helada | la ruina | pozo minero |
| `:E:` | Ruina ↔ Profundidades | las profundidades | vuelta rápida para la tienda o para farmear |

## 5. Cómo rehacer una zona con este plan

- Se sigue montando como dice `CLAUDE.md` ("Cómo se monta un mundo"): PNG, constructor y escena `_combate` que hereda de la base.
- La entrada y la salida van en el lado que marca el mapa (arriba, abajo o lateral), y la salida en la parte más honda cuando baja.
- Los atajos entre zonas son transiciones entre escenas. Su lado cerrado puede ser un `arena_barrier.gd` que se abre desde abajo y se recuerda en `completed_encounters` de `GameManager`.
- Los enemigos siguen la tabla de `docs/P33_ENEMIGOS_POR_PROFUNDIDAD.md`.
- Al terminar una zona, marcarla en `TASK.md` ("Macro mapa") y anotar aquí lo que cambie.

### Piezas que ya existen
- Llaves: `grant_key` / `has_key` en `GameManager`, y `locked_door.gd`.
- Habilidades como premio: `ability_reward` de `boss_arena.gd` y `escenas/items/reliquia_habilidad.tscn`.
- Puertas que se abren con un evento: `arena_barrier.gd`.
- Estado guardado: `completed_encounters`.

### Piezas que faltan
- Suelo o muro frágil que se rompe con un ataque (`[P6]`, y con el derrumbe de `[!5]`).
- Un contador de sellos que abre una puerta al activarlos todos (`[S3]`, `[S7]`).
- La secuencia de huida o derrumbe tras la Reina (`[!5]`).
- La reja baja que solo se pasa rodando (`[H2]`).
- El ascensor minero (`:C:`).

## 6. Diferencias con lo que hay hoy (decisiones pendientes)

- **Castillo:** hoy sale por la puerta con la llave del Rey Caído (`castillo_rey`), en las criptas de abajo. En el plan sale por `[H2]` hacia un lado. Falta decidir qué pasa con la llave `castillo_rey` (quitarla o darle otro uso).
- **Cementerio:**
  - Hoy ya es de bajada: superficie, cripta, catacumbas, sala del jefe y abismo. Eso encaja con el plan.
  - Pero tiene jefe: el Capitán, que da la Ráfaga y una llave para la salida. Falta decidir el papel del Capitán con `[S3]`: que guarde uno de los sellos, que sea el reto final antes de la cripta, o mantener la llave y cambiar la forma de otra transición.
- **Minas:** hoy salen por una puerta con llave en el fondo. En el plan, `[L4]` es lateral, hacia la mazmorra.
- **Mazmorra, ruina, profundidades e infierno:** siguen siendo calcos con la salida por la derecha. Se rehacen con este plan.
- **Atajos:** no existe ninguno todavía.

## 7. Pendiente

- Resolver las decisiones de la sección 6.
- Rehacer las zonas una a una (lista en `TASK.md`, "Macro mapa").

## 8. Regenerar el dibujo

El dibujo se genera con `herramientas/macro_mapa/macro_mapa.py`, para que no se descuadre:
- `box()` dibuja una zona;
- `vert()` y `horiz()` dibujan un pasillo con su marca.

Se cambian las coordenadas y se ejecuta:

```
python3 herramientas/macro_mapa/macro_mapa.py
```

La salida se pega en la sección 1. Todas las líneas deben medir 74 columnas.
