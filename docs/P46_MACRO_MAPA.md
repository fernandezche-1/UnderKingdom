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

- **Primero el ASCII:** Claude dibuja el ASCII de cada zona por separado, y con ese ASCII se genera el nivel real. No se genera ningún nivel antes de tener su ASCII. Método completo en la sección 9.
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

## 9. ASCII de cada zona y conexiones

El macro mapa (sección 1) solo dice qué zona va al lado de cuál; no está a escala. Cada zona se dibuja después por separado, a escala real, y un script comprueba que encajen.

### Archivos
| Qué | Dónde |
|---|---|
| ASCII de una zona mientras se dibuja | `mapas_texto/macro/zonas/<zona>.txt` |
| Zonas: escena, fuente del ASCII y posición en el mundo | `mapas_texto/macro/zonas.txt` |
| Conexiones: la fuente de verdad | `mapas_texto/macro/conexiones.txt` |
| Verificar y unir | `herramientas/macro_mapa/verificar_mundo.py` |

### El ASCII de una zona
- **Un carácter = una pieza de 16 px**, con las letras del constructor (`mapas_texto/LEYENDA.md`, sección 5): `#` bloque, `.` vacío, `=` plataforma, `H` escalera, `>`/`<` salidas…
- Tiene el formato de un mapa de letras del constructor: cabecera de opciones, línea `---` y el mapa, como `mapas_texto/tiles_calabozo.txt`. Así el ASCII ya es la fuente del nivel, sin traducirlo.
- Primero solo la estructura: salas, pasillos y aperturas. Enemigos, objetos y checkpoints se añaden después, sobre el mismo archivo.
- **Al generar el nivel**, el archivo pasa a `mapas_texto/tiles_<zona>.txt` y se cambia su ruta en `zonas.txt`. Así hay una sola fuente en todo momento.

### Conexiones
- Cada conexión de la sección 3 y cada atajo de la sección 4 es una línea de `conexiones.txt` con:
  - el lado de salida y el de entrada (`arriba`, `abajo`, `izq`, `der`), que deben ser opuestos;
  - la posición de la apertura en cada zona: columna o fila, desde 0, sobre ese borde;
  - el ancho, igual en las dos zonas;
  - quién la pone (`coloca`).
- Lo que no se sabe todavía va con `?`.
- **`coloca`:**
  - `constructor`: salida `>` en la zona de arriba de la ruta y `<` en la siguiente, en la columna del borde. Solo en los bordes `izq` y `der`, y como mucho una de cada por zona: el constructor solo tiene un destino "siguiente" y uno "anterior".
  - `combate`: transición puesta en la escena `_combate`, con un spawn `Desde<Zona>` a cada lado. Es lo que se usa para las conexiones de arriba y abajo y para los atajos.
- **Posición en el mundo** (`zonas.txt`): la esquina de arriba a la izquierda de cada zona en una cuadrícula global, en piezas. Se fija al dibujar la zona, guiándose por el macro mapa.

### Orden de trabajo
1. Las zonas se hacen bajando por la ruta: calabozo (ya hecho), castillo, cementerio, minas…
2. Antes de dibujar una zona se leen `conexiones.txt` y `zonas.txt`. Las aperturas hacia zonas ya hechas tienen posición fija y se copian. Las de las zonas que faltan se proponen y se apuntan en la tabla antes de dibujarlas.
3. Se dibuja el ASCII, se le da posición en `zonas.txt` y se corre el verificador.
4. Si hay que mover una apertura de una zona ya hecha, se cambia primero en la tabla. El verificador dice qué otra zona hay que ajustar.

### El verificador
```
python3 herramientas/macro_mapa/verificar_mundo.py
python3 herramientas/macro_mapa/verificar_mundo.py --unir /ruta/mundo.txt
```
- **Errores** (sale con código 1):
  - la apertura no está, o no tiene ese ancho, en alguna de las dos zonas;
  - falta el `>`/`<` de una conexión `constructor`;
  - los lados no son opuestos;
  - dos zonas se solapan en el mundo;
  - las aperturas no quedan en la misma fila o columna del mundo;
  - la zona de destino no está del lado que toca;
  - el túnel entre dos zonas atraviesa otra.
- **Avisos:**
  - zonas sin dibujar;
  - posiciones con `?`;
  - aperturas del borde que no están en la tabla;
  - zonas que no se tocan (túnel entre ellas).
- **`--unir`** pega las zonas dibujadas y colocadas en un solo mapa a escala real. Los túneles salen como `|` y `-`.

Una zona no se da por hecha mientras el verificador dé errores.

### Estado
- **Calabozo:** es la única zona dibujada. Su salida `[L1]` ya está fija: borde derecho, fila 10, 3 piezas. El castillo tiene que recibirla igual en su borde izquierdo.
- Las demás posiciones van con `?`, y no hay ninguna zona colocada en el mundo todavía.
