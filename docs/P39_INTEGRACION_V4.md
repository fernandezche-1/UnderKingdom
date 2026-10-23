# P39 - Integración de la rama v4 (0.04.048 y 0.04.049)

- Armando subió a `origin/v4` seis commits (19 a 22 de octubre) sobre `e151dc5`, el mismo punto del que salen nuestros 23 commits desde la 0.04.047.
- Se fusionaron en la rama `edwin/integrar-v4`. Lo que trae v4 está en `docs/CHANGELOG_0.04.048.md`, `docs/CHANGELOG_0.04.049.md` y los README de `escenas/mapas/prologo*/`.

## 1. Qué entra de v4

- **Prólogo:**
  - `prologo_prision/camara_sellado_alma.tscn`: cinemática con la Reina del Agua (`cinematica_prision.gd`).
  - Calabozo, interior del castillo y Castillo Oscuro (`escenas/mapas/prologo/`, `dark_castle_map.gd`).
  - Tres tilesets nuevos.
  - Son mapas hechos a mano, fuera de la ruta de tiles.
- **"Nueva partida" empieza en la prisión.** Su salida `SalidaPrision` lleva a `tiles_cementerio_combate`. El calabozo y el castillo todavía no están enlazados: según el README, la prisión debe salir a `escape_calabozo` cuando se validen.
- **Partidas guardadas** (`GameManager`):
  - 3 ranuras JSON en `user://saves` y nombre del personaje;
  - copia `.bak` al sobrescribir;
  - autoguardado al tocar un checkpoint, al entrar al cementerio y con casi cualquier cambio de progreso (monedas, pociones, llaves, jefes, encuentros, cinemáticas, habilidades);
  - guardar desde la pausa, solo si el Player está en el suelo, sin atacar y sin enemigos cerca.
- **Cofres:** el botín cae al suelo repartido y no reaparece.
- **Diálogo:** modo de un solo retrato para la cinemática, y el nombre del jugador en sus líneas.
- **Spawns seguros:** `map_spawn_controller.gd` no coloca al Player dentro de un sólido ni sobre el vacío. Si el punto no sirve, usa otro spawn.
- Se borran `cavernas_nuevas/` y `cementerio_redisenado/`. Ninguno estaba en uso.

## 2. Habilidades: se queda el sistema nuestro

- v4 traía otro sistema: "alma fragmentada", con `skill_unlocks`, `is_skill_unlocked` y `grant_soul_fragment`.
  - Solo cubría 5 habilidades: ataques 1 a 3, ataque aéreo y Ultimate.
  - Bloqueaba también al abrir un mapa directo.
- Se queda `unlock_ability` / `has_ability` (P35):
  - cubre las 8 habilidades (rodar, combo, tajo aéreo, parry, Ultimate, robo de vida, adrenalina);
  - ya tiene reliquias y premio de jefe;
  - con un mapa abierto directo, el Player tiene todo.
- La idea de Armando encaja como relato: en la prisión le fragmentan el alma, y eso es el bloqueo de "Nueva partida". Las reliquias y los jefes son los fragmentos que devuelven las habilidades.
- Cambios:
  - Se quitan el sistema de alma y las llamadas a `mark_soul_fragmented` de la cinemática.
  - El guardado usa `abilities_locked` y `abilities`. `SAVE_FORMAT_VERSION` pasa a 2, así que una partida guardada con v4 sale como "no compatible".
  - `unlock_ability` pide un autoguardado.
  - La mejora de enfriamiento de la Ultimate no se compra sin la Ultimate (`purchase_upgrade` y botón "Sin Ultimate").
  - La pestaña "Poderes" de la pausa no entra: la página de estadísticas ya lista las habilidades.

## 3. Otros conflictos resueltos

- **Pantalla completa:**
  - Queda nuestro `DisplaySettings` (`user://ajustes.cfg`, F11) y se quita `UserSettings`.
  - De este se toma el ajuste de la ventana: en pantallas pequeñas, al salir de pantalla completa, la ventana baja al mayor múltiplo entero de 480x270 que cabe.
- **Menú principal:** queda nuestro diseño (tema pixel, selector, fundido), con lo de v4 añadido:
  - "Continuar" y "Eliminar partida" se apagan si no hay partidas;
  - una pantalla de ranuras sirve para crear (nombre más ranura), continuar y eliminar;
  - la confirmación para reemplazar o borrar va dentro del menú, no en una ventana emergente.
- **Pausa:** botón "Guardar partida" (apagado sin ranura activa) y nombre del personaje en la cabecera.
- **`GameManager.gd` y `dialogue_ui.gd`:**
  - v4 los había pasado a tabuladores. Se fusionaron con su versión convertida a espacios, como estaban.
  - El diálogo de la prisión usaba letra de 9, 10 y 11: se quitó para que mande el tema (8).
- **`reset_for_new_game`** reinicia también `last_checkpoint_id`, `active_save_slot`, la restauración pendiente y el autoguardado pendiente.
- **`tiles_cementerio.tscn`:** en v4 solo se había reguardado desde el editor (uids y valores repetidos, sin cambios en tiles ni colisiones). Se queda el nuestro.
- **`player.gd`:** los cambios de v4 eran solo los bloqueos del alma. Se queda el nuestro.

## 4. Spawns seguros en los mapas con tiles

- Con la comprobación tal como venía, ningún spawn de nuestros mapas pasaba. Al entrar no se notaba, porque recurre al spawn pedido. Pero tras morir o al continuar una partida, el Player volvía a la entrada en vez de al checkpoint. Había tres causas:
  - Nuestros spawns dejan los pies justo sobre el suelo, y la consulta cuenta ese contacto como solape. Ahora se prueba 2 px más arriba (`SPAWN_SKIN`).
  - Un enemigo o una plataforma one-way sobre el punto lo volvían inseguro. Ahora solo cuenta la geometría fija (`_blocks_spawn`).
  - Al llegar con `change_scene`, en el primer frame de física los tiles aún no tienen colisión. Ahora se esperan dos frames.
- Ahora pasan todos los spawns y checkpoints de los seis mapas con tiles.
- Siguen sin pasar `mundo_1` (spawns metidos en la colisión dibujada a mano; recurre al spawn pedido) y `escape_calabozo`, cuyo spawn no tiene suelo debajo: el Player cae.

## Verificación

- Arrancan sin errores el menú principal, los seis mapas con tiles, el interior del castillo, el Castillo Oscuro y la prisión. Esta última solo avisa de que no tiene `MapBounds`.
- Prueba sin ventana del guardado:
  1. Se crea un perfil y la partida queda con habilidades bloqueadas.
  2. Se consigue `roll`, monedas y una llave, y se guarda en el Checkpoint2 del cementerio.
  3. Se reinicia la partida y se carga: escena, posición, habilidades, monedas y llave vuelven.
  4. Se guarda desde el juego y se borra la ranura.
  5. Las tres pantallas de ranuras del menú se construyen.
- La cinemática de la prisión corre sin errores hasta el primer diálogo. Falta jugarla con ventana.

## Pendiente

- Validar con ventana el prólogo y enlazar la prisión con `escape_calabozo` cuando Armando lo confirme. Antes hay que darle suelo a su spawn.
- El prólogo no sigue la regla de mapas con tiles (`CLAUDE.md`). Hablar con Armando si se rehace con el constructor.
- El campo de nombre (`LineEdit`) no tiene estilo en el tema global.
- Cada guardado sobre una ranura ocupada deja un `.bak` que no se limpia hasta borrar la ranura.
- Archivos sueltos de v4 en la raíz que habría que mover o quitar: `111.png`, `prsision.png`, `dark_castle_tileset.png`, `animated_sprite_2d.gd`, `escenas/mapas/antorhca.tscn`.
