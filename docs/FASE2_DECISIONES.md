# Fase 2: decisiones previas

Decisiones de diseño de las piezas de la Fase 2 (`TASK.md`) que los documentos no fijan. Se resuelven aquí, de una vez, para que las piezas se puedan hacer seguidas sin parar a preguntar. Cada una trae una propuesta. Lo que no se cambie se da por bueno.

**Estado: APROBADO** (cambiar a `Estado: APROBADO` al revisarlo; `herramientas/fase2_auto.sh` no arranca hasta entonces).

Reglas para el modo autónomo:
- Lo que diga este archivo manda sobre lo que el agente supondría.
- Si una pieza pide una decisión que no está aquí ni en P46, el agente elige la opción más conservadora y coherente con P46. Después la apunta al final, en "Decisiones tomadas durante la ejecución", con la alternativa y el porqué.
- Si una pieza no se puede terminar, se marca `- [~]` en `TASK.md` y el motivo se apunta al final, en "Piezas bloqueadas".

Hecha antes de este archivo: la pared agrietada (P48, commit `5c2c0b3`).

---

## 0. Generales

- **G1. Guardados viejos.** Al subir `SAVE_FORMAT_VERSION`, las partidas guardadas con la versión anterior dejan de cargar (`_validate_save_data` exige la versión exacta). Esta fase la sube al menos dos veces: con los fragmentos de vida y con los atuendos.
  **Propuesta:** se acepta. El juego está en desarrollo y no hay partidas que conservar. No se escribe migración.
- **G2. Orden.** El fuego infernal (paso 4) necesita saber si el jugador lleva E5.
  **Propuesta:** la pieza de atuendos "Atuendo actual y `OUTFIT_DEFINITIONS`" se adelanta al principio del paso 4, antes del fuego infernal. Las otras tres piezas de atuendos quedan al final.
- **G3. Textos provisionales.** Todos los mensajes nuevos van en mayúsculas, como los de `locked_door` ("NECESITAS UNA LLAVE"), y se exportan para poder cambiarlos por instancia.
- **G4. Arte provisional.** Si falta arte, se usa uno que ya exista en el proyecto y se apunta como pendiente en la etapa de `docs/`, como hizo P48.
- **G5. Tecla de interactuar.** Todo lo que se activa a mano usa la misma acción que `npc.gd` (E), con su mismo aviso flotante ("E  Tirar", "E  Leer"…).

## 1. Calabozo

### Palanca y barrera según `completed_encounters`
- **C1. Cómo se acciona.** **Propuesta:** con E, no a golpes. Así no se activa por error en mitad de un combate.
- **C2. Varias barreras.** Una palanca marca un `encounter_id`. Toda barrera con ese id, en esa escena o en otra, se abre al cargarse o en ese momento. Una palanca puede abrir varias.
- **C3. Aviso.** **Propuesta:** la palanca cambia de cuadro, hay una sacudida ligera (`shake()`, la de la pared) y un texto de marcador: "SE OYE UN MECANISMO". La cámara no se desplaza hasta la barrera.
- **C4. Barrera que se cierra desde un lado.** La palanca solo existe en el lado de abajo. Desde el otro lado la barrera se ve cerrada y no se puede abrir. No hace falta código extra para eso.

### Objeto de lore que abre un diálogo
- **C5. Releer.** **Propuesta:** el objeto se queda y se puede releer. La primera lectura se marca en `completed_encounters` (`lore_<id>`) para una futura pestaña de diario. Esa pestaña no se hace en esta fase.
- **C6. Formato.** Reutiliza `npc.gd` y `dialogue_ui` con su `.json` de líneas. Es una escena genérica, con el sprite exportado.

### Empuñadura: +0.25 de daño en todos los tajos
- **C7. A qué ataques afecta.** **Propuesta:** a los dos tajos con espada, al ataque aéreo y al golpe final del ascendente; no a los puñetazos ni a la Ultimate. Si el jugador recoge la empuñadura antes de tener espada (no debería poder), la mejora queda guardada y se aplica al tenerla.
- **C8. Cómo se guarda.** **Propuesta:** con una tabla genérica de "mejoras encontradas" en `GameManager` (`FOUND_UPGRADE_DEFINITIONS`, aparte de las de la tienda), que sirva también al amuleto. Se guarda en la partida, se reinicia en `reset_for_new_game` y sube `SAVE_FORMAT_VERSION`. Aparece en la pestaña de mejoras del menú de pausa como "encontrada", sin precio.

## 2. Castillo

### Reja baja que solo se pasa rodando
- **K1. Comportamiento.** **Propuesta:** la reja bloquea al Player si no está rodando. Rodando la atraviesa. Si la rodada acaba con el Player dentro de la reja, se le empuja hacia el lado del que vino. Los enemigos nunca la cruzan.
- **K2. Rodar sin espada.** No aplica: Rodar se consigue en el castillo y la reja está después.

### Mostrar u ocultar según un encuentro superado
- **K3.** Es un componente genérico con `show_when_encounter` y `hide_when_encounter`. Sirve para cualquier nodo: NPC, enemigo u objeto. Mientras el nodo está oculto, no colisiona ni procesa. `story_hidden_actor.gd` se queda como está o pasa a usar el componente, sin cambiar lo que ya hace en `mundo_1`.

### Fragmento de vida
- **K4. Al recoger.** **Propuesta:** el texto "FRAGMENTO DE VIDA n/4". Con el cuarto, la vida máxima sube 1 corazón (tope 6) y se llena la vida.
- **K5. Dónde se ve.** **Propuesta:** en la pestaña de estadísticas del menú de pausa, con el texto "Fragmentos de vida: n/4". No va en el HUD.
- **K6. Guardado.** Se guarda la lista de ids de los fragmentos recogidos, no solo cuántos hay, para que un fragmento no cuente dos veces. La vida máxima se calcula con las mejoras de la tienda más los fragmentos (P47).

## 3. Cementerio

### Contador de sellos
- **S1. Cómo se activa cada sello.** Escucha un `encounter_id` (la arena de la tumba 1, el Capitán de la tumba 3) o se activa con E al llegar a él (la tumba 2, tras las plataformas). Cada sello se configura por instancia.
- **S2. Aviso.** **Propuesta:** al activarse un sello, el sello se enciende, como cambio de cuadro, y sale el texto "SELLO n/3". Con el último sale "ALGO SE HA ABIERTO" y la puerta se abre aunque esté fuera de pantalla.
- **S3. Contador.** Cuenta los sellos de un grupo (`seal_group`) y abre las barreras que tienen ese grupo. Sirve igual para `[S3]` y para `[S7]`.

### Rompible que solo acepta un tipo de golpe
- **S4. Golpe equivocado.** **Propuesta:** no hace daño, sale un destello o chispa metálica y, la primera vez, el texto "RESISTE EL GOLPE".
- **S5. Vida.** **Propuesta:** se rompe con 1 golpe del tipo correcto.
- **S6. Raíz.** P48 vio que la AttackHitbox no detecta `StaticBody2D`. La estatua de la Reina usa `estatua_rompible.tscn`, así que la pieza le cambia la raíz a `AnimatableBody2D`, como la pared, y comprueba que `mundo_1` sigue igual. Si eso cambiara algo de `mundo_1`, se hace una escena aparte.

### `locked_door` con otro dibujo
- **S7. Cómo se abre.** Hoy `locked_door` se abre sola al acercarse con la llave. **Propuesta:** una exportación nueva, `require_interact`. Con ella, la puerta se abre con E delante. Las velas, el hielo de `[P6]` y el hielo negro la usan (la ruina ya dice "tecla E delante"); las puertas normales siguen abriéndose solas.
- **S8. Al abrirse.** **Propuesta:** las velas se encienden y la puerta se desvanece. El hielo se derrite: se desvanece hacia abajo con gotas o vapor si hay partículas a mano y, si no, con el `fade` que ya tiene.

### Amuleto: +0.25 en pociones
- **S9.** Las pociones pasan de curar 1.0 a curar 1.25. Usa la misma tabla de mejoras encontradas que la empuñadura (C8).

## 4. Minas

### Ascensor minero (`:C:`)
- **M1. Qué es.** `:C:` une dos escenas (el castillo y las minas), así que la cabina no recorre las 53 piezas dentro de una escena. **Propuesta:** hay una cabina en cada escena. El jugador sube a ella y pulsa E ("E  Subir" o "E  Bajar"). La cabina se mueve 1 s, la pantalla se funde y hace la transición al spawn de la cabina de la otra escena.
- **M2. Bloqueo.** Hasta tirar de la palanca de las minas, la cabina de las minas dice "NO HAY CORRIENTE". Del lado del castillo no se llega a la cabina, porque la trampilla está cerrada (C2).

### Fuego infernal (pide E5)
- **M3. Sin E5.** **Propuesta:** quita 0.5 de daño y empuja al Player hacia el lado por el que entró, con su invulnerabilidad de siempre. No mata de un golpe, pero insistir sí mata. Otras opciones: un muro sólido que no deja pasar, o un daño por segundo hasta morir.
- **M4. Con E5.** No hace daño ni empuja. Las `burn_zone` normales siguen igual: el Fire Knight solo resiste el fuego infernal, salvo que se decida otra cosa en A3.
- **M5. Enemigos.** No les afecta.

### IA del Crystal Mauler
- **M6. Base.** Usa `simple_boss.gd` con `attack_profiles`, como el Guardián: `1_atk`, `2_atk` y `3_atk` en la fase 1, y además `sp_atk` en la fase 2. `air_atk`, `defend` y `roll` no se usan en esta fase.
- **M7. Números.** **Propuesta:** 16 de vida (como el Guardián), contacto 0.5, tajos de 0.5 y `sp_atk` de 1.0. Es un jefe opcional al que se llega con E5, casi al final del juego.
- **M8. Escena.** Una escena heredada o rehecha en `escenas/jefes/` con `BossHealthBar`, a escala 1. Se prueba en la zona de pruebas con una cámara de 16 x 14 para comprobar que cabe.

### Adrenalina
- Sin decisiones: sale de `STARTING_ABILITIES` y la da el Mauler con `ability_reward adrenaline`.

## 5. Mazmorra

### Suelo que se hunde y derrumbe
- **Z1. Secuencia.** **Propuesta:** muere la Reina, la sala tiembla 1.5 s, el suelo se rompe a trozos y se cae. La trampilla de entrada queda tapada para siempre.
- **Z2. Huida.** **Propuesta:** sin tiempo límite. Mientras dura la huida, la cámara tiembla un poco y caen escombros del techo en sitios fijos, con un aviso de polvo antes de caer. Cada escombro quita 0.5. Otra opción: un frente de derrumbe que persigue al jugador y lo mata si lo alcanza.
- **Z3. Al volver.** El suelo sigue hundido y ya no tiembla nada. Se recuerda en `completed_encounters`.

## 6. Ruina

### Hielo, llama eterna y luz
- **R1. La llama.** Es un objeto que se recoge en el altar y da `grant_key("antorcha")`. Funciona sola: no hay que equiparla.
- **R2. La luz.** **Propuesta:** la parte oscura se oscurece mucho (con `CanvasModulate` o una capa negra) y, con la llama, el Player lleva una luz de unas 5 piezas de radio. Si a escala entera no queda bien, una máscara de oscuridad recortada alrededor del Player.

### Dash en el aire
- **R3. Botón.** **Propuesta:** el de rodar, pulsado en el aire. Rodar solo funciona en el suelo, así que no choca, y no hace falta tecla nueva.
- **R4. Números.** 112 px (7 piezas) en unos 0.18 s, sin gravedad, una vez por salto. Se recarga al tocar el suelo o una escalera. **Propuesta:** sin invulnerabilidad; la rodada sí la tiene y el dash no.
- **R5. Animación.** Provisional: la de rodar o el primer cuadro del salto, con estela si hay una a mano.

## 7. Infierno

### Arenas con oleadas
- **I1.** Es una pieza genérica: cada oleada es un nodo hijo con sus enemigos, desactivados hasta que la oleada empieza. Hay 1.5 s entre oleadas y una nube de humo (`death_puff`) al aparecer cada enemigo. Al vencer la última, se abren las barreras y se marca el `encounter_id`.
- **I2. Al morir.** La arena se reinicia entera: barreras abiertas, oleadas desde la primera.
- **I3.** El número de oleadas y los enemigos de cada una se deciden en la Fase 3, por instancia.

## 8. Atuendos

- **A1. Qué da cada uno, provisional** (P46 dice que se ajusta jugando):
  - E2, soldado: un 25 % más de alcance del tajo (`sword_hitbox_scale_x` 1.25). Da alcance y no daño, para no sumarse a la empuñadura.
  - E3, caballero de la cripta: la Agilidad y 0.25 menos de daño en los golpes de 0.75 o más, con un mínimo de 0.25.
  - E4, abrigo: inmunidad al frío. **Aviso:** hoy no existe el daño por frío y no está en la lista de la Fase 2. **Propuesta:** se deja el campo de resistencia preparado y la zona de frío se apunta como pieza que falta.
  - E5, Fire Knight: +0.25 de daño, alcance 1.25 e inmunidad al fuego infernal. La lava sigue matando.
- **A2. Menú "Equipo".** Lista los atuendos encontrados y lo que da cada uno, y marca el que se lleva puesto. No se cambia a mano (P46).
- **A3. Arte.** La pieza "Arte con IA de E2, E3 y E4" no se hace en modo autónomo: necesita generar imágenes y aprobarlas. Se deja sin marcar. Mientras tanto, cada atuendo usa el `SpriteFrames` del anterior.

---

## Decisiones tomadas durante la ejecución

(Las añade el agente: pieza, decisión, alternativa, por qué.)

- **Palanca y barrera (P49), dónde va la escucha del encuentro.** Decisión: una exportación `open_on_encounter` en `arena_barrier.gd`, vacía por defecto. Alternativa: una escena o un script hijo aparte, como `locked_door.gd`. Por qué: las trampillas y rejas de los atajos ya son `arena_barrier.gd` con piezas del tileset de cada nivel; así basta con rellenar un campo, también en `locked_door.gd`, y con el valor por defecto ninguna barrera existente cambia.
- **Palanca y barrera (P49), tamaño y arte.** Decisión: 1 x 2 piezas con origen arriba a la izquierda, como la pared agrietada; los ASCII dan la pieza del pie. Arte provisional: la lanza y la espada clavadas en un barril del tileset CC0 de la mazmorra. Alternativa: una sola pieza de 16 x 16. Por qué: es el único arte del proyecto que se parece a una palanca y ocupa 16 x 32.
- **Palanca y barrera (P49), palanca ya tirada.** Decisión: no se puede volver a tirar ni sale el aviso; la E vuelve a lanzar la Ultimate, como cuando no hay nada cerca. Alternativa: dejarla accionable sin efecto. Por qué: C2 dice que la palanca marca el encuentro una vez y no hay nada que cerrar de nuevo.
- **Empuñadura (P51), tabla y sitio de la mejora.** Decisión: `FOUND_UPGRADE_DEFINITIONS` solo lleva la empuñadura; el amuleto añade su fila en su pieza. El bono se suma en `Player._start_attack` para `attack`, `attack 2` y `air attack` (el golpe final entra por `attack 2`). Alternativa: sumarlo en cada llamada a `_start_attack` o crear las dos filas ya. Por qué: un solo punto, y la fila del amuleto sin código que la use sería una mejora que no hace nada.
- **Empuñadura (P51), recogida.** Decisión: el objeto hereda de `ability_pickup.gd`, que gana `_already_owned()` y `_grant()` como métodos a cambiar. Alternativa: duplicar el script de la reliquia. Por qué: evita duplicar el respaldo por distancia y el destello; la reliquia de habilidad se comporta igual.
- **Atuendo actual (P59), cómo se combinan los rasgos.** Decisión: alcance y reducción de daño toman el mayor de los atuendos encontrados, el daño de tajo se suma y las resistencias se unen; solo el aspecto y el nombre son del de más nivel. Alternativa: que cuente solo el atuendo que se lleva. Por qué: E2, E3 y E4 son opcionales y no se excluyen; con la alternativa, encontrar el abrigo (E4) quitaría el alcance del soldado y la reducción del caballero.
- **Atuendo actual (P59), atuendo sin recoger.** Decisión: `get_outfit_id()` devuelve `harapos` si hay espada y no se encontró ningún atuendo, y `desnudo` sin espada, en vez de guardar un `outfit_id` aparte. Alternativa: guardar `outfit_id`. Por qué: la espada se da por varias rutas (armería, modo dev, misión) y un dato derivado no puede quedar desincronizado.
- **Atuendo actual (P59), prueba a mano.** Decisión: opción "Siguiente atuendo" en el modo dev, porque el objeto de recoger es otra pieza. Alternativa: poner una escena provisional en la zona de pruebas. Por qué: evita una escena que habría que rehacer.
- **Ascensor minero (P60), cómo se mueve la cabina.** Decisión: la cabina no se desplaza; traquetea ±1 px y la cámara se sacude durante 1 s antes del fundido. Alternativa: mover cabina y Player por el pozo. Por qué: sin colisión propia el Player caería de la cabina que sube, y a escala entera un desplazamiento falso no aporta; el cambio de escena ya esconde el recorrido.
- **Ascensor minero (P60), spawn y fundido.** Decisión: la cabina crea su propio spawn y el fundido lo hace una capa colgada de la raíz, que sobrevive al cambio de escena. Alternativa: `SpawnPoint` suelto en cada mapa y fundido en `GameManager`. Por qué: no toca el autoload ni los mapas de la ruta, y un solo objeto lleva todo.
- **Fuego infernal (P61), forma y empuje.** Decisión: franja `Area2D` de piezas (origen arriba a la izquierda) que golpea con `take_damage` cada vez que acaba la invulnerabilidad, con el origen del golpe del lado contrario al de entrada. Alternativa: heredar de `burn_zone.gd` con tics. Por qué: M3 pide daño más empuje, y así no entra en el grupo `burn_zone`, que E5 no resiste.
- **Fuego infernal (P61), constructor.** Decisión: no se cambia el constructor; las `F` de los ASCII seguirán saliendo como trampas normales hasta la Fase 3, que las sustituye en la `_combate`. Alternativa: letra nueva en el constructor. Por qué: no tocar herramientas ni mapas ahora.
- **IA del Mauler (P62), escena.** Decisión: escena nueva `crystal_mauler.tscn` y `boss_mina.tscn` intacto. Alternativa: heredar de `boss_mina.tscn` o editarlo. Por qué: lo usa `mundo_2` (mapa viejo que no se modifica) y no tiene las tiras sueltas de ataque (`1_atk`, `2_atk`, `3_atk`, `sp_atk`).
- **IA del Mauler (P62), alcances.** Decisión: hitbox de cada ataque sacada de la caja opaca de los cuadros de golpe; el `3_atk` (132 px) y el `sp_atk` (140 px) son largos porque el dibujo lo es. Alternativa: acortarlos. Por qué: M6 no da números y P46 ya cuenta con 8,8 piezas hacia delante.
- **Adrenalina (P63), dónde se prueba.** Decisión: una `SalaMauler` (`boss_arena.gd`) nueva en la zona de pruebas, en el suelo x 45-60 (16 de ancho, como la gruta), con puerta de entrada, puerta de salida en `Atajos` y sin llave; el `CrystalMauler` suelto de P62 se queda para probar ataques. Alternativa: convertir ese Mauler en el jefe de la sala. Por qué: la sala cierra y abre y el suelto sirve para ver los golpes sin cerrarse dentro.
- **Derrumbe (P64), suelo propio y espera de la reliquia.** Decisión: el suelo es un `StaticBody2D` que construye la pieza, con una colisión por pieza, y `wait_for_ability` retrasa el temblor hasta recoger la reliquia de la Reina. Alternativa: quitar celdas de la capa `Terreno` generada, y no esperar. Por qué: quitar celdas toca las colisiones validadas y el constructor; y la reliquia flota (`ability_pickup.gd`), así que sin la espera se perdería sobre el hueco. En la Fase 3 el ASCII tendrá que dejar el hueco.
- **Derrumbe (P64), marcas.** Decisión: dos marcas en `completed_encounters`, `collapse_id` (suelo caído, huida en curso) y `collapse_id_huida` (terminada, al entrar en la zona de salida). Alternativa: una sola marca. Por qué: Z3 pide que tras volver no tiemble nada, y recargar a mitad de huida tiene que seguir con ella.
- **Derrumbe (P64), escombros.** Decisión: caen de uno en uno, por turno, en los puntos a menos de 240 px del Player; el aviso es polvo arriba durante 0.8 s. Alternativa: todos a la vez o al azar. Por qué: Z2 pide "sitios fijos con aviso"; por turno el ritmo es legible y no gasta escombros fuera de pantalla.
- **Llama eterna (P65), luz.** Decisión: la oscuridad es una capa propia por zona (`dark_zone.gd`, `ColorRect` con shader que deja un círculo claro en el Player, con el borde en 4 escalones y parpadeo de ±2 px), sin `CanvasModulate` ni luces 2D. Alternativa: `CanvasModulate` más `PointLight2D`. Por qué: `CanvasModulate` oscurecería la escena entera y solo admite uno por escena; la capa sirve a varias zonas y no toca el Player.
- **Llama eterna (P65), sin la llama.** Decisión: sin la llave la zona deja un halo de 20 px (`dark_radius`) en vez de oscuridad total. Alternativa: negro absoluto. Por qué: P46 hace que se llegue siempre con la llama, y así nadie queda atascado si se entra por otra ruta.
- **Llama eterna (P65), objeto.** Decisión: `llama_eterna.tscn` hereda de `ability_pickup.gd` (como el fragmento de vida), da la llave `antorcha` sin consumirse al usarla y se lista siempre en la pestaña de llaves como "Llama eterna". Alternativa: un objeto aparte con diálogo. Por qué: reutiliza la recogida y R1 dice que funciona sola.
- **Dash en el aire (P66), acción y arte.** Decisión: nueva `PlayerAction.AIR_DASH` (al final del enum, sin mover valores); no se puede empezar durante un tajo ni cubriéndose, y al acabar conserva la velocidad de caminar. Arte: la animación de rodar acelerada. Alternativa: dejar la velocidad del dash o permitirlo cancelando ataques aéreos. Por qué: R3 a R5 no lo fijan y lo conservador es no tocar el combate aéreo existente.
- **Dash en el aire (P66), zona de pruebas.** Decisión: el pasillo se pone a continuación del suelo que se hunde (x 1824-2144), con rectángulos de color y su reliquia en la entrada. Alternativa: sobre la zona del derrumbe o en el `.txt`. Por qué: el derrumbe ya ocupa x 1584-1824 a esa altura, y un `StaticBody2D` propio no toca el mapa generado.

## Piezas bloqueadas

(Las añade el agente: pieza, motivo, qué falta para seguir.)
