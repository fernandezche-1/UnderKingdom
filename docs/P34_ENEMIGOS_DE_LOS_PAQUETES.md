# P34 - Enemigos y arte de los paquetes nuevos

- Llegaron paquetes nuevos de Ansimuz, todos CC0:
  - Legacy Collection (Gothicvania);
  - Super Grotto Escape;
  - Gothicvania Cemetery.
- Esta etapa los usa en el orden acordado:
  1. murciélago;
  2. esqueletos;
  3. efectos de muerte e impacto;
  4. la Reina como jefe de la mazmorra;
  5. tileset del cementerio;
  6. jefes de ruina, profundidades e infierno;
  7. NPC con los que se habla y el mercader.
- Cada paquete se descomprime fuera del proyecto. Solo se copia lo que se usa, con su `ORIGEN.txt` en `assets_prueba/<paquete>/`.

## 1. Murciélago (`m`)

- **Arte:** Bat de Super Grotto Escape, 5 cuadros de 48x48, en `assets_prueba/super_grotto/murcielago.png`. Se ve de frente, así que no hace falta girarlo.
- **Escena:** `escenas/enemigos/murcielago.tscn`.
- **Script nuevo:** `scripts/combat/lunge_enemy.gd` (`UnderkingdomLungeEnemy`), que extiende `enemy_base.gd`. Es para criaturas sin animación de golpe:
  - el ataque se queda quieto un momento como aviso (`lunge_windup`);
  - luego se lanza hacia el torso del Player (`lunge_speed`, `lunge_duration`);
  - solo hace daño durante el impulso;
  - los voladores se lanzan también en vertical; los de suelo frenan antes de un borde.
- **Valores:**
  - 1,5 de vida: dos golpes del primer tajo, o uno del tercero más otro;
  - ¼ de corazón de daño, cada 1,4 s;
  - vuela a la altura del torso del Player (`fly_target_offset_y = 34`);
  - lo detecta a 190 px.
- **Letra `m`**, color `#402060`, en `COLORS` / `ENEMIES` del constructor. Se dibuja en la pieza donde flota. Se regeneraron la paleta y la tabla de `LEYENDA.md`.
- **Dónde está** (coordenadas en piezas):
  - **Cementerio:** cripta (50, 42) y (73, 42); abismo (60, 66) y (95, 66).
  - **Minas:** los dos huecos de la veta ardiente que dejó P33, (58, 79) y (80, 78); galería alta (62, 23); galería media (88, 38).
- **Comprobado sin ventana:**
  - frente al Player en un suelo de prueba: se acerca, se queda a la altura del torso, avisa, se lanza y quita ¼ de corazón; un golpe de 0,75 le deja 0,75;
  - tras regenerar el cementerio y las minas, solo cambian los nodos de `Enemigos` y los identificadores internos (tileset, `unique_id`), como en P33;
  - las dos escenas `_combate` cargan, y tras 3 s de física los 4 murciélagos de cada mapa siguen donde se dibujaron.

## 2. Esqueletos (`e` y `u`)

- **Arte:** el esqueleto de Gothicvania Cemetery, de 44x52 por cuadro, con su animación de salir de la tierra y la nube de muerte del mismo paquete.
  - Los cuadros sueltos se juntaron sin cambiar el arte en `assets_prueba/gothicvania_cementerio/esqueleto.png`, una fila por animación (ver su `ORIGEN.txt`).
  - Se descartó el esqueleto de Super Grotto Escape que proponía el plan: es cabezón y de estilo tierno, y no pega con el resto. Además tampoco trae animación de golpe.
- **Las dos escenas usan la embestida del murciélago** (`lunge_enemy.gd`), porque el arte no trae golpe: avisan 0,35 s, se lanzan 57 px y solo dañan durante el impulso.
  - Valores comunes: 3 de vida, ½ corazón de daño cada 1,6 s, patrulla lenta.
  - Muerte con la nube del paquete (animación `death`).
- **`escenas/enemigos/esqueleto.tscn` (`e`):** camina desde el principio. Va en la mazmorra y la ruina.
- **`escenas/enemigos/esqueleto_tumba.tscn` (`u`), con ropa:** usa el script nuevo `scripts/combat/rising_enemy.gd` (`UnderkingdomRisingEnemy`).
  - Mientras duerme se ve solo un montículo de tierra. No se mueve, no recibe daño y está en la capa 0: el Player lo atraviesa y su ataque no lo detecta.
  - Cuando el Player llega a 85 px en horizontal y 60 px en vertical, sale de la tierra hacia él. Sigue siendo invulnerable mientras se levanta.
  - Va en el cementerio.
- **Dónde están** (piezas):
  - **Cementerio (`u`):**
    - superficie (18, 29), junto al inicio, para enseñar la mecánica, y (95, 29);
    - cripta (68, 47);
    - catacumbas (49, 56);
    - abismo (70, 75).

    Ninguno está en la sala del jefe.
  - **Mazmorra (`e`):** (38, 33), (45, 40) y (68, 69).
  - **Ruina (`e`):** (42, 20), (14, 39) y (85, 56).

  Todos van sobre suelo llano de 6 piezas o más, con tres filas libres encima y sin pinchos ni lava. Donde se pudo, junto a monedas o cofres, que ya se sabe que se alcanzan.
- **Comprobado sin ventana:**
  - frente al Player, el esqueleto se acerca, embiste y quita ½ corazón;
  - el de tumba lejos del Player sigue dormido 7 s y rechaza un golpe; cerca, sale de la tierra y pelea;
  - tras regenerar, cementerio, mazmorra y ruina cargan, y los 11 esqueletos siguen sobre el suelo a los 3 s (los de tumba, dormidos).

## 3. Efectos de muerte, impacto y recogida

- **`scripts/fx/combat_fx.gd` reproduce efectos con sprites** con `play_sprite(origen, nombre, posición)`.
  - Cada efecto de `SPRITE_FX` es una hoja horizontal con el tamaño de cuadro y su velocidad.
  - Se reproduce una vez, colgado de la escena, y se borra solo.
  - Las `SpriteFrames` se arman una vez y se guardan en caché.
- **Impacto** (`impacto`, Hit de la Legacy, 3 cuadros de 31x32): una chispa en el centro del enemigo cada vez que un golpe del Player hace daño. Sale de `hit_flash`, que ya se llamaba desde `player.gd`, así que no hubo que tocar al Player.
- **Muerte** (`muerte`, EnemyDeath de la Legacy, 8 cuadros de 48x48): fogonazo y humo. Sustituye a la nube de partículas de `death_puff`, que solo usan los enemigos sin animación de muerte (hoy el murciélago). Los que tienen la suya la siguen usando.
- **Recoger** (`recoger`, pick-feedback-2 de Super Grotto, 5 cuadros de 16x16): destello al recoger una moneda o una poción, desde `collectible_pickup.gd`.
- Los archivos están en `assets_prueba/gothicvania/efectos/` y `assets_prueba/super_grotto/recoger.png`, anotados en sus `ORIGEN.txt`.
- La explosión en el suelo de la Legacy (Ground Explosion) queda para los golpes fuertes de los jefes (paso 6).
- **Comprobado sin ventana:**
  - la chispa, el fogonazo del murciélago y el destello de la moneda aparecen y a los 2,5 s ya no queda ninguno;
  - el menú, Mundo 1 y el cementerio arrancan sin errores.

## 4. La Reina, jefa de la mazmorra

- **Escena del mundo:** `escenas/mapas/tiles_mazmorra_combate.tscn` hereda de la generada `tiles_mazmorra.tscn`, como la del cementerio y la de las minas.
  - Las minas llevan ahora a esta escena: línea `siguiente` del `.txt` y `target_scene_path` del `.tscn`, sin regenerar.
  - La salida izquierda de la ruina vuelve a ella de la misma forma.
- **Sala:** la cámara del fondo a la derecha, x 54-76, filas 53-69.
  - Su única entrada es el hueco de x 60-62 en la fila 52, por donde baja la escalera.
  - No se dibujó ni se quitó ninguna colisión. La sala se cierra con una trampilla horizontal en ese hueco (`TrampillaEntrada`, `arena_barrier.gd`), que solo existe mientras dura el combate.
  - Activador: el suelo de la cámara (filas 63-69).
  - La Reina sale en el extremo más lejano al Player: (56, 69) o (74, 69).
  - La llave cae en el centro.
- **Puerta con llave:** `PuertaLlave` (`locked_door.gd`, llave `mazmorra_reina`) tapa la salida derecha, columna 76, filas 5-11.
  - El punto de llegada desde la ruina queda en la columna 75, del lado de dentro.
  - Este mundo es un calco y no baja: la salida está arriba, no en lo más hondo. Queda pendiente rehacer el trazado como en los dos primeros.
- **El esqueleto de (68, 69)**, que quedaba dentro de la sala, pasó a (66, 51).
- **`escenas/jefes/reina_jefe.tscn`** hereda de `enemigos/reina.tscn` (Water Priestess). Lleva 14 de vida, `BossHealthBar` "LA REINA" y `counts_as_world1_boss = false`. La Reina enemiga de los mapas viejos no cambia.
- **Script `scripts/bosses/queen_boss.gd`** (`UnderkingdomQueenBoss`), que extiende el del Capitán.
  - Hereda las fases, el roll, el anti spam y la Ultimate con aviso: la Reina ya tenía animaciones con esos nombres.
  - Cambia las ventanas de golpe, medidas por el alcance del dibujo en cada cuadro:
    - attack basic: 2-3;
    - attack: 3-6;
    - attack2: 2-4 y 14-17;
    - attack rapido: 2-4, 14-17 y 20-26;
    - ultimate: 12-31.
  - Daño:
    - ½ corazón con el tajo corto y la ráfaga, por golpe;
    - ¾ con los otros dos ataques;
    - 1½ con la Ultimate.
  - Las animaciones de la Reina enemiga eran muy lentas para un jefe. Se aceleran solo en una copia propia de sus cuadros.
  - Suma el tajo corto (`attack basic`) al azar de ataques.
  - **Curación:** al entrar en fase 3 se cura 2 corazones una vez, con su animación `curacion`. Si el Player la golpea mientras se cura, la pierde.
- **Comprobado sin ventana:**
  - frente al Player, la Reina usa los cinco ataques, rueda, se defiende y se cura;
  - en el mapa:
    - la puerta con llave sigue cerrada sin llave;
    - al bajar a la cámara se cierra la trampilla y la Reina aparece en el extremo más lejano;
    - al vencerla se abre la trampilla y la sala queda completada;
    - la llave cae, se recoge y abre la puerta de la salida;
  - la mazmorra, las minas y la ruina arrancan sin errores.

## 5. Tileset y fondo del cementerio

- **Tileset nuevo `cementerio`** (`herramientas/constructor_mapas/tilesets/cementerio.gd`), con atlas `assets_prueba/gothicvania_cementerio/tileset_cementerio.png`:
  - filas 0-15: el atlas de mazmorra sin cambios, por las antorchas, la lava, la escalera y la fogata del checkpoint;
  - filas 16-19: piezas del tileset de Gothicvania Cemetery copiadas en el orden del juego de 4x4:
    - pasto arriba;
    - tierra con calaveras en paredes y techos;
    - interior oscuro;
    - plataformas de pasto;
  - decorados: `T` pasa de árbol a lápida (stone-1, 2x3), `g` a puntas de pasto y `r` a zarzas secas. No hubo que tocar el PNG del mapa.
- **Colisiones:** el constructor deduce la colisión de cada pieza por la opacidad de sus esquinas, y el Cemetery trae muchas piezas con bordes redondeados y transparentes.
  - Solo se usaron piezas macizas, así que cada bloque sigue siendo un cuadrado completo.
  - Se comprobó volcando el polígono de colisión de cada celda de `Terreno` y `Plataformas` antes y después de regenerar: las 4261 celdas son idénticas.
- **Parallax:** el pueblo nocturno se cambió por el cielo con luna, las montañas y el cementerio del paquete (`assets_prueba/gothicvania_cementerio/fondo/`). Cada capa va en un lienzo de 224 px alineada abajo, como el pueblo.
  - Sigue pendiente que el cielo no se vea dentro de las cuevas: el constructor pone un solo parallax por mapa.
- `tiles_cementerio.txt` usa `tileset: cementerio` y `bloques: cementerio`.
- **Comprobado:**
  - captura de pantalla con el juego abierto: pasto, lápidas y el fondo nuevo se ven bien;
  - el cementerio carga y los 22 enemigos siguen en su sitio a los 3 s;
  - las colisiones no cambiaron.

## 6. Jefes de la ruina, las profundidades y el infierno

### Script genérico `scripts/bosses/simple_boss.gd` (`UnderkingdomSimpleBoss`)

- Es para arte con pocos ataques. Cada animación de ataque tiene su perfil en `attack_profiles`:
  - cuadros de golpe;
  - daño;
  - tamaño y posición del golpe;
  - fase mínima;
  - cuadro de la explosión en el suelo.
- **Fase 2**, por debajo de la mitad de vida:
  - ataca un 25 % más rápido;
  - persigue más rápido;
  - espera menos entre ataques;
  - puede pasar a volar (`phase_2_flies`).
- **Explosión en el suelo:** el efecto Ground Explosion de la Legacy (`assets_prueba/gothicvania/efectos/explosion_suelo.png`) aparece delante del jefe y hace daño en un área. No sale mientras vuela.
- **Armadura durante el ataque:** un golpe del Player le quita vida pero no le corta el ataque ni lo empuja. Fuera del ataque recibe el golpe normal. Sin esto se le podía interrumpir cada golpe.
- No usan la animación de daño, para que no se les pueda aturdir sin fin; el golpe se ve con el destello y la chispa.
- Las escenas se generaron desde las hojas de sprites que ya estaban en el repo, sin tocar el arte.

### Jefes

| Jefe | Escena | Vida | Ataque | Fase 2 |
|---|---|---|---|---|
| Guardián de hielo (Frost Guardian, sin usar hasta ahora) | `escenas/jefes/guardian_hielo.tscn` | 16 | Manotazo, cuadros 6-8, 1 corazón | Explosión en el suelo (¾) |
| Demon Slime | `escenas/jefes/demon_slime_jefe.tscn` | 18 | Tajo, cuadros 9-11, alcance 126 px, 1 corazón | Explosión en el suelo (1) |
| Cthulhu (jefe final) | `escenas/jefes/cthulhu_jefe.tscn` | 20 | Dos golpes: ¾ (cuadros 2-5) y 1 con explosión (cuadros 3-6) | Vuela y persigue al Player en el aire |

- La escena enemiga `enemigos/demonslime.tscn` y el `jefes/boss.tscn` viejo de Cthulhu no cambian.

### Salas

Todas son cámaras que ya existían en los calcos. Se cierran con trampillas y rejas (`arena_barrier.gd`) que solo existen durante el combate, sin dibujar ni quitar colisiones.

- **Ruina** (`tiles_ruina_combate.tscn`):
  - la cueva de abajo a la derecha, x 65-102, filas 46-56;
  - única entrada en x 67-69, fila 43 (trampilla);
  - puerta con llave en la salida derecha, columna 102, filas 22-24;
  - el esqueleto que quedaba dentro, en (85, 56), pasó a (86, 27).
- **Profundidades** (`tiles_profundidades_combate.tscn`):
  - la cámara de abajo a la derecha, x 81-102, filas 43-51;
  - dos entradas: trampilla en x 97-102, fila 42, y reja en la columna 81, filas 47-51, junto a la escalera;
  - puerta con llave en la salida derecha, columna 102, filas 33-37.
- **Infierno** (`tiles_jefe_combate.tscn`):
  - no hay cámara cerrada de buen tamaño, así que la pelea es en el pasillo central, entre rejas en las columnas 46 y 74, filas 30-39;
  - desde el suelo del pasillo (fila 40) el Player salta unos 104 px y no alcanza las plataformas de la fila 29, así que las dos rejas bastan;
  - no hay llave: es el final, y al vencer sale "HAS VENCIDO A CTHULHU".
- **Ruta:** cada mapa apunta ahora a la escena `_combate` del siguiente y del anterior. Se cambió en los `.txt` y en `target_scene_path`; la ruina se regeneró por el esqueleto.

### Comprobado

- **Frente al Player en un suelo de prueba**, los tres atacan y hacen daño. Con la armadura, el ataque sigue aunque los golpeen. Pasan a fase 2: el Guardián y el Demon Slime levantan la explosión en el suelo, y Cthulhu se pone a volar.
- **En cada mapa:**
  - la puerta con llave sigue cerrada sin llave;
  - al entrar en la sala se cierran sus puertas y el jefe aparece en el extremo más lejano;
  - al vencerlo se abren y la sala queda completada;
  - la llave cae, se recoge y abre la salida;
  - en el infierno, la pelea termina sin llave.
- Los cuatro mapas `_combate` de la mazmorra en adelante cargan y sus enemigos siguen en su sitio a los 3 s.
- Capturas de pantalla con el juego abierto de las tres peleas: tamaño de los jefes, rejas y barra de jefe correctos.
- **Pendiente de jugar a mano:** la dificultad de cada jefe y la posición exacta de las rejas.

## 7. Personajes con los que se habla y el Barquero

- **`scripts/npc/npc.gd` (`UnderkingdomNPC`)**, un `AnimatedSprite2D` del grupo `interactable`, como el cofre.
  - Con el Player cerca muestra "E  Hablar". Con E abre su diálogo: un JSON de `dialogues/`, con el mismo formato que las cinemáticas, y sus líneas con `speaker_id` "friend" sin retrato.
  - Mientras habla, el Player queda quieto e invulnerable (`set_controls_locked`, `cinematic_invulnerable`).
  - Tras cerrar el diálogo, la misma E no lo vuelve a abrir (espera 0,4 s).
  - Mira hacia el Player.
  - Las subclases deciden qué pasa al terminar (`_after_dialogue`).
- **`scripts/npc/merchant_npc.gd` (`UnderkingdomMerchantNPC`): el Barquero.**
  - Es la Muerte con lámpara de la Legacy (`assets_prueba/gothicvania/personajes/`, cuadros de 32x48).
  - Está enterrado hasta que el Player se acerca y entonces sale de la tierra con su animación.
  - La primera charla de la partida es su presentación (`dialogues/barquero_presentacion.json`); después dice una línea corta (`barquero_otra_vez.json`). Lo recuerda con `GameManager.mark_cinematic_seen("barquero_presentado")`, que "Nueva partida" ya reinicia.
  - Al terminar de hablar abre la tienda: el menú de pausa en la pestaña Mejoras, con "EL BARQUERO" como título (`PauseMenu.open_shop`). Las mejoras se siguen pudiendo comprar desde el menú de pausa como antes.
- **El anciano** (`escenas/npc/anciano.tscn`, el elder de Lively NPCs) está en la superficie del cementerio, a la izquierda del inicio, en (1, 29). Da pistas: la tierra removida (esqueletos de tumba), los murciélagos que se quedan quietos antes de lanzarse y el Barquero.
- **Barqueros:** uno junto a la puerta con llave de cada mundo, del lado de dentro. Están en el nodo `Personajes` de cada escena `_combate`:
  - cementerio (106, 75);
  - minas (89, 85);
  - mazmorra (73, 11);
  - ruina (99, 24);
  - profundidades (98, 37).
- **Aviso de la puerta con llave** (`locked_door.gd`): sale hacia el lado del Player. Antes se centraba en la puerta y, con las puertas junto al borde del mapa, quedaba cortado.
- **Comprobado:**
  - sin ventana y con la tecla E simulada:
    - el Barquero sale de la tierra, muestra "E Hablar", su diálogo bloquea al Player, y al terminar se abre la tienda pausada con título "EL BARQUERO" y la pestaña Mejoras;
    - la compra descuenta 5 monedas y al cerrar se reanuda;
    - el anciano habla y no abre la tienda;
  - captura con el juego abierto del Barquero y el aviso de la puerta;
  - el menú, Mundo 1 y los cinco mapas `_combate` arrancan sin errores.
