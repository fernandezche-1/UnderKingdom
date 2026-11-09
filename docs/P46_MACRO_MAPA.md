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
#  ######   ########    #########     ##########################   ####  #
#       #   #      #    #                                      #   #     #
#       #   #      #[!5]#                                      #:D:#     #
#       #   #      #    #                                      #   #     #
#       #   #   ####    ########################################   ####  #
#       #   #   #                                                     #  #
#       #:F:#   #                    RUINA HELADA                     #  #
#       #   #   #                 (Guardián de hielo)                 #  #
#       #   #   ###########   ####################    #################  #
#       #   #             #   #                  #    #                  #
#       #   #             #:E:#                  #[P6]#                  #
#       #   #             #   #                  #    #                  #
#       #   ###############   ####################    #############      #
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
#                 #       (prueba final, Cthulhu)       #                #
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
| `:B:` … `:F:` | atajo que se abre desde el lado de abajo |

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
| `:B:` | Calabozo ↔ Mazmorra | la mazmorra (palanca en la repisa alta, en (67, 21)) | el desagüe entre las dos prisiones: del suelo de la cámara del preso del calabozo (x 64-66 del calabozo rehecho) a la esquina noreste de la gran sala de la mazmorra (x 70-72), por un pozo de 45 piezas, en las columnas 100-102 del mundo. Es la vuelta al depósito del alcaide (idea 1 de las puertas hacia atrás). Dibujado (2026-11-06) |
| `:C:` | Castillo ↔ Minas | las minas | ascensor minero |
| `:D:` | Minas ↔ Ruina helada | la ruina | pozo minero |
| `:E:` | Ruina ↔ Profundidades | las profundidades | vuelta rápida para la tienda o para farmear |
| `:F:` | Mazmorra ↔ Profundidades | las profundidades (palanca en la galería de los condenados) | el pozo de los condenados: de la huida de la mazmorra (x 88-90, columnas 118-120 del mundo) a la galería de los condenados (x 18-20), con palanca en (23, 25) de las profundidades. Túnel de 80 piezas, al oeste de la ruina. Idea 7 de las puertas hacia atrás. Dibujado (2026-11-06) |

## 5. Cómo rehacer una zona con este plan

- **Primero el ASCII:** Claude dibuja el ASCII de cada zona por separado, y con ese ASCII se genera el nivel real. No se genera ningún nivel antes de tener su ASCII. Método completo en la sección 9.
- Se sigue montando como dice `CLAUDE.md` ("Cómo se monta un mundo"): PNG, constructor y escena `_combate` que hereda de la base.
- La entrada y la salida van en el lado que marca el mapa (arriba, abajo o lateral), y la salida en la parte más honda cuando baja.
- Los atajos entre zonas son transiciones entre escenas. Su lado cerrado es un `arena_barrier.gd` con `open_on_encounter`, que se abre con la palanca del lado de abajo (`palanca.tscn`) y se recuerda en `completed_encounters` de `GameManager` (P49).
- Los enemigos siguen la tabla de `docs/P33_ENEMIGOS_POR_PROFUNDIDAD.md`.
- Al terminar una zona, marcarla en `TASK.md` ("Macro mapa") y anotar aquí lo que cambie.

### Piezas que ya existen
- Llaves: `grant_key` / `has_key` en `GameManager`, y `locked_door.gd`.
- Habilidades como premio: `ability_reward` de `boss_arena.gd` y `escenas/items/reliquia_habilidad.tscn`.
- Puertas que se abren con un evento: `arena_barrier.gd`.
- Estado guardado: `completed_encounters`.
- La pared agrietada que se rompe a golpes, también a puños (secretos del calabozo y de las profundidades): `escenas/objetos/pared_agrietada.tscn`, con `breakable_object.gd`, que recuerda si se rompió; 1 x 3 piezas, origen arriba a la izquierda. Arte provisional; en las profundidades, una escena heredada con otro `SpriteFrames` (P48).
- La palanca que se tira con E y marca un `encounter_id` (`escenas/objetos/palanca.tscn`, `lever.gd`; 1 x 2 piezas, origen arriba a la izquierda), y la barrera que se abre con ese id, en esa escena o en otra, al marcarse o al cargarse (`open_on_encounter` de `arena_barrier.gd`): trampillas y rejas de los atajos `:B:` a `:F:`, compuerta de la mazmorra y rejilla de la jaula del rey encadenado (con `infierno_animas_liberadas`). Arte provisional (P49).
- El objeto de lore que se lee con E y abre un diálogo JSON (`escenas/objetos/objeto_lore.tscn`, `lore_object.gd`, hereda de `npc.gd`; marca `lore_<lore_id>` en `completed_encounters` y se puede releer; P50): acta del prisionero, diario de la Reina, fosa de los soldados leales, restos de los condenados, carta de la primera reina y alma del rey encadenado. Arte y textos provisionales.
- La mejora encontrada (`escenas/items/mejora_encontrada.tscn`, `found_upgrade_pickup.gd`; tabla `FOUND_UPGRADE_DEFINITIONS` de `GameManager`, que se guarda como `found_upgrades`; P51): la empuñadura del alcaide (+0.25 de daño en los tajos con espada, el aéreo y el golpe final, no en puños ni Ultimate) y el amuleto de la guardia (+0.25 en pociones: curan 1.25; P58). Sin precio ni niveles; sale en la pestaña de mejoras del menú de pausa como "Encontrada". Arte provisional.
- El fragmento de vida (`escenas/items/fragmento_vida.tscn`, `life_fragment_pickup.gd`; `fragment_id` único por partida, `<zona>_<n>`; `GameManager.grant_life_fragment`, guardado como `life_fragments`; P54): 4 dan +1 corazón de vida máxima, con tope 6, y llenan la vida; el recuento sale en la pestaña de estadísticas. Arte provisional.
- El sello (`escenas/objetos/sello.tscn`, `seal.gd`; P55): hereda de la palanca. Se activa con E o solo, cuando se marca su `listen_encounter` (arena de la fosa, Capitán). Guarda `sello:<grupo>:<id>` en `completed_encounters`; al llegar a `seal_total` marca `sellos:<grupo>` y se abren las barreras con `open_on_seal_group`. Arte provisional.
- El rompible selectivo (`escenas/objetos/rompible_selectivo.tscn`, `selective_breakable.gd`; P56): hereda de `breakable_object.gd` y solo cede a un tipo de golpe, `accepted_hit` = Golpe final (tajo ascendente con `combo_3`, losa de la cripta) o Ultimate (estatua de la Reina). Los demás golpes sacan chispa y "RESISTE EL GOLPE". Arte provisional.
- El ascensor minero (`escenas/objetos/ascensor.tscn`, `mine_elevator.gd`; P60): una cabina por escena, E para viajar al spawn de la gemela con fundido; `requires_encounter` la deja sin corriente hasta tirar de la palanca. Arte provisional.
- Los atuendos (`OUTFIT_DEFINITIONS`, `outfits_found`, `grant_outfit` en `GameManager`; P59): `get_outfit_id()` da el de más nivel; sus rasgos (alcance, daño de tajo, reducción de daño, resistencias `cold` / `infernal_fire`) se consultan con `get_outfit_*` y `has_outfit_resistance`, y el Player los aplica. Modo dev: "Siguiente atuendo". Sin objeto, aspecto ni menú todavía.

### Piezas que faltan
- Suelo que se hunde para el derrumbe de `[!5]`: hecho, `scripts/environment/collapse_sequence.gd` (P64). Temblor de 1,5 s, suelo que cae del centro hacia fuera, trampilla de entrada sellada y huida con escombros de 0,5. Falta su arte.
- Hielo que se derrite con la llama eterna (`[P6]`): hecho (P65). `escenas/items/llama_eterna.tscn` da `grant_key("antorcha")`; el hielo es una `locked_door.gd` con `key_id` `antorcha`, `require_interact` y `MELT`; la parte oscura de la ruina (criptas) es una `scripts/environment/dark_zone.gd` con luz de 5 piezas con la llama. Falta su arte (llama y hielo).
- El contador de sellos que abre una puerta al activarlos todos (`[S3]`, `[S7]`): hecho, `escenas/objetos/sello.tscn` (P55).
- El rompible que solo acepta un tipo de golpe (losa de la cripta y estatua de la Reina): hecho, `escenas/objetos/rompible_selectivo.tscn` (P56).
- `locked_door.gd` con otro dibujo (velas, hielo de `[P6]`, hielo negro): hecho (P57). `require_interact` (E delante), `open_effect` (`FADE`, `CANDLES`, `MELT`) y `piece_tint`. Falta su arte.
- La secuencia de huida o derrumbe tras la Reina (`[!5]`): hecha, la misma pieza (P64). Los `Marker2D` de `Escombros` y la zona de salida se colocan en la Fase 3.
- La reja baja que solo se pasa rodando (`[H2]`): hecha, `scripts/environment/roll_gate.gd` (P52).
- El ascensor minero (`:C:`): hecho, `escenas/objetos/ascensor.tscn` (P60). Cabina en cada escena, E para viajar con fundido; con `requires_encounter` (la palanca de las minas) dice "NO HAY CORRIENTE" hasta entonces. Falta su arte.
- Las arenas con oleadas del infierno (coliseo de los condenados y salón de los verdugos): `arena_barrier.gd` más algo que saque una oleada tras otra.
- El fuego infernal del altar este de las profundidades (`[S7]`): fuego que sin E5 no deja pasar (quema hasta matar o empuja hacia atrás) y con E5 no hace daño. En el ASCII son trampas de fuego `F`. Pieza hecha: `escenas/sistemas/fuego_infernal.tscn` (P61); sin E5 quita 0.5 y empuja hacia atrás, con E5 no hace nada.
- El dash en el aire (`air_dash`, habilidad nueva en `ABILITY_DEFINITIONS`), premio del Guardián de hielo: unas 7 piezas (112 px) en horizontal, sin gravedad, una vez por salto (se recarga al tocar el suelo). Sus sitios son pasillos de 4 de alto con un foso de pinchos de 6 (sección 6). Pieza hecha (P66): botón de rodar en el aire, 112 px en 0.18 s, sin invulnerabilidad; falta su arte y dárselo al Guardián en la Fase 3.

## 6. Diferencias con lo que hay hoy y decisiones

- **Castillo:** hoy sale por la puerta con la llave del Rey Caído (`castillo_rey`), en las criptas de abajo. En el plan sale por `[H2]` hacia un lado. **Decidido (2026-11-04):** la llave `castillo_rey` se descarta y la salida es solo rodando. Al rehacer el castillo se quitan la puerta con llave, la llave que suelta el Rey y su entrada en la pestaña de llaves y en `BOSS_KEY_IDS`. Como el Rey deja de dar llave, da Rodar (`ability_reward`), y la reliquia de la biblioteca se quita.
- **Cementerio:**
  - Hoy ya es de bajada: superficie, cripta, catacumbas, sala del jefe y abismo. Eso encaja con el plan.
  - Pero tiene jefe: el Capitán, que da la Ráfaga y una llave para la salida. **Decidido (2026-11-04):** el Capitán guarda la tercera tumba sello, la tumba real de la cripta. Su sala de jefe es la cámara de esa tumba, y al vencerlo se activa el último sello y se abre `[S3]`. Sigue dando la Ráfaga y deja de dar llave. Se mantienen el Capitán, su sala y la cinemática del reencuentro.
- **Ruina:** **decidido (2026-11-04):** `[P6]` se abre con la llama eterna, una antorcha que se encuentra explorando la ruina. Se usa delante del hielo (tecla E) y también alumbra una parte oscura de la ruina. Así ya no hace falta un ataque hacia abajo. Idea opcional para más adelante: que el hielo también se derrita si lo alcanza una bola de fuego de un Aprendis, como truco secreto.
- **Minas:** hoy salen por una puerta con llave en el fondo. En el plan, `[L4]` es lateral, hacia la mazmorra.
- **Mazmorra, ruina, profundidades e infierno:** siguen siendo calcos con la salida por la derecha. Se rehacen con este plan.
- **Atajos:** no existe ninguno todavía.
- **Premio del Guardián de hielo:** **decidido (2026-11-08):** el dash en el aire (punto 2 de `sugerencias_exploracion.txt`), con `ability_reward air_dash`. No suelta llave.
  - **Regla de sus sitios:** un pasillo de 4 de alto con un foso de pinchos de 6 de ancho. El techo deja 1,3 piezas sobre la cabeza (el cuerpo mide 43 px), así que el salto, también con la Agilidad, no pasa ahí de unas 3 piezas en horizontal, y rodar solo se puede en el suelo. El cuerpo, de 20 px de ancho, asoma media pieza por cada borde, así que el foso de 6 deja unas 4,75 piezas que cruzar. Con un salto corto y el dash se pasa con margen. Un hueco abierto no sirve: con la Agilidad el salto llega a unas 10,7 piezas.
  - **Secretos (punto 4 de las sugerencias):** de los cuatro escalones de 5 de la Agilidad queda el de las minas. El de la ruina y el de la mazmorra pasan a ser del dash y el de las profundidades, una pared falsa (la pieza del secreto del calabozo). Y un tercer sitio del dash en las minas, al fondo de la galería de los mineros (junto a `:D:` no cabía). Los premios siguen siendo cofres (punto 5).
  - Nada obligatorio pide el dash, tampoco en el infierno.
- **Puertas hacia atrás:** **decidido (2026-11-06).** Las zonas de arriba tienen sitios que se ven antes de poder abrirlos y se abren con algo que se consigue más abajo: 9 ideas, cada una con una llave distinta, en el punto 1 de `mapas_texto/macro/sugerencias_exploracion.txt` (sitio, llave, premio, vuelta y coste). Se dibujan en el ASCII de cada zona y se montan al rehacerla. Lo que fija:
  - **Vida:** la tienda vende un solo nivel de vida máxima (de 4 a 5 corazones, por 10 monedas; `max_level` 1 en `UPGRADE_DEFINITIONS`). **Aplicado (2026-11-08, P47).** El sexto corazón sale de 4 fragmentos de vida repartidos en las puertas hacia atrás (ideas 2, 5, 8 y 9). El tope sigue siendo 6.
  - **Crystal Mauler** (`escenas/jefes/crystal_mauler.tscn`, con IA desde P62; `boss_mina.tscn` queda como el sprite viejo de `mundo_2`): pasa a ser jefe opcional de la gruta de cristal de las minas (idea 6), que pide la Agilidad y E5. Deja de proponerse para el santuario de las llamas (sección 7).
  - **Adrenalina:** la da el Mauler, con una reliquia. Ya salió de `STARTING_ABILITIES` (P63); falta montar la gruta (Fase 3).
  - **El Capitán sigue vivo** tras su combate. Tras la muerte de la Reina espera junto al trono del castillo (idea 3).
  - **Lore nuevo, como marcador:** el diario de la Reina (3 páginas), la fosa de los soldados leales, el acta del prisionero, la carta de la primera reina y el alma del rey encadenado. Sus objetos y sitios van en los ASCII y las escenas con textos provisionales; Armando escribe los definitivos más adelante.
  - **Atajos:** la idea 1 necesita `:B:`. Se añade `:F:` (sección 4).

## 7. Pendiente

- Aplicar las decisiones de la sección 6 al rehacer cada zona.
- Rehacer las zonas una a una (lista en `TASK.md`, "Macro mapa").
- Ruina: confirmar que la reja tras la sala del Guardián, que se abre al vencerlo, es el camino a `[P6]`. Lo que da al caer ya está decidido: el dash en el aire (sección 6).
- Profundidades: los minijefes de los tres altares (el plan no los dice). Propuesta, sin arte nuevo: en el coliseo, oleadas de diablillos y el demonslime común (`escenas/enemigos/demonslime.tscn`); en el lago de magma, un diablillo mayor (`diablillo.tscn` a escala 2 y con más vida); en el santuario de las llamas, un segundo demonslime (el Crystal Mauler pasa a la gruta de cristal de las minas, sección 6). El comentario del ASCII de las profundidades ya lo dice así (2026-11-08).
- Puertas hacia atrás: las 9 están dibujadas en los ASCII (Fase 1 cerrada el 2026-11-08): 1 (calabozo), 2 y 3 (castillo), 4 y 5 (cementerio), 6 (minas), 7 (mazmorra y profundidades), 8 (ruina) y 9 (profundidades, con la marca del coliseo del infierno). Falta escribir los textos de lore que quedaron como marcador.

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
| Datos del atlas (artefacto con el mundo unido, sus zonas, notas y conexiones) | `herramientas/macro_mapa/datos_atlas.py <atlas.html>`: sustituye su línea `const D = ...;` por los datos de hoy; tras cada cambio de mapa se vuelve a publicar |

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
1. Las zonas se hacen bajando por la ruta: calabozo (rehecho en ASCII el 2026-11-06), castillo, cementerio, minas…
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
- **Calabozo (ASCII rehecho, 2026-11-06):** `mapas_texto/macro/zonas/calabozo.txt`, 100 x 52, en el mundo en (36, 36). Sustituye como diseño al tramo lineal de P42 (`mapas_texto/tiles_calabozo.txt`, 136 x 46, en (0, 34)), que sigue siendo el nivel que se juega hasta generar el nuevo; su `:B:` de x 100-102, dibujado el mismo día y sin generar, queda obsoleto.
  - Es la primera zona y hace de tutorial: la más pequeña, lineal y sin bucles. Tres pisos en zigzag: se baja a por la espada y se vuelve a subir con ella al carcelero. Enseña por orden a caminar y saltar (pasillo de las celdas), pelear a puño (cuerpo de guardia), bajar escaleras (conducto y bajada), esquivar (sala larga), volver con algo nuevo (celda cerrada que se abre con la espada) y la primera pelea con espada (carcelero).
  - `[L1]` sale por el borde derecho, filas 8-10 (44-46 del mundo), con la salida `>` del constructor, pegado al castillo (columna 135). `:B:` sale por el borde de abajo, columnas 64-66 (100-102 del mundo, las del pozo de la mazmorra), desde el suelo de la cámara del preso, con trampilla cerrada desde el calabozo. El pozo recorre 45 piezas hasta la mazmorra (aviso de túnel).
  - Mantiene la historia de P42: aviso del prisionero y conducto, reja interior que obliga a bajar, cámara del preso tranquila con la espada oxidada y el atuendo (E1), y carcelero con la llave. Enemigos de la profundidad 0 con letras nuevas del constructor, `R` rata, `L` slime y `B` murciélago grande (6 ratas, 1 slime y 3 murciélagos grandes), y el carcelero a mano en la `_combate`.
  - Depósito del alcaide (idea 1) en la galería de los presos, x 12-18, tras la reja de la columna 19. Secreto: el escondite del preso, tras una pared agrietada en la columna 63 que se rompe a golpes, también a puños (`pared_agrietada.tscn`, P48).
  - Coordenadas de cada pieza y lista de lo que va en la `_combate` en la cabecera del archivo. Comprobado con una simulación de saltos de 3 piezas y huecos de 3: sin espada se llega a la espada y no al carcelero, la celda, el depósito ni el secreto; con espada y la llave, a todo y a `[L1]`, y desde todo se vuelve a la P; el depósito pide su llave y el secreto romper la pared (ni con saltos de 7); con `:B:` cerrado no se baja a la mazmorra y, abierto, desde la mazmorra se llega al depósito y se vuelve; se alcanzan todos los cofres, monedas y pociones; ningún decorado ni enemigo pisa una escalera. Probado generando una escena temporal con el constructor, sin errores; tras 3 s de física cada enemigo sigue en su sitio.
  - **Al generarlo**, el archivo pasa a `mapas_texto/tiles_calabozo.txt` y la `_combate` se rehace entera: se pierden las colisiones validadas del calabozo de hoy y hay que volver a jugarlo.
- **Castillo (ASCII, primera pasada, 2026-11-04):** `mapas_texto/macro/zonas/castillo.txt`, 110 x 80, en el mundo en (136, 0).
  - Recibe `[L1]` en su borde izquierdo, filas 44-46. `[H2]` sale por el borde derecho, filas 67-69, 3 piezas, por el paso bajo el trono. `:C:` es un hueco de 3 piezas en el borde de abajo, columnas 34-36, desde el sótano.
  - Subzonas, coordenadas y sitio de cada pieza (Rey, reja, trampillas, E2, cofres) en los comentarios del archivo.
  - Rodar pasa a ser el premio del Rey Caído (`ability_reward`), en lugar de la reliquia de la biblioteca de hoy.
  - Segunda pasada hecha: 7 Guardias, 5 Vanguardias, 11 murciélagos, 4 cofres y decorados del tileset castillo. Probada generando una escena temporal con el constructor, sin errores.
  - La puerta del gran salón a la antecámara solo se abre desde la antecámara (cerrojo en la `_combate`): el camino obligatorio pasa por la biblioteca, las almenas y la armería.
  - **Puertas hacia atrás (2026-11-06), ideas 2 y 3:**
    - **Aposentos de la Reina (idea 2):** sala nueva en x 62-74, filas 11-18, al este de la capilla, con su puerta en la columna 61 (filas 16-18) y el arco `C` en (60, 18). La antorcha pasa a (59, 18). La puerta lleva `locked_door.gd` con la llave del Caballero (`minas_caballero`, la de `[L4]`). La columna 75 queda de pared y no toca la armería. Dentro, en la `_combate`: la página I del diario (marcador) en (66, 18) y el fragmento de vida 1/4 sobre la repisa de x 70-73, en (71, 15).
    - **El castillo sin hechizo (idea 3):** no cambia el trazado. Tras la muerte de la Reina, los 7 Guardias pasan a ser soldados NPC de rodillas en sus mismos sitios, apuntados en la cabecera. El Capitán espera en (68, 62), al pie del estrado: el sitio que proponía la sugerencia, x 62-64, filas 61-62, es el estrado macizo.
    - **Simulación de saltos**, comparando el ASCII de antes y el de después con las mismas reglas:
      - con la puerta cerrada, el alcance es idéntico al de antes y la sala no se alcanza, ni con saltos de 7 y huecos de 6;
      - abierta, se llega a la sala desde la P y desde la llegada de `:C:` con saltos de 3, y desde toda la sala se vuelve a la P;
      - desde `:C:` también se llega al sitio del Capitán;
      - lo único nuevo es la sala.
    - Ningún decorado pisa otro, una escalera ni un checkpoint. Probado generando una escena temporal con el constructor, sin errores.
- **Cementerio (ASCII, primera pasada, 2026-11-04):** `mapas_texto/macro/zonas/cementerio.txt`, 120 x 90, en el mundo en (246, 43): pegado al castillo por la derecha y más abajo que su cima, al pie de la colina, para que `[H2]` caiga en las filas 67-69 del mundo.
  - Recibe `[H2]` en su borde izquierdo, filas 24-26, por un túnel bajo la colina del castillo. `[S3]` sale por el borde de abajo, columnas 10-12 (columna 256 del mundo), 3 piezas, desde el pozo del sello, al oeste de la sala del Capitán.
  - Exterior con la fosa común (tumba sello 1, reto de combate), la casa del sepulturero (checkpoint, tienda o NPC y escalera a la cripta), el hueco al osario y el foso de pinchos con la colina del panteón (tumba sello 2, reto de plataformas).
  - Cripta en tres pisos: antecripta y osario, catacumba alta y baja (con bucle) y, al fondo, la antesala, la cámara de la tumba real (el Capitán, 31 x 11 como la sala de hoy, tumba sello 3) y el pozo del sello. E3 en el panteón del caballero, al fondo este, fuera del camino.
  - Atajo interno: escalera de la columna 22 de la catacumba alta a la entrada, con trampilla que se abre desde abajo.
  - Coordenadas de cada pieza en los comentarios del archivo. Comprobado con una simulación de saltos de 3 piezas: se llega a todo y desde todo se vuelve a la entrada.
  - Segunda pasada hecha: 4 Vanguardias, 16 esqueletos de tumba, 11 murciélagos, 4 cofres, 20 monedas, 3 pociones y decorados del tileset cementerio. La repisa alta del osario pasa a ser maciza para llevar el cofre. Probada generando una escena temporal con el constructor, sin errores.
  - **Puertas hacia atrás (2026-11-06), ideas 4 y 5:**
    - **Estatua de la Reina (idea 4):** al extremo este de la cornisa de la colina, la estatua (`estatua_rompible.tscn`, solo con la Ultimate) tapa el hueco de la columna 111, filas 15-17. Las filas 12-14 de esa columna quedan de roca para que no se pase por encima, así que la cueva va en x 112-118, filas 12-17 (suelo 18), bajo la meseta del panteón, y no desde la 111 como decía la sugerencia. Dentro, en la `_combate`: las notas de los soldados (marcador) en (113, 17) y el amuleto de la guardia en (115, 17).
    - **Cripta de la primera reina (idea 5):** bajo el mausoleo, x 62-74, filas 29-34 (suelo 35), con las repisas nuevas del osario en las filas 45 (x 69-73) y 42 (x 65-70). Como decía la sugerencia, no se podía entrar: de la repisa de la fila 42 al suelo de la cripta hay 7 piezas. Por eso se añade una escalera en la columna 68 (filas 35-41) por el nicho (x 67-69, filas 36-37), con la losa (tajo ascendente con el Golpe final) tapando el hueco de la fila 35. Dentro, la antecámara (x 66-74), la puerta de velas en la columna 65 (filas 32-34; llama eterna) y el sepulcro (x 62-64) con el sarcófago de x 62-63. La corona con la carta (marcador) va en (63, 33) y el fragmento de vida 2/4 en (64, 34). El murciélago de (72, 44) pasa a (76, 44).
    - **Simulación de saltos**, comparando el ASCII de antes y el de después con las mismas reglas (cuerpo de 3, saltos de 3, huecos de 3):
      - con la estatua, la losa y las velas cerradas, no se llega a la cueva ni a la cripta, ni con saltos de 7 y huecos de 6;
      - desde la P y desde la llegada de `[S3]`, el alcance es el de antes más las dos repisas y la escalera del osario, así que el camino obligatorio no cambia;
      - rota la estatua, se llega a la cueva; rota la losa, a la antecámara y no al sepulcro; con las velas, al sepulcro;
      - desde todo se vuelve a la P.
    - Ningún decorado pisa otro, una escalera ni un checkpoint. Probado generando una escena temporal con el constructor, sin errores.
- **Minas (ASCII, primera pasada, 2026-11-04):** `mapas_texto/macro/zonas/minas.txt`, 150 x 90, en el mundo en (150, 133): justo debajo del cementerio, y bajo el sótano del castillo, para cubrir las columnas de `:C:` (170 del mundo) y `[S3]` (256).
  - Recibe `[S3]` por el borde de arriba, columnas 106-108, en el pozo del sello, con escalera en la columna 107 para volver al cementerio. `:C:` entra por el borde de arriba, columnas 20-22: el pozo del ascensor baja a la estación, con la palanca en (12, 40). Entre el sótano del castillo y las minas el pozo recorre 53 piezas (el verificador lo avisa como túnel).
  - `[L4]` sale por el borde izquierdo, filas 66-68 (fila 199 del mundo), 3 piezas, por un túnel encima de la sala del Caballero con la puerta con llave en la columna 28. `:D:` es un hueco de 3 piezas en el borde de abajo, columnas 132-134 (columna 282 del mundo), al fondo este de la galería honda.
  - Bocamina (checkpoint), galería alta, galería de las vagonetas, veta ardiente con dos fosos de lava, galería honda, antecámara (checkpoint) y sala del Caballero (31 x 13, la de hoy) en la parte más honda, junto a `[L4]`. Tres bucles y un atajo interno: la escalera de la columna 48, de la antecámara a una trampilla de la galería de las vagonetas que se abre desde abajo. Hoy ese atajo sale de la sala del jefe; ahora sale de la antecámara, y la sala ya no tiene `Atajos`.
  - Secreto de la Agilidad en la pared este de la bocamina: un escalón de 5 piezas, como la poción de (29, 6) de las minas de hoy (P45).
  - Coordenadas de cada pieza en los comentarios del archivo. Comprobado con una simulación de saltos de 3 piezas: se llega a todo menos al secreto (tampoco con 4; sí con 6) y desde todo se vuelve a la bocamina. Probada generando una escena temporal con el constructor, sin errores.
  - Segunda pasada hecha: 6 kolbo, 6 kolbo2, 4 kolbo3, 10 murciélagos, 4 trampas de fuego en la veta, 4 cofres (uno en el secreto), 15 monedas, 3 pociones y decorados del tileset mazmorra (campamento en la bocamina, vagonetas de cajas y barriles). Con saltos de 3 se alcanza todo menos lo del secreto. Probada generando una escena temporal con el constructor, sin errores.
  - **Puerta hacia atrás (2026-11-06), idea 6, la gruta de cristal:**
    - **Trazado:** la boca está en la pared este de la veta (columna 131, filas 52-55), con el suelo 5 piezas por encima del de la veta: el escalón de la Agilidad. Sigue el pasillo del fuego (x 131-143, filas 52-55, 4 de alto), con el fuego infernal (`F`, la pieza nueva del santuario) en x 133-141 y un checkpoint en (142, 55), tras el fuego. La bajada (x 144-146, filas 52-63) no tiene escalera: se cae a la gruta (x 132-147, filas 64-77). La salida es un hueco en el suelo (x 138-140) con la escalera 139 hasta la galería honda. La caja de (139, 86) pasa a (135, 86) y el murciélago de (138, 82) a (136, 82).
    - **Sala de jefe opcional del Crystal Mauler** (`boss_arena.gd`): la trampilla de entrada (fila 63) va en `Puertas`, y la del suelo (fila 78), en `Atajos`, cerrada hasta vencerlo. Desde la galería honda se ve la escalera que acaba en esa trampilla cerrada. Da la Adrenalina (`ability_reward adrenaline`), sin llave.
    - **El Mauler cabe en 16 x 14 a escala 1:** colisión de 20 x 35 px, cuerpo de unas 3 x 2,5 piezas y `sp_atk` de unas 12,5 x 6 piezas (3,7 hacia atrás y 8,8 hacia delante). Es la sala de jefe más pequeña: contra el `sp_atk` hay que ponerse detrás o rodar. Su IA ya está hecha (`escenas/jefes/crystal_mauler.tscn`, `simple_boss.gd`; P62): 16 de vida, tres tajos y `sp_atk` en fase 2. Falta montarlo en la gruta (Fase 3).
    - Se supone que la Agilidad (`agility`, P45), como es una habilidad, se conserva al llevar E5.
    - **Simulación de saltos**, comparando el ASCII de antes y el de después con las mismas reglas (cuerpo de 3 y de 2, saltos de 3 y de 4, huecos de 3):
      - no se pierde ninguna posición; lo único nuevo es la escalera 139 bajo la trampilla cerrada, así que el camino obligatorio no cambia;
      - sin la Agilidad no se llega al pasillo ni a la gruta, tampoco con E5;
      - con la Agilidad (saltos de 6, y también de 7) se llega a la boca, pero sin E5 el fuego no deja pasar;
      - con la Agilidad y E5 se llega al checkpoint y a la gruta, y con la trampilla del suelo cerrada no se sale;
      - vencido el Mauler, desde toda la gruta se vuelve a la P con saltos de 3 y sin E5, y desde el checkpoint con E5.
    - Probado generando una escena temporal con el constructor, sin errores.
  - **Secreto del dash (2026-11-08), punto 4 de las sugerencias:** al fondo este de la galería de los mineros, cavado en roca: pasillo de 4 de alto (x 35-42, filas 53-56), foso de pinchos de 6 (x 37-42) y nicho x 43-45, filas 50-56, con el cofre en (45, 56) y dos monedas sobre el foso. Junto a `:D:` no cabía: al este de la galería honda quedan 9 columnas. El escalón de la Agilidad de la bocamina se queda: es el único que hay ya en el mundo.
    - **Simulación de saltos con dash**, con las mismas reglas que en la ruina (trampilla del atajo, reja de `:D:`, puerta de `[L4]` y gruta cerradas): sin dash no se pierde ninguna posición y no se llega al nicho ni con saltos de 7 y huecos de 6; con el dash se llega y se vuelve a la P. Lo único más que abre el dash es la plataforma alta de la sala del Caballero, dentro de la sala, a la que con E1 ya se llega en el juego.
    - Probado generando una escena temporal con el constructor, sin errores.
- **Mazmorra (ASCII, primera pasada, 2026-11-04):** `mapas_texto/macro/zonas/mazmorra.txt`, 120 x 90, en el mundo en (30, 133): a la izquierda de las minas, a su misma profundidad. Su borde derecho es la columna 149 y su borde de abajo, la fila 222, como el de las minas.
  - Recibe `[L4]` en su borde derecho, filas 66-68, sin túnel: `<` pegada a la `>` de las minas. `[!5]` sale por el borde de abajo, columnas 115-117 (145-147 del mundo), 3 piezas, al final de la huida. La ruina tendrá que cubrir de la columna 145 a la 284 del mundo (`[!5]` y `:D:`): unas 140 piezas de ancho, empezando en la fila 223.
  - Llegada (checkpoint), cuerpo de guardia, celdas bajas y altas, gran sala de guardia (43 x 35), torre del alcaide, sala de tortura, desagües y antesala (checkpoint). La sala de la Reina (23 x 17, la de hoy) está en la parte más honda, al suroeste, con su única entrada de 3 piezas por arriba.
  - Bucle por las celdas altas, la torre y la gran sala. Atajo interno: la compuerta de los desagües, que se abre desde la antesala.
  - Derrumbe: al morir la Reina se hunden 15 piezas del suelo de su sala (x 8-22, fila 75) y la trampilla de entrada queda tapada. La huida corre hacia el este bajo los desagües, con 4 fosos de pinchos de 3 de ancho y escalones de 3 como mucho, hasta `[!5]`.
  - Añadido al plan: la escalera del colector, que va de la huida al cuerpo de guardia y tiene una trampilla que solo se abre desde abajo. Antes de la Reina no deja bajar a la huida. Después, permite volver desde la ruina.
  - El suelo que se hunde está dibujado como bloque: la sala queda entera durante el combate, y la pieza nueva tiene que quitar esas celdas al hundirse.
  - Secreto de la Agilidad al fondo este de la torre: un escalón de 5 piezas, como el de las minas; desde el 2026-11-08 es el secreto del dash (ver abajo).
  - `:B:` (2026-11-06): pozo de 3 piezas en el borde de arriba, columnas 70-72 (100-102 del mundo), con escalera en la columna 71 (filas 0-21) hasta la esquina noreste de la gran sala, donde la repisa alta se junta con la torre. Palanca en (67, 21) y spawn `DesdeCalabozo` hacia (69, 21); la llave del alcaide de (73, 21) queda a dos piezas. El kolbo3 de la repisa pasa de (66, 21) a (62, 21). Por este lado no se cierra.
  - Coordenadas de cada pieza en los comentarios del archivo. Comprobado con una simulación de saltos de 3 piezas: se llega a todo menos al secreto (tampoco con 4; sí con 6), desde todo se vuelve a la llegada y la huida solo se alcanza tras el derrumbe. Probada generando una escena temporal con el constructor, sin errores.
  - Segunda pasada hecha: 5 Aprendis, 2 mino, 7 kolbo3 y 6 esqueletos, 4 cofres (uno en el secreto; el de la torre, en (73, 21), se quitó al cerrar la Fase 1 para dejar sitio a la llave del alcaide), 14 monedas, 3 pociones y decorados del tileset mazmorra (estanterías en la torre y la gran sala, la fogata de la guardia y agua y hongos en los desagües). El mino mide 5 piezas de alto y solo cabe en la gran sala y en la torre. Las plataformas del cuerpo de guardia bajan una fila (66 y 63): estaban a 4 piezas. Con saltos de 3 se alcanza todo menos lo del secreto. Probada generando una escena temporal con el constructor, sin errores; tras 3 s de física cada enemigo sigue en su sitio.
  - **Puerta hacia atrás (2026-11-06), idea 7, el pozo de los condenados (`:F:`):**
    - **Trazado:** hueco de 3 en el suelo de la huida, x 88-90 (columnas 118-120 del mundo), junto al pie de la escalera del colector, con escalera en la columna 89 (filas 84-89) hasta el borde de abajo. La trampilla de la fila 84 está cerrada desde la mazmorra: se ve en el suelo de la huida y la abre la palanca de las profundidades (`mazmorra_atajo_f_abierto` en `completed_encounters`). Spawn `DesdeProfundidades` hacia (92, 83).
    - Abierta, deja un hueco de 3 en el suelo de la huida: se salta, y quien cae baja a las profundidades. Es la vuelta más rápida desde el abismo hacia `:B:` y `[L4]`, subiendo por el colector.
    - **Simulación de saltos**, comparando el ASCII de antes y el de después con las mismas reglas (cuerpo de 2 y de 3, saltos de 3 y de 4, huecos de 3):
      - con la trampilla cerrada, el alcance desde la P es idéntico al de antes, también tras la Reina (suelo hundido, entrada tapada y colector abierto), y desde la huida no se baja por el pozo;
      - abierta, desde el pie del pozo se llega a la P por el colector y a `[!5]`, y lo único nuevo es el pozo. El camino obligatorio no cambia.
    - Probado generando una escena temporal con el constructor, sin errores.
  - **Secreto del dash (2026-11-08), punto 4 de las sugerencias:** el escalón de 5 de la Agilidad al fondo este de la torre (x 109-117, filas 12-16) pasa a roca. En su lugar, un pasillo de 4 de alto (filas 18-21) que sale del suelo de la torre por la columna 109, con un foso de pinchos de 6 (x 109-114) desde la misma boca, y un nicho x 115-117, filas 14-21, con el cofre en (117, 21). Las dos monedas van sobre el foso. Se vuelve a por él desde la ruina, por `[!5]`, la huida y el colector.
    - **Simulación de saltos con dash**, con las mismas reglas que en la ruina (compuerta, trampilla del colector y de `:F:` cerradas): sin dash no se pierde ni aparece ninguna posición fuera del viejo secreto, y no se llega al nicho ni con saltos de 7 y huecos de 6; con el dash se llega y se vuelve a la P; el dash no abre nada más, y la huida sigue sin alcanzarse antes de la Reina.
    - Probado generando una escena temporal con el constructor, sin errores.
- **Ruina helada (ASCII, primera pasada, 2026-11-04):** `mapas_texto/macro/zonas/ruina.txt`, 156 x 80, en el mundo en (136, 223): justo debajo de la mazmorra y las minas, que acaban en la fila 222, de la columna 136 a la 291.
  - Recibe `[!5]` por el borde de arriba, columnas 9-11 (145-147 del mundo), y `:D:` también por arriba, columnas 146-148 (282-284). Las dos sin túnel, con su escalera en la misma columna que la de la mazmorra (116) y la de las minas (133).
  - `[!5]`: el Player cae unas 15 piezas (no hay daño por caída) a la llegada, suelo liso y sin enemigos. La única vuelta atrás es esa escalera, hacia la huida y el colector.
  - `:D:`: el pie del pozo tiene la palanca que abre la reja de las minas, en (140, 17).
  - `[P6]` sale por el borde de abajo, columnas 145-147 (281-283 del mundo), 3 piezas. `:E:` es un pozo de 3 piezas en el suelo de la antesala, columnas 90-92 (226-228), con trampilla cerrada desde la ruina. **Las profundidades tendrán que cubrir de la columna 226 a la 283 del mundo, empezando en la fila 303.**
  - Llegada (checkpoint), exterior helado, torre caída, pasillo y pie del pozo arriba; galería alta y baja en medio; capilla de la llama eterna, criptas oscuras, refugio del explorador, antesala (checkpoint), sala del Guardián (38 x 11, la de hoy), cámara del deshielo y pozo de `[P6]` abajo.
  - Bucles por las dos galerías (escaleras 5 y 118) y por el pie del pozo, la torre y la galería alta (escalera 151). Atajo interno: la escalera 5, de la galería baja a la llegada, con trampilla que se abre desde abajo.
  - La llama eterna está en la capilla, en (5, 62), fuera del camino directo al jefe. La parte oscura son las criptas (x 32-62, filas 50-64): solo se entra por la capilla, así que siempre se llega con la llama. Tras ellas, el refugio del explorador con el Abrigo (E4), en (69, 56), como secreto.
  - Zonas frías, opcionales: la cumbre del viento (x 66-103, filas 2-11) y el lago helado (x 50-70, filas 18-23). Secreto de la Agilidad al fondo este de la galería baja, un escalón de 5 piezas, como en las minas y la mazmorra; desde el 2026-11-08 es el secreto del dash (ver abajo).
  - **Añadido al plan:** el hielo de `[P6]` es un muro de 1 x 3 (columna 144, filas 70-72) tras la sala del Guardián, y a él se llega por una reja en la pared este de la sala (columna 134), que va en `Atajos` de `boss_arena.gd` y se abre al vencerlo. Así la salida pide el jefe y la llama eterna. Qué da el Guardián al caer queda pendiente (sección 7).
  - Coordenadas de cada pieza en los comentarios del archivo. Comprobado con una simulación de saltos de 4 piezas y huecos de 3: se llega a todo menos al secreto (sí con 6) y a la cámara del deshielo, que pide abrir la reja; desde todo se vuelve a la llegada. El camino obligatorio sale incluso con saltos de 3.
  - Segunda pasada hecha: 6 Aprendis, 2 mino, 7 kolbo3 y 8 esqueletos, 4 cofres (uno en el secreto), 18 monedas, 3 pociones y decorados del tileset mazmorra (cristales de hielo, antorchas salvo en el exterior y la parte oscura, estanterías en las galerías, cajas de los mineros en el pie del pozo, agua y hongos en el lago). El mino solo cabe en el exterior helado. Con saltos de 4 se alcanza todo menos lo del secreto. Probada generando una escena temporal con el constructor, sin errores; tras 3 s de física cada enemigo sigue en su sitio.
  - **Puerta hacia atrás (2026-11-07), idea 8, el hielo negro:**
    - **Trazado:** cámara nueva en x 114-130, filas 52-58 (suelo 59, el de la antesala), al este de la antesala, con la puerta en su pared este, columna 113, filas 56-58. Entre la cámara y la galería baja quedan 4 filas de roca (48-51) y, hasta el techo de la sala del Guardián, 3 (59-61). Dentro, una repisa de una vía en x 124-127, fila 56, a 3 piezas del suelo, y cristales de hielo.
    - **La puerta:** hielo oscuro, la misma pieza que el hielo de `[P6]` (`locked_door.gd` con otro dibujo, en la `_combate`), con `key_id` `profundidades_ascua`, la ascua que suelta el Demon Slime en el `PuntoLlave` de su sala. Basta con la ascua: quien la tiene ya pasó `[P6]` con la llama. Sin ella, al pulsar E sale "LA LLAMA NO BASTA" (marcador). En el ASCII la puerta queda abierta, como la de los aposentos del castillo, para que la `locked_door` pueda cerrarla. Por lo mismo, el hielo de `[P6]` (columna 144, filas 70-72), que era bloque, pasa a quedar abierto en el ASCII. Con la misma simulación, con el hielo cerrado el alcance no cambia y no se sale por `[P6]` ni con saltos de 7 y huecos de 6; solo se sale con la reja y el hielo abiertos, y desde el spawn `DesdeProfundidades` se vuelve a la P.
    - **Premio, en la `_combate`:** la página III del diario (marcador, sección 6) en (117, 58) y el fragmento de vida 3/4 sobre la repisa, en (125, 55). Sin enemigos ni monedas.
    - **Vuelta:** por `:E:`, que sube a esta misma antesala (spawn hacia (94, 58)), o por `[P6]`, la cámara del deshielo, la sala del Guardián y la escalera 100.
    - **Simulación de saltos**, comparando el ASCII de antes y el de después con las mismas reglas (cuerpo de 3 y de 2, saltos de 3 y de 4, huecos de 3, con la reja de salida cerrada y abierta):
      - con la puerta cerrada, el alcance desde la P es idéntico al de antes, y no se llega a la cámara ni con saltos de 7 y huecos de 6, tampoco desde `:E:`; el camino obligatorio no cambia;
      - abierta, lo único nuevo es la cámara, la página y el fragmento se alcanzan con saltos de 3, y desde toda la cámara se vuelve a la P;
      - desde el spawn de `:E:` se llega a la página, al fragmento y a la P.
    - Probado generando una escena temporal con el constructor, sin errores.
  - **Secreto del dash (2026-11-08), punto 4 de las sugerencias:** el escalón de 5 de la Agilidad (x 131-140, filas 37-42) pasa a roca. En su lugar, un pasillo de 4 de alto (x 131-138, filas 44-47) al nivel de la galería baja, con un foso de pinchos de 6 (x 133-138, 2 de hondo), y una cámara x 139-148, filas 40-47, con el cofre en (147, 47). Las dos monedas van sobre el foso. Está a dos escaleras de la sala del Guardián, que da el dash: es donde se aprende.
    - **Simulación de saltos con dash** (de 7 piezas, una vez por salto), comparando el ASCII de antes y el de después (cuerpo de 3 y de 2, saltos de 3 y de 4, huecos de 3, con trampillas, reja e hielos cerrados):
      - sin dash no se pierde ninguna posición fuera del viejo secreto, y lo único nuevo es la boca del pasillo: el camino obligatorio no cambia;
      - sin dash no se llega a la cámara, ni con saltos de 6 y 7 y huecos de 6;
      - con el dash se llega a toda la cámara con saltos de 3, y desde ella se vuelve a la P;
      - el dash no abre nada más en la ruina.
    - Probado generando una escena temporal con el constructor, sin errores.
- **Profundidades (ASCII, primera pasada, 2026-11-05):** `mapas_texto/macro/zonas/profundidades.txt`, 231 x 85, en el mundo en (100, 303): justo debajo de la ruina, que acaba en la fila 302, de la columna 100 a la 330. Es más ancha que la ruina y sobresale por los dos lados, bajo la mazmorra (oeste) y bajo el cementerio (este), para que el infierno quede centrado debajo de todo.
  - Recibe `:E:` por el borde de arriba, columnas 126-128 (226-228 del mundo), y `[P6]` también por arriba, columnas 181-183 (281-283). Las dos sin túnel, con su escalera en la misma columna que la de la ruina (91 y 146). Las dos llevan al mismo camino: el pie de `:E:` está en él, unido a la llegada de `[P6]` por el puente de ceniza.
  - `:E:`: el pie del pozo tiene la palanca que abre la trampilla de la antesala de la ruina, en (119, 13).
  - `[S7]` sale por el borde de abajo, columnas 114-116 (214-216 del mundo), 3 piezas, desde un pozo al este de la sala del Demon Slime. El infierno tendrá que recibirlo en esas columnas, empezando en la fila 388.
  - Tres partes: el centro (llegada, puente de ceniza, pie de `:E:`, gran caverna con cornisa y puente de huesos, encrucijada, lago de magma, antesala, sala del Demon Slime y pozo de `[S7]`), el oeste (galería de los condenados, coliseo, forja y secreto) y el este (chimenea de azufre y santuario de las llamas). Cada punta lleva un altar y un checkpoint.
  - Tres altares (sellos, con el contador de `[S3]`): el coliseo de ceniza al oeste (combate), el lago de magma en el centro (plataformas sobre lava) y el santuario de las llamas al este, en lo más hondo de la chimenea, rodeado de fuego.
  - E5 (el Fire Knight) está en la forja, bajo el coliseo, a saltos de 3. El santuario es el único reto que lo pide.
  - Sala del Demon Slime (22 x 9, la de hoy) en la parte más honda, con sus dos entradas de hoy: reja de 5 en su primera columna, junto a la escalera de la antesala, y trampilla de 6 por arriba. Las dos van en `Puertas` y siguen cerradas hasta activar los tres altares. La reja de salida, en `Atajos`, lleva al pozo de `[S7]`.
  - Bucles por los dos pisos de la caverna, por el oeste (galería, coliseo, forja, antesala, encrucijada y caverna) y por la chimenea. Atajo interno: la escalera 68, de la antesala a la galería de los condenados, con trampilla que se abre desde abajo. Secreto de la Agilidad al fondo oeste de la galería, un escalón de 5 piezas; desde el 2026-11-08 es una pared falsa (ver abajo).
  - **Añadido al plan:** la isla del lago vuelve a la caverna por una escalera con trampilla que se abre desde abajo (así no se saltan los pilares); el pozo de `[S7]` lleva escalera para volver desde el infierno, como el de `[P6]`; el fuego del santuario es una pieza nueva (sección 5). Los minijefes quedan pendientes (sección 7).
  - Coordenadas de cada pieza en los comentarios del archivo. Comprobado con una simulación de saltos de 4 piezas y huecos de 3: se llega a todo menos al secreto (sí con 6), al santuario (pide E5), a la sala (pide los tres altares) y al pozo de `[S7]` (pide el jefe); desde todo se vuelve a la llegada. El camino obligatorio sale incluso con saltos de 3.
  - Segunda pasada hecha: 22 diablillos (vuelan, así que van en el aire), 5 cofres (uno en el secreto y otro en la isla del lago), 15 monedas, 4 pociones y decorados del tileset mazmorra (antorchas, ascuas con los cristales y la forja con fogatas, caja y barril). La plataforma alta del coliseo pasa a x 21-28: a x 22-27 quedaba a 5 de las otras. Con saltos de 4 se alcanza todo menos lo del secreto. Probada generando una escena temporal con el constructor, sin errores; tras 3 s de física cada enemigo sigue en su sitio.
  - **Pozo de `:F:` (2026-11-06), idea 7 de las puertas hacia atrás:**
    - **Trazado:** pozo x 18-20, filas 0-19 (columnas 118-120 del mundo), que se abre al techo de la galería de los condenados, con escalera en la columna 19 (filas 0-25), que sigue la 89 de la mazmorra. Entre las dos zonas hay un túnel de 80 piezas (filas 223-302 del mundo), al oeste de la ruina, que empieza en la columna 136.
    - En la `_combate`: la palanca en (23, 25), el spawn `DesdeMazmorra` hacia (16, 25), y al pie del pozo los restos de los condenados (lore) en (14, 25) y la página II del diario en (12, 25), con textos de marcador (sección 6). La antorcha de (20, 21) pasa a (24, 21), fuera de la columna vecina de la escalera.
    - El premio se alcanza al llegar, sin abrir nada; lo que se abre hacia atrás es el atajo, como proponía la sugerencia ("al llegar a las profundidades: 6 y 7"). Por este lado no se cierra: quien sube sin la palanca llega bajo la trampilla cerrada y vuelve a bajar.
    - **Simulación de saltos** (cuerpo de 2 y de 3, saltos de 3 y de 4, huecos de 3, también con E5):
      - no se pierde ninguna posición, y los únicos sitios nuevos donde estar de pie son los de la escalera 19;
      - el secreto de la Agilidad sigue sin alcanzarse con saltos de 4 (antes y después se alcanza desde 5);
      - desde la P se llega a lo alto del pozo, y desde ahí se vuelve a la P.
    - Probado generando una escena temporal con el constructor, sin errores.
  - **Puerta hacia atrás (2026-11-08), idea 9, el rey encadenado:**
    - **Trazado:** jaula en el techo de la galería de los condenados, x 44-48, filas 16-19, junto al checkpoint de (50, 25). Las columnas 43 y 49 y la fila 15 son roca. La rejilla va en x 44-48, fila 20, la de arriba de la galería: es pieza de la `_combate` (la barrera que se abre según `completed_encounters`, como las de `:E:` y `:F:`) y en el ASCII queda abierta. Cerrada, el techo baja ahí a la fila 21 (5 de alto).
    - **No se entra en la jaula:** no tiene suelo y la rejilla está 6 piezas sobre el de la galería. Por eso el premio sale de ella. Antes, el rey encadenado (sprite del Rey Caído, `escenas/jefes/rey_caido.tscn`, sin arte nuevo) está dentro, en (46, 19), y se ve al pasar, porque la galería es camino obligatorio. Con `infierno_animas_liberadas`, que marca el coliseo de los condenados del infierno al vencer su última oleada, la rejilla se abre, el rey de la jaula se oculta y aparecen en el suelo el alma del Rey Caído en (46, 25), con su texto de marcador ("no fue ella sola", sección 6), y el fragmento de vida 4/4 en (44, 25). Pieza: mostrar u ocultar según un encuentro superado, la misma de la idea 3.
    - **Vuelta:** desde el infierno, la sima, la escalera 55 de `[S7]` y, en las profundidades, la escalera 115, la sala del Demon Slime y la escalera 68.
    - **De paso:** el santuario de las llamas ya no nombra al Mauler (va el segundo demonslime, sección 7), y la sala del Demon Slime lleva su `PuntoLlave` hacia (100, 78), donde cae la ascua (`profundidades_ascua`) del hielo negro de la ruina.
    - **Simulación de saltos**, comparando el ASCII de antes y el de después con las mismas reglas y cierres (cuerpo de 2 y de 3, saltos de 3 y de 4, huecos de 3, con y sin E5):
      - con la rejilla cerrada, el alcance desde la P es idéntico al de antes; abierta, no aparece ni se pierde ninguna posición, así que el camino obligatorio no cambia;
      - dentro de la jaula no se está de pie nunca, ni con saltos de 7 y huecos de 6;
      - desde el pie de `[S7]`, con la sala y la reja de salida abiertas, se llega al alma, al fragmento y a la P, por la escalera 68 o, con su trampilla cerrada, por la forja y el coliseo; desde ahí se vuelve a la P y a `[S7]`;
      - en el infierno, desde el coliseo se vuelve a `[S7]` con saltos de 4.
    - Probado generando una escena temporal con el constructor, sin errores.
  - **Pared falsa (2026-11-08), punto 4 de las sugerencias:** el escalón de 5 de la Agilidad (x 4-11, filas 16-20, sobre un pilar) pasa a roca. En su lugar, una sala x 4-7, filas 21-25, al suelo de la galería, tras una pared agrietada en la columna 8 (filas 23-25), la misma pieza del escondite del calabozo (`pared_agrietada.tscn`, P48; aquí con el arte de su tileset). Queda abierta en el ASCII. Cofre en (5, 25) y dos monedas. Se ve desde el pie del pozo de `:F:`.
    - **Simulación de saltos**, con las mismas reglas y cierres: con la pared cerrada no se pierde ni aparece ninguna posición fuera del viejo nicho, y no se llega a la sala ni con saltos de 7 y huecos de 6 ni con el dash; rota, se llega con saltos de 3 y se vuelve a la P.
    - Probado generando una escena temporal con el constructor, sin errores.
- **Infierno (ASCII, segunda versión, 2026-11-06): la prueba final.** `mapas_texto/macro/zonas/infierno.txt`, 111 x 120, en el mundo en (160, 388). Misma posición y ancho que la primera versión (2026-11-05, 111 x 66, corta y sin bucles); crece solo hacia abajo. `[S7]` sigue en las columnas 54-56 (214-216 del mundo), sin túnel, con su escalera en la columna 55.
  - **Por qué se rehízo:** la primera versión era un descenso corto hasta Cthulhu. Se decidió (2026-11-06) que el infierno sea la zona más difícil: una sucesión de pruebas, una por cada cosa que el jugador aprendió al bajar, con los enemigos más duros.
  - **Pruebas, en orden:** fuego (paso de las cadenas, con fuego infernal, E5), salto (sima de las ánimas, la de la primera versión), combate (coliseo de los condenados: la antigua sala de Cthulhu, cerrada con oleadas), rodar (pasillo del filo: 4 de alto, con tres rejas bajas como la de `[H2]` y enemigos que no se saltan), aire (caverna del vuelo: repisas sobre lava con diablillos y murciélagos) y parry (salón de los verdugos: cerrado, con Guardias y minos). Después, el umbral (descanso) y el trono de Cthulhu.
  - **Enemigos:** excepción a P33. El infierno reúne las ánimas de lo vencido al bajar, así que mezcla los más duros de todas las profundidades: mino, kolbo3, Aprendis, Guardia, esqueleto, kolbo2, diablillo y murciélago. Los definitivos están por decidir.
  - **Checkpoints:** llegada, antesala del coliseo, tras el coliseo y umbral. Rodar, aire y parry van seguidas, sin checkpoint entre ellas.
  - Trono de Cthulhu: misma medida (56 x 21), ahora en x 45-100, filas 96-116, con la reja de entrada en la columna 44 (filas 113-116), plataformas de una vía a escalones de 4 y Cthulhu en (96, 116). Sin llave: al vencerlo sale "HAS VENCIDO A CTHULHU" (P34, sección 6).
  - Opcional: el mirador de ceniza y el osario (los de la primera versión, ahora con enemigos más duros) y un rincón con cofre al este del pasillo del filo.
  - Ningún escalón obligatorio pide más de 4 piezas ni huecos de más de 3; nada pide E3 ni E4. Comprobado con una simulación de saltos sobre la cuadrícula: desde la P se llega a todo y desde todo se vuelve (con rejas y trampillas abiertas). Con saltos de 3 no se vuelve a subir la sima, como antes.
  - **Piezas nuevas:** las arenas cerradas con oleadas del coliseo y del salón (`arena_barrier.gd` más un generador de oleadas, que no existe) y las rejas bajas del pasillo (la misma pieza de `[H2]`, ya hecha: `roll_gate.gd`, P52).
  - Coordenadas de cada pieza en la cabecera del archivo.
  - El coliseo marca `infierno_animas_liberadas` al vencer su última oleada (2026-11-08): abre la jaula del rey encadenado de las profundidades (idea 9).
- Con el infierno quedan dibujadas todas las zonas (primera pasada). `:B:` y `:F:` quedaron dibujados el 2026-11-06 (ver el calabozo, la mazmorra y las profundidades). El verificador da 0 errores y avisa de los túneles de `:B:` (45 piezas), `:C:` (53) y `:F:` (80).
- **Cierre de la Fase 1 (2026-11-08):** las 9 puertas hacia atrás del punto 1 de `sugerencias_exploracion.txt` están dibujadas. Repasada la tabla "Desbloqueos por zona" (sección 10) contra la cabecera de cada ASCII:
  - **Mazmorra:** la llave del alcaide iba "en lugar del cofre de (73, 21)", pero el ASCII seguía con la `c` y la cabecera la contaba como cofre. Se quita la `c` (no cambia ninguna colisión: el cofre no es sólido) y la cabecera apunta la llave en la `_combate`, en "Se consigue" y en "Viven en". La zona queda con 3 cofres.
  - **Tabla:** el calabozo dice ya que su puerta está dibujada; la salida de la ruina pide también vencer al Guardián (la reja de salida va en `Atajos`); las profundidades llegan con la llama eterna, no solo con E4.
  - El resto coincide: lo que da cada zona, lo que pide cada salida y el sitio, la llave y la vuelta de cada puerta.
  - El verificador da 0 errores, con los mismos tres avisos de túnel.

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
| E2 | Soldado del castillo (cota y espada de guardia) | castillo, en la armería | más alcance del tajo (1.25) | plan; opcional; rasgos en `GameManager` (P59) |
| E3 | Caballero de la cripta (armadura de un caballero enterrado) | cementerio, en una tumba real de la cripta | la **Agilidad** (P45) y más resistencia | plan; opcional |
| E4 | Abrigo de la ruina | ruina helada, en un secreto | el frío de la ruina no hace daño | plan; opcional |
| E5 | Fire Knight (espada grande) | profundidades | el más fuerte; resiste el fuego | arte existente; falta separarlo de E1 |

- **Más daño o alcance:** se ajusta con `sword_hitbox_offset_x` y `sword_hitbox_scale_x`, para que un arma más larga alcance más.
- **Resistencias:** en múltiplos de 0.25, o "no hace daño".
- **E3 da la Agilidad.** Resuelve el pendiente de P45 (dónde se consigue, antes de las minas).
- **E5 responde al pendiente de P42** sobre la espada buena con armadura.

### Desbloqueos por zona
"Hoy" es lo que ya está en las escenas `_combate`; "plan" es lo de esta propuesta.

La última columna son las puertas hacia atrás (sección 6): se ven en esa zona y se abren con lo que se consigue más abajo. Todas son opcionales. Detalle en el punto 1 de `mapas_texto/macro/sugerencias_exploracion.txt`.

| Zona | Llega con | Se consigue aquí | La salida pide | Puertas hacia atrás que hay aquí |
|---|---|---|---|---|
| Prisión | E0; tajo aéreo, parry, robo de vida y adrenalina (`STARTING_ABILITIES`; la adrenalina ya salió de la lista, P63: la da el Mauler) | — | — | — |
| Calabozo | E0 (salto de unas 3 piezas) | E1 (hoy); llave del carcelero (hoy) | `[L1]` llave del carcelero | 1. Depósito del alcaide (llave del alcaide, mazmorra): acta del prisionero y +0.25 de daño (la empuñadura es una mejora encontrada, `mejora_encontrada.tscn`, P51). Dibujada en el ASCII (2026-11-06). Vuelta por `:B:` |
| Castillo | E1 (salto de unas 4,6 piezas) | Rodar, por reliquia en la biblioteca (hoy); en el plan, premio del Rey Caído (`ability_reward`); E2 en la armería (plan) | `[H2]` Rodar | 2. Aposentos de la Reina, al este de la capilla (llave del Caballero, minas): diario I y fragmento de vida 1/4. 3. El castillo sin hechizo (muerte de la Reina): soldados NPC en lugar de los Guardias y el Capitán al pie del trono. Las dos dibujadas en el ASCII (2026-11-06). Vuelta por `:C:` |
| Cementerio | E1 o E2; Rodar | Ráfaga, con el Capitán, guardián de la tercera tumba; E3 y la Agilidad (plan) | `[S3]` tres tumbas sello (la última, vencer al Capitán) | 4. Estatua de la Reina (Ultimate, mazmorra): fosa de los soldados y amuleto (+0.25 en pociones). 5. Cripta de la primera reina, bajo el mausoleo (Golpe final, minas, para la losa, y llama eterna, ruina, para las velas): corona y fragmento de vida 2/4. Las dos dibujadas en el ASCII (2026-11-06). Vuelta por `[S3]`, o por `:C:` y `[H2]` |
| Minas | Ráfaga; con E3, Agilidad (salto de unas 6,5 piezas) | Golpe final, con el Caballero (hoy); llave del Caballero | `[L4]` llave del Caballero | 6. Gruta de cristal, tras la boca de la pared este de la veta (Agilidad para el escalón y E5 para el fuego infernal): Crystal Mauler, que da la Adrenalina. Dibujada en el ASCII (2026-11-06). Vuelta por `:E:` y `:D:`, y la escalera 62 |
| Mazmorra | Golpe final | Ultimate, con la Reina (hoy); llave del alcaide (plan, en la torre, en (73, 21), donde iba un cofre) | `[!5]` derrumbe tras la Reina | 7. Pozo de los condenados, trampilla en el suelo de la huida, x 88-90 (palanca en la galería de los condenados de las profundidades): atajo `:F:`; los restos de los condenados y el diario II están al pie del pozo, abajo. Dibujada en el ASCII (2026-11-06). Vuelta por el propio `:F:` |
| Ruina helada | Ultimate | la llama eterna (pieza hecha, P65: objeto, hielo y luz; falta colocarla en el nivel); el dash en el aire, con el Guardián (plan; pieza hecha, P66, falta el `ability_reward` en la Fase 3); E4 (plan) | `[P6]` vencer al Guardián (reja de salida) y la llama eterna | 8. Hielo negro, cámara x 114-130 al este de la antesala, puerta en la columna 113 (ascua del Demon Slime, `profundidades_ascua`): diario III y fragmento de vida 3/4. Dibujada en el ASCII (2026-11-07). Vuelta por `:E:` |
| Profundidades | la llama eterna y el dash; E4 si se encontró | E5 (plan); ascua (`profundidades_ascua`), al vencer al Demon Slime, en el `PuntoLlave` de su sala (plan) | `[S7]` tres altares y el Demon Slime; con E5 se llega al altar rodeado de fuego | 9. Rey encadenado, jaula x 44-48, filas 16-19, en el techo de la galería de los condenados, con rejilla en la fila 20 (coliseo del infierno superado, `infierno_animas_liberadas`): el alma del Rey Caído (lore final) y fragmento de vida 4/4, en el suelo de la galería. Dibujada en el ASCII (2026-11-08). Vuelta por la escalera de `[S7]` y la escalera 68 |
| Infierno | E5 | — (superar el coliseo marca `infierno_animas_liberadas` y libera al rey de la idea 9) | — | — |

- **Mejoras de la tienda** (vida máxima, robo de vida, enfriamiento de la Ultimate): se compran con monedas en cualquier momento. Nunca son necesarias para avanzar (P35). La vida máxima queda en un solo nivel (de 4 a 5 corazones, por 10 monedas; aplicado en P47); el sexto sale de los 4 fragmentos de vida (sección 6).
- **Opcionales no obligatorios:** E2, E3 y E4 son premios por explorar. Ningún reto obligatorio puede pedirlos. Sí pueden pedirlos los secretos y los objetos opcionales: la Agilidad, los de las minas, la ruina y `tiles_jefe` (P45); el Abrigo, las zonas de frío. El dash, aunque no es de un atuendo, tampoco lo pide ningún reto obligatorio: solo sus secretos (sección 6).

### Arte de los atuendos (con IA)
Como los harapos (P42, "Sprites nuevos con espada"), el arte se genera con IA y se procesa con `herramientas/sprites/tira_ia_a_hoja.py`. Lo que importa es que todos se vean como el mismo personaje:
1. **Figura de referencia:** primero se genera y se aprueba una sola imagen del personaje con el atuendo, en pose `idle`. Todas sus tiras se piden a partir de ella.
2. **Poses de los harapos como guía:** cada animación se pide con la `original_ia.png` equivalente de los harapos de referencia. Así se repiten pose, número de cuadros y encuadre, y se procesa con las mismas opciones anotadas en P42.
3. **Mismas condiciones de tira:** fondo magenta, figura de perfil mirando a la derecha y de unos 120 px de alto, sin salirse mucho de su casilla.
4. **Mismas medidas de hoja:** 864x384 por cuadro, pie en la fila 380, centro en la columna 432 y escala 1/3. Así el cambio de atuendo no mueve la colisión ni la caja de la espada.
5. **Todas las animaciones de una vez:** `idle`, `run`, salto, `attack` / `attack 2`, `air attack`, `take hit`, `death`, `escaleras`, rodar y defensa, seguidas y con el mismo prompt base.
6. **Una carpeta por atuendo:** cada hoja con su `original_ia.png` al lado y un archivo con los prompts exactos usados, para poder regenerar.

### Implementación (en curso)
- **`GameManager`: hecho (P59).** `OUTFIT_DEFINITIONS`, `outfits_found`, `get_outfit_id()` (el de más nivel; con espada y sin atuendo, los harapos), `grant_outfit` y los rasgos (alcance, daño de tajo, reducción de daño, resistencias), combinados entre todos los encontrados; el Player los lee. `SAVE_FORMAT_VERSION` 5. Falta lo de abajo. Lo que seguía previsto:
  - un atuendo actual (`outfit_id` o nivel) y una tabla `OUTFIT_DEFINITIONS`, como `UPGRADE_DEFINITIONS`, con nombre, `SpriteFrames`, ajustes del arma, habilidad que da y resistencias;
  - `has_sword` se mantiene como "E1 o más";
  - se reinicia en `reset_for_new_game`, se guarda en la partida y se sube `SAVE_FORMAT_VERSION`.
- **Player:** un `SpriteFrames` por atuendo, como recurso aparte. Si falta una animación, se usa la del atuendo anterior. Hay que separar el Fire Knight de las tiras de E1, que hoy comparten `SpriteFrames` en `player.tscn`.
- **Objeto para recoger:** generalizar `escenas/objetos/espada_oxidada.tscn` en una escena de atuendo con `outfit_id` exportado.
- **Menú de pausa:** sección "Equipo".
- **E5 y el fuego infernal:** la resistencia `infernal_fire` ya la lee `fuego_infernal.tscn` (P61).
- **Probar** cada atuendo en la zona de pruebas antes de llevarlo a un mapa.

### Pendientes
- Confirmar que E2, E3 y E4 son opcionales y E5 obligatorio, o cambiarlo.
- Confirmar qué da exactamente cada atuendo (números de daño, alcance y resistencias) al jugarlo.
