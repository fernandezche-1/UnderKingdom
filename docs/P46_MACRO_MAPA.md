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
| 4 | Cementerio | `tiles_cementerio_combate.tscn` | `[S3]` tres tumbas sello abren el fondo de la cripta, que baja a las minas. Dos están en el exterior; la tercera es la tumba real de la cripta y la guarda el Capitán | Mezcla exploración y jefe; la salida se abre justo tras la pelea. |
| 5 | Minas | `tiles_mineria_combate.tscn` | `[L4]` llave del Caballero de la Reina, hacia la mazmorra | El Caballero guarda la mazmorra de su señora. |
| 6 | Mazmorra | `tiles_mazmorra_combate.tscn` | `[!5]` al morir la Reina la mazmorra se derrumba: huida hacia abajo | Cierre de capítulo con otro ritmo. |
| 7 | Ruina helada | `tiles_ruina_combate.tscn` | `[P6]` muro o suelo de hielo que se derrite con la llama eterna, una antorcha que se encuentra explorando la ruina | Fuego contra hielo; la antorcha también alumbra una parte oscura de la ruina. |
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
- Suelo que se hunde para el derrumbe de `[!5]`.
- Hielo que se derrite con la llama eterna (`[P6]`): puerta con llave genérica (`grant_key("antorcha")`, `locked_door.gd`) con otro dibujo y efecto de derretirse, más la luz de la antorcha en la parte oscura.
- Un contador de sellos que abre una puerta al activarlos todos (`[S3]`, `[S7]`).
- La secuencia de huida o derrumbe tras la Reina (`[!5]`).
- La reja baja que solo se pasa rodando (`[H2]`).
- El ascensor minero (`:C:`).

## 6. Diferencias con lo que hay hoy y decisiones

- **Castillo:** hoy sale por la puerta con la llave del Rey Caído (`castillo_rey`), en las criptas de abajo. En el plan sale por `[H2]` hacia un lado. **Decidido (2026-11-04):** la llave `castillo_rey` se descarta y la salida es solo rodando. Al rehacer el castillo se quitan la puerta con llave, la llave que suelta el Rey y su entrada en la pestaña de llaves y en `BOSS_KEY_IDS`. Como el Rey deja de dar llave, da Rodar (`ability_reward`), y la reliquia de la biblioteca se quita.
- **Cementerio:**
  - Hoy ya es de bajada: superficie, cripta, catacumbas, sala del jefe y abismo. Eso encaja con el plan.
  - Pero tiene jefe: el Capitán, que da la Ráfaga y una llave para la salida. **Decidido (2026-11-04):** el Capitán guarda la tercera tumba sello, la tumba real de la cripta. Su sala de jefe es la cámara de esa tumba, y al vencerlo se activa el último sello y se abre `[S3]`. Sigue dando la Ráfaga y deja de dar llave. Se mantienen el Capitán, su sala y la cinemática del reencuentro.
- **Ruina:** **decidido (2026-11-04):** `[P6]` se abre con la llama eterna, una antorcha que se encuentra explorando la ruina. Se usa delante del hielo (tecla E) y también alumbra una parte oscura de la ruina. Así ya no hace falta un ataque hacia abajo. Idea opcional para más adelante: que el hielo también se derrita si lo alcanza una bola de fuego de un Aprendis, como truco secreto.
- **Minas:** hoy salen por una puerta con llave en el fondo. En el plan, `[L4]` es lateral, hacia la mazmorra.
- **Mazmorra, ruina, profundidades e infierno:** siguen siendo calcos con la salida por la derecha. Se rehacen con este plan.
- **Atajos:** no existe ninguno todavía.

## 7. Pendiente

- Aplicar las decisiones de la sección 6 al rehacer cada zona.
- Rehacer las zonas una a una (lista en `TASK.md`, "Macro mapa").
- Ruina: qué da el Guardián de hielo al caer (el plan no lo dice), y confirmar que la reja tras su sala, que se abre al vencerlo, es el camino a `[P6]`.

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
2. Antes de dibujar una zona se leen `conexiones.txt`, `zonas.txt` y la sección 10 (con qué llega el jugador y qué se consigue en la zona). Las aperturas hacia zonas ya hechas tienen posición fija y se copian. Las de las zonas que faltan se proponen y se apuntan en la tabla antes de dibujarlas.
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
- **Calabozo:** su salida `[L1]` está fija: borde derecho, fila 10, 3 piezas. Colocado en el mundo en (0, 34).
- **Castillo (ASCII, primera pasada, 2026-11-04):** `mapas_texto/macro/zonas/castillo.txt`, 110 x 80, en el mundo en (136, 0).
  - Recibe `[L1]` en su borde izquierdo, filas 44-46. `[H2]` sale por el borde derecho, filas 67-69, 3 piezas, por el paso bajo el trono. `:C:` es un hueco de 3 piezas en el borde de abajo, columnas 34-36, desde el sótano.
  - Subzonas, coordenadas y sitio de cada pieza (Rey, reja, trampillas, E2, cofres) en los comentarios del archivo.
  - Rodar pasa a ser el premio del Rey Caído (`ability_reward`), en lugar de la reliquia de la biblioteca de hoy.
  - Segunda pasada hecha: 7 Guardias, 5 Vanguardias, 11 murciélagos, 4 cofres y decorados del tileset castillo. Probada generando una escena temporal con el constructor, sin errores.
  - La puerta del gran salón a la antecámara solo se abre desde la antecámara (cerrojo en la `_combate`): el camino obligatorio pasa por la biblioteca, las almenas y la armería.
- **Cementerio (ASCII, primera pasada, 2026-11-04):** `mapas_texto/macro/zonas/cementerio.txt`, 120 x 90, en el mundo en (246, 43): pegado al castillo por la derecha y más abajo que su cima, al pie de la colina, para que `[H2]` caiga en las filas 67-69 del mundo.
  - Recibe `[H2]` en su borde izquierdo, filas 24-26, por un túnel bajo la colina del castillo. `[S3]` sale por el borde de abajo, columnas 10-12 (columna 256 del mundo), 3 piezas, desde el pozo del sello, al oeste de la sala del Capitán.
  - Exterior con la fosa común (tumba sello 1, reto de combate), la casa del sepulturero (checkpoint, tienda o NPC y escalera a la cripta), el hueco al osario y el foso de pinchos con la colina del panteón (tumba sello 2, reto de plataformas).
  - Cripta en tres pisos: antecripta y osario, catacumba alta y baja (con bucle) y, al fondo, la antesala, la cámara de la tumba real (el Capitán, 31 x 11 como la sala de hoy, tumba sello 3) y el pozo del sello. E3 en el panteón del caballero, al fondo este, fuera del camino.
  - Atajo interno: escalera de la columna 22 de la catacumba alta a la entrada, con trampilla que se abre desde abajo.
  - Coordenadas de cada pieza en los comentarios del archivo. Comprobado con una simulación de saltos de 3 piezas: se llega a todo y desde todo se vuelve a la entrada.
  - Segunda pasada hecha: 4 Vanguardias, 16 esqueletos de tumba, 11 murciélagos, 4 cofres, 20 monedas, 3 pociones y decorados del tileset cementerio. La repisa alta del osario pasa a ser maciza para llevar el cofre. Probada generando una escena temporal con el constructor, sin errores.
- **Minas (ASCII, primera pasada, 2026-11-04):** `mapas_texto/macro/zonas/minas.txt`, 150 x 90, en el mundo en (150, 133): justo debajo del cementerio, y bajo el sótano del castillo, para cubrir las columnas de `:C:` (170 del mundo) y `[S3]` (256).
  - Recibe `[S3]` por el borde de arriba, columnas 106-108, en el pozo del sello, con escalera en la columna 107 para volver al cementerio. `:C:` entra por el borde de arriba, columnas 20-22: el pozo del ascensor baja a la estación, con la palanca en (12, 40). Entre el sótano del castillo y las minas el pozo recorre 53 piezas (el verificador lo avisa como túnel).
  - `[L4]` sale por el borde izquierdo, filas 66-68 (fila 199 del mundo), 3 piezas, por un túnel encima de la sala del Caballero con la puerta con llave en la columna 28. `:D:` es un hueco de 3 piezas en el borde de abajo, columnas 132-134 (columna 282 del mundo), al fondo este de la galería honda.
  - Bocamina (checkpoint), galería alta, galería de las vagonetas, veta ardiente con dos fosos de lava, galería honda, antecámara (checkpoint) y sala del Caballero (31 x 13, la de hoy) en la parte más honda, junto a `[L4]`. Tres bucles y un atajo interno: la escalera de la columna 48, de la antecámara a una trampilla de la galería de las vagonetas que se abre desde abajo. Hoy ese atajo sale de la sala del jefe; ahora sale de la antecámara, y la sala ya no tiene `Atajos`.
  - Secreto de la Agilidad en la pared este de la bocamina: un escalón de 5 piezas, como la poción de (29, 6) de las minas de hoy (P45).
  - Coordenadas de cada pieza en los comentarios del archivo. Comprobado con una simulación de saltos de 3 piezas: se llega a todo menos al secreto (tampoco con 4; sí con 6) y desde todo se vuelve a la bocamina. Probada generando una escena temporal con el constructor, sin errores.
  - Segunda pasada hecha: 6 kolbo, 6 kolbo2, 4 kolbo3, 10 murciélagos, 4 trampas de fuego en la veta, 4 cofres (uno en el secreto), 15 monedas, 3 pociones y decorados del tileset mazmorra (campamento en la bocamina, vagonetas de cajas y barriles). Con saltos de 3 se alcanza todo menos lo del secreto. Probada generando una escena temporal con el constructor, sin errores.
- **Mazmorra (ASCII, primera pasada, 2026-11-04):** `mapas_texto/macro/zonas/mazmorra.txt`, 120 x 90, en el mundo en (30, 133): a la izquierda de las minas, a su misma profundidad. Su borde derecho es la columna 149 y su borde de abajo, la fila 222, como el de las minas.
  - Recibe `[L4]` en su borde derecho, filas 66-68, sin túnel: `<` pegada a la `>` de las minas. `[!5]` sale por el borde de abajo, columnas 115-117 (145-147 del mundo), 3 piezas, al final de la huida. La ruina tendrá que cubrir de la columna 145 a la 284 del mundo (`[!5]` y `:D:`): unas 140 piezas de ancho, empezando en la fila 223.
  - Llegada (checkpoint), cuerpo de guardia, celdas bajas y altas, gran sala de guardia (43 x 35), torre del alcaide, sala de tortura, desagües y antesala (checkpoint). La sala de la Reina (23 x 17, la de hoy) está en la parte más honda, al suroeste, con su única entrada de 3 piezas por arriba.
  - Bucle por las celdas altas, la torre y la gran sala. Atajo interno: la compuerta de los desagües, que se abre desde la antesala.
  - Derrumbe: al morir la Reina se hunden 15 piezas del suelo de su sala (x 8-22, fila 75) y la trampilla de entrada queda tapada. La huida corre hacia el este bajo los desagües, con 4 fosos de pinchos de 3 de ancho y escalones de 3 como mucho, hasta `[!5]`.
  - Añadido al plan: la escalera del colector, que va de la huida al cuerpo de guardia y tiene una trampilla que solo se abre desde abajo. Antes de la Reina no deja bajar a la huida. Después, permite volver desde la ruina.
  - El suelo que se hunde está dibujado como bloque: la sala queda entera durante el combate, y la pieza nueva tiene que quitar esas celdas al hundirse.
  - Secreto de la Agilidad al fondo este de la torre: un escalón de 5 piezas, como el de las minas.
  - `:B:` no está dibujado. Sitio sugerido: borde de arriba de la mazmorra, columnas 67-69, que son las 97-99 del mundo y del calabozo. Bajaría por un pozo con escalera hasta la repisa alta de la gran sala. Se decide al rehacer el calabozo.
  - Coordenadas de cada pieza en los comentarios del archivo. Comprobado con una simulación de saltos de 3 piezas: se llega a todo menos al secreto (tampoco con 4; sí con 6), desde todo se vuelve a la llegada y la huida solo se alcanza tras el derrumbe. Probada generando una escena temporal con el constructor, sin errores.
  - Segunda pasada hecha: 5 Aprendis, 2 mino, 7 kolbo3 y 6 esqueletos, 4 cofres (uno en el secreto), 14 monedas, 3 pociones y decorados del tileset mazmorra (estanterías en la torre y la gran sala, la fogata de la guardia y agua y hongos en los desagües). El mino mide 5 piezas de alto y solo cabe en la gran sala y en la torre. Las plataformas del cuerpo de guardia bajan una fila (66 y 63): estaban a 4 piezas. Con saltos de 3 se alcanza todo menos lo del secreto. Probada generando una escena temporal con el constructor, sin errores; tras 3 s de física cada enemigo sigue en su sitio.
- **Ruina helada (ASCII, primera pasada, 2026-11-04):** `mapas_texto/macro/zonas/ruina.txt`, 156 x 80, en el mundo en (136, 223): justo debajo de la mazmorra y las minas, que acaban en la fila 222, de la columna 136 a la 291.
  - Recibe `[!5]` por el borde de arriba, columnas 9-11 (145-147 del mundo), y `:D:` también por arriba, columnas 146-148 (282-284). Las dos sin túnel, con su escalera en la misma columna que la de la mazmorra (116) y la de las minas (133).
  - `[!5]`: el Player cae unas 15 piezas (no hay daño por caída) a la llegada, suelo liso y sin enemigos. La única vuelta atrás es esa escalera, hacia la huida y el colector.
  - `:D:`: el pie del pozo tiene la palanca que abre la reja de las minas, en (140, 17).
  - `[P6]` sale por el borde de abajo, columnas 145-147 (281-283 del mundo), 3 piezas. `:E:` es un pozo de 3 piezas en el suelo de la antesala, columnas 90-92 (226-228), con trampilla cerrada desde la ruina. **Las profundidades tendrán que cubrir de la columna 226 a la 283 del mundo, empezando en la fila 303.**
  - Llegada (checkpoint), exterior helado, torre caída, pasillo y pie del pozo arriba; galería alta y baja en medio; capilla de la llama eterna, criptas oscuras, refugio del explorador, antesala (checkpoint), sala del Guardián (38 x 11, la de hoy), cámara del deshielo y pozo de `[P6]` abajo.
  - Bucles por las dos galerías (escaleras 5 y 118) y por el pie del pozo, la torre y la galería alta (escalera 151). Atajo interno: la escalera 5, de la galería baja a la llegada, con trampilla que se abre desde abajo.
  - La llama eterna está en la capilla, en (5, 62), fuera del camino directo al jefe. La parte oscura son las criptas (x 32-62, filas 50-64): solo se entra por la capilla, así que siempre se llega con la llama. Tras ellas, el refugio del explorador con el Abrigo (E4), en (69, 56), como secreto.
  - Zonas frías, opcionales: la cumbre del viento (x 66-103, filas 2-11) y el lago helado (x 50-70, filas 18-23). Secreto de la Agilidad al fondo este de la galería baja, un escalón de 5 piezas, como en las minas y la mazmorra.
  - **Añadido al plan:** el hielo de `[P6]` es un muro de 1 x 3 (columna 144, filas 70-72) tras la sala del Guardián, y a él se llega por una reja en la pared este de la sala (columna 134), que va en `Atajos` de `boss_arena.gd` y se abre al vencerlo. Así la salida pide el jefe y la llama eterna. Qué da el Guardián al caer queda pendiente (sección 7).
  - Coordenadas de cada pieza en los comentarios del archivo. Comprobado con una simulación de saltos de 4 piezas y huecos de 3: se llega a todo menos al secreto (sí con 6) y a la cámara del deshielo, que pide abrir la reja; desde todo se vuelve a la llegada. El camino obligatorio sale incluso con saltos de 3.
  - Segunda pasada hecha: 6 Aprendis, 2 mino, 7 kolbo3 y 8 esqueletos, 4 cofres (uno en el secreto), 18 monedas, 3 pociones y decorados del tileset mazmorra (cristales de hielo, antorchas salvo en el exterior y la parte oscura, estanterías en las galerías, cajas de los mineros en el pie del pozo, agua y hongos en el lago). El mino solo cabe en el exterior helado. Con saltos de 4 se alcanza todo menos lo del secreto. Probada generando una escena temporal con el constructor, sin errores; tras 3 s de física cada enemigo sigue en su sitio.
- Las demás zonas van con `?`.

## 10. Progreso del personaje: atuendos y desbloqueos por zona

El protagonista empieza desnudo y sin nada, y se hace más fuerte con lo que encuentra al bajar: atuendos con su arma, habilidades y llaves.

**Al trabajar en una zona** (su ASCII, su nivel, sus enemigos, su jefe o su dificultad), mirar esta sección:
- con qué llega el jugador: sus saltos, su arma y sus habilidades;
- qué se consigue en la zona, que hay que colocar en su ASCII;
- qué pide su salida.

Los retos obligatorios solo pueden pedir lo que el jugador ya tiene al llegar.

### Atuendos (conjuntos)
Cada atuendo cambia el aspecto del Player (su `SpriteFrames`) y su arma, y da algo jugable. No se cambia a mano: siempre se lleva el mejor que se tenga.

| # | Atuendo | Dónde | Qué da | Estado |
|---|---|---|---|---|
| E0 | Desnudo | prisión (inicio) | puñetazos; movimiento corto | hecho (`prisn.tscn`) |
| E1 | Harapos + espada oxidada | calabozo, cadáver del preso | espada y tajos | hecho (P42); faltan algunas tiras propias |
| E2 | Soldado del castillo (cota y espada de guardia) | castillo, en la armería | más daño o alcance del tajo | plan; opcional |
| E3 | Caballero de la cripta (armadura de un caballero enterrado) | cementerio, en una tumba real de la cripta | la **Agilidad** (P45) y más resistencia | plan; opcional |
| E4 | Abrigo de la ruina | ruina helada, en un secreto | el frío de la ruina no hace daño | plan; opcional |
| E5 | Fire Knight (espada grande) | profundidades | el más fuerte; resiste el fuego | arte existente; falta separarlo de E1 |

- **Más daño o alcance:** se ajusta con `sword_hitbox_offset_x` y `sword_hitbox_scale_x`, para que un arma más larga alcance más.
- **Resistencias:** en múltiplos de 0.25, o "no hace daño".
- **E3 da la Agilidad.** Resuelve el pendiente de P45 (dónde se consigue, antes de las minas).
- **E5 responde al pendiente de P42** sobre la espada buena con armadura.

### Desbloqueos por zona
"Hoy" es lo que ya está en las escenas `_combate`; "plan" es lo de esta propuesta.

| Zona | Llega con | Se consigue aquí | La salida pide |
|---|---|---|---|
| Prisión | E0; tajo aéreo, parry, robo de vida y adrenalina (`STARTING_ABILITIES`) | — | — |
| Calabozo | E0 (salto de unas 3 piezas) | E1 (hoy); llave del carcelero (hoy) | `[L1]` llave del carcelero |
| Castillo | E1 (salto de unas 4,6 piezas) | Rodar, por reliquia en la biblioteca (hoy); en el plan, premio del Rey Caído (`ability_reward`); E2 en la armería (plan) | `[H2]` Rodar |
| Cementerio | E1 o E2; Rodar | Ráfaga, con el Capitán, guardián de la tercera tumba; E3 y la Agilidad (plan) | `[S3]` tres tumbas sello (la última, vencer al Capitán) |
| Minas | Ráfaga; con E3, Agilidad (salto de unas 6,5 piezas) | Golpe final, con el Caballero (hoy); llave del Caballero | `[L4]` llave del Caballero |
| Mazmorra | Golpe final | Ultimate, con la Reina (hoy) | `[!5]` derrumbe tras la Reina |
| Ruina helada | Ultimate | la llama eterna (plan); E4 (plan) | `[P6]` la llama eterna |
| Profundidades | E4 si se encontró | E5 (plan) | `[S7]` tres altares y el Demon Slime; con E5 se llega al altar rodeado de fuego |
| Infierno | E5 | — | — |

- **Mejoras de la tienda** (vida máxima, robo de vida, enfriamiento de la Ultimate): se compran con monedas en cualquier momento. Nunca son necesarias para avanzar (P35).
- **Opcionales no obligatorios:** E2, E3 y E4 son premios por explorar. Ningún reto obligatorio puede pedirlos. Sí pueden pedirlos los secretos y los objetos opcionales: la Agilidad, los de las minas, la ruina y `tiles_jefe` (P45); el Abrigo, las zonas de frío.

### Arte de los atuendos (con IA)
Como los harapos (P42, "Sprites nuevos con espada"), el arte se genera con IA y se procesa con `herramientas/sprites/tira_ia_a_hoja.py`. Lo que importa es que todos se vean como el mismo personaje:
1. **Figura de referencia:** primero se genera y se aprueba una sola imagen del personaje con el atuendo, en pose `idle`. Todas sus tiras se piden a partir de ella.
2. **Poses de los harapos como guía:** cada animación se pide con la `original_ia.png` equivalente de los harapos de referencia. Así se repiten pose, número de cuadros y encuadre, y se procesa con las mismas opciones anotadas en P42.
3. **Mismas condiciones de tira:** fondo magenta, figura de perfil mirando a la derecha y de unos 120 px de alto, sin salirse mucho de su casilla.
4. **Mismas medidas de hoja:** 864x384 por cuadro, pie en la fila 380, centro en la columna 432 y escala 1/3. Así el cambio de atuendo no mueve la colisión ni la caja de la espada.
5. **Todas las animaciones de una vez:** `idle`, `run`, salto, `attack` / `attack 2`, `air attack`, `take hit`, `death`, `escaleras`, rodar y defensa, seguidas y con el mismo prompt base.
6. **Una carpeta por atuendo:** cada hoja con su `original_ia.png` al lado y un archivo con los prompts exactos usados, para poder regenerar.

### Implementación (pendiente)
- **`GameManager`:**
  - un atuendo actual (`outfit_id` o nivel) y una tabla `OUTFIT_DEFINITIONS`, como `UPGRADE_DEFINITIONS`, con nombre, `SpriteFrames`, ajustes del arma, habilidad que da y resistencias;
  - `has_sword` se mantiene como "E1 o más";
  - se reinicia en `reset_for_new_game`, se guarda en la partida y se sube `SAVE_FORMAT_VERSION`.
- **Player:** un `SpriteFrames` por atuendo, como recurso aparte. Si falta una animación, se usa la del atuendo anterior. Hay que separar el Fire Knight de las tiras de E1, que hoy comparten `SpriteFrames` en `player.tscn`.
- **Objeto para recoger:** generalizar `escenas/objetos/espada_oxidada.tscn` en una escena de atuendo con `outfit_id` exportado.
- **Menú de pausa:** sección "Equipo".
- **Probar** cada atuendo en la zona de pruebas antes de llevarlo a un mapa.

### Pendientes
- Confirmar que E2, E3 y E4 son opcionales y E5 obligatorio, o cambiarlo.
- Confirmar qué da exactamente cada atuendo (números de daño, alcance y resistencias) al jugarlo.
