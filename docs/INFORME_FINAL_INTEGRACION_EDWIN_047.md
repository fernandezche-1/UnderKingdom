# Informe final de integración de Underkingdom

> Informe histórico de la integración selectiva inicial. La ampliación visual y
> la recompensa aérea posterior se documentan en [EDWIN_CAMBIOS_VISIBLES.md](EDWIN_CAMBIOS_VISIBLES.md).

Rama: `prueba-integracion-edwin-047`. Base: `v4` en `0437606`.
Cambios de Edwin revisados: `origin/edwin/integrar-0.04.047` en `3d456bd`.

La integración selectiva de código y recursos queda finalizada en el directorio
de trabajo, pendiente de aceptación manual antes de llevarla a v4. No se hizo
commit, push ni cambio de rama. Los archivos nuevos siguen sin seguimiento y los
cambios anteriores preparados en el índice se conservaron.

Este cierre utiliza los resultados ya obtenidos. No se volvió a ejecutar Godot,
la batería de regresiones ni la auditoría automática. En este cierre solo se
consultaron el estado y los informes existentes y se añadió este documento.

## 1. Archivos de Edwin incorporados

Se incorporaron escenas de esqueletos y murciélago; reliquias; jefes y arenas;
Anciano y Barquero; diálogos; ambientación; efectos; controles por acciones;
modo de desarrollo; recursos de interfaz, fuentes y herramientas de mapas.
El apéndice contiene los nombres de los archivos del inventario inicial que
se incorporaron y siguen presentes, incluidos gráficos, licencias y metadatos.

Los siguientes archivos de v4 recibieron adaptaciones para conectar las novedades:

- `project.godot`: InputConfig y DevMode, conservando los autoloads de v4.
- `scripts/core/game_manager.gd`: API de habilidades compatible con sus fragmentos.
- `scripts/core/user_settings.gd`: F11 y notificación del estado de pantalla.
- `escenas/menu/menu_principal.gd`: sincronización de la casilla de pantalla completa.
- `scripts/ui/pause_menu_manager.gd` y `scripts/ui/pause_menu_overlay.gd`: tienda
  del Barquero sobre la pestaña de mejoras existente y compatibilidad de controles.
- `scripts/dialogue/dialogue_ui.gd`: avance por acciones, conservando la prisión.
- `scripts/items/collectible_pickup.gd`: efectos, conservando el botín persistente.
- `scripts/player/player.gd`: mejoras de combate, conservando los bloqueos de v4.
- `scripts/transitions/map_transition.gd`: controles nuevos y autosave existente.
- Mapas base de jefe, mazmorra, minería, profundidades y ruinas: únicamente
  destinos de transiciones hacia las nuevas arenas; sus diseños se conservaron.

No se adoptaron el reemplazo del menú, otro gestor de preferencias, los mapas
regenerados ni el cambio de significado de la mejora de robo de vida de Edwin.
El tema visual nuevo queda como recurso disponible, sin aplicarlo globalmente.

## 2. Funcionalidades originales de v4 conservadas

- Perfiles, nombre personalizado, tres ranuras, guardado, carga y autosave.
- Borrado con confirmación y cancelación; validación de guardados.
- Cámara del Sellado del Alma, cinemática y devolución de control al jugador.
- Escenas de escape del calabozo, interior del castillo y castillo oscuro editable.
- Controlador de aparición, restauración de posición y reaparición de v4.
- HUD, combate, llaves, inventario, mejoras, fragmentos y GameManager.
- Menú principal y pausa con sus señales, estadísticas y pestaña de habilidades.
- Geometría de los siete mapas base y capas persistidas del castillo.

El recorrido inicial de v4 sigue saliendo de la prisión hacia el cementerio.
Conservar las escenas de escape y castillo no implica que se haya creado una
nueva ruta narrativa que pase automáticamente por todas ellas.

## 3. Estado del menú principal y de pausa

| Función | Estado |
| --- | --- |
| Nueva partida y nombre personalizado | Conservados; comprobados automáticamente. |
| Continuar | Conservado; carga de perfil y progreso comprobada. |
| Borrar partida | Confirmación, cancelación y borrado comprobados. |
| Opciones | Conservadas. |
| Pantalla completa / ventana | Lógica y persistencia conservadas; F11 añadido. Falta comprobación visual en ventana real. |
| Preferencias | Pantalla completa persiste en `settings.cfg`. El volumen solo cambia durante la sesión. |
| Salir | Implementado y conservado; falta prueba interactiva desde ambos menús. |
| Pausa | Apertura, opciones y reanudación comprobadas. |
| Estadísticas, llaves, mejoras y habilidades | Interfaz y lógica de v4 conservadas. |
| Guardar desde pausa | Se conserva su conexión con el guardado de v4. |

No se reemplazó la escena `escenas/menu/menu_pausa.tscn` por la de Edwin.
La tienda nueva utiliza su pestaña de mejoras existente.

## 4. Compatibilidad de habilidades, reliquias y fragmentos

Hay un único estado para los ataques compartidos:

| ID de Edwin | Estado de v4 utilizado |
| --- | --- |
| `combo_2` | `attack_2` |
| `combo_3` | `attack_3` |
| `air_attack` | `air_attack` |
| `ultimate` | `ultimate` |

Las reliquias llaman a la API compatible de GameManager y actualizan las
habilidades de v4. Los fragmentos también se reflejan en la API nueva.
Se comprobó guardar y restaurar ese progreso manteniendo el formato de guardado 1.
Las arenas conectan recompensas de combo 2, combo 3 y Ultimate.

Rodar, parry, robo de vida y adrenalina mantienen su disponibilidad anterior.
La reliquia de rodar se retira sola porque esa capacidad ya está disponible.
El ataque aéreo conserva su bloqueo: no se encontró una recompensa colocada
para obtenerlo en el recorrido actual. Sus hooks existen, pero ese contenido
sigue pendiente. No se añadió un desbloqueo gratuito.

Las mejoras funcionales siguen siendo vida máxima, robo de vida y enfriamiento
de Ultimate, este último sujeto al desbloqueo de la habilidad. Fuerza,
Resistencia y mejora de poder de Llama Ancestral siguen sin implementar.

## 5. Errores y advertencias pendientes de Godot

Los resultados conservados de Godot 4.7.2 headless registran:

- **300 comprobaciones, cero fallos** en la batería de regresiones.
- Validación independiente del menú principal aprobada.
- Validación independiente del castillo editable aprobada: 34 816 píxeles
  sólidos idénticos y 16 plataformas físicas.
- Ningún error de script o carga en esas ejecuciones finales.
- Auditoría previa sin referencias literales faltantes ni conflictos Git pendientes.

Persisten **25 advertencias de suelo seguro** y **3 de MapBounds** en la ejecución
de regresiones. Son ocurrencias del registro, no necesariamente 28 problemas
distintos. No se ocultaron. Se verificaron los destinos y sus IDs, pero las
posiciones finitas no prueban que cada aparición sea la correcta.

No se afirma que el proyecto esté libre de cualquier error posible: las pruebas
headless no sustituyen el recorrido visual ni una partida completa.

Resultados y evidencia:

- [Resultados por ejecución](integracion_edwin_047_validation.json).
- [Registro de las 300 comprobaciones](integracion_edwin_047_regressions.log).
- [Registro del castillo](integracion_edwin_047_editable_castle.log).
- [Registro del menú](integracion_edwin_047_main_menu.log).
- [Auditoría y decisiones detalladas](INTEGRACION_EDWIN_047.md).
- [Inventario de cambios y conflictos](integracion_edwin_047_audit.json).

## 6. Qué probar manualmente antes de integrar a v4

1. Crear un perfil, escribir un nombre y terminar la cinemática de prisión.
   Confirmar cámara, nombre en diálogos, HUD, control y salida habilitada.
2. Guardar y continuar tras cerrar y abrir el juego. Comprobar inventario,
   llaves, mejoras, habilidades, posición y ausencia de repetición de la cinemática.
   Para probar un guardado real anterior, utilizar una copia de respaldo.
3. Recorrer todas las transiciones en ambos sentidos; comprobar aparición sobre
   suelo, ausencia de atascos y de retornos inmediatos involuntarios. Priorizar
   las escenas que producen advertencias de suelo y MapBounds.
4. Morir y reaparecer; comprobar checkpoint, posición y persistencia de objetos
   recogidos, llaves y encuentros completados.
5. Completar los combates de los jefes, recoger reliquias y verificar combo 2,
   combo 3 y Ultimate. Guardar, cargar y regresar a la arena para comprobar que
   las recompensas no reaparezcan indebidamente y las puertas sigan funcionando.
6. Hablar con Anciano y Barquero, abrir la tienda, comprar mejoras y volver al
   juego. Comprobar pausa, estadísticas, llaves y habilidades con teclado y mando.
7. Alternar pantalla completa/ventana desde opciones y F11, también en pausa;
   reiniciar para confirmar la preferencia. Revisar tamaño de ventana y monitor.
8. Revisar audio, HUD, retratos, luces, efectos y legibilidad. Abrir y editar
   los TileMapLayer del castillo; abrir las escenas de escape e interior.
9. Cancelar el borrado de una partida de prueba y confirmar que sigue disponible;
   después confirmar su borrado. Probar salir desde menú principal y pausa.

La aceptación para v4 queda pendiente de estas pruebas, especialmente de las
apariciones con advertencias. No se eliminaron archivos ni se reemplazaron
sistemas adicionales durante este cierre.

## Apéndice: lista nominal de archivos incorporados desde Edwin

Lista procedente del inventario existente, filtrada por archivos presentes.
Incluye archivos después adaptados, especialmente jugador y transiciones; no
implica que cada uno sea una copia literal de Edwin. Los adaptadores sobre v4
enumerados en el apartado 1 complementan esta lista.

```text
.gitignore
assets_prueba/gothicvania/ORIGEN.txt
assets_prueba/gothicvania/efectos/explosion_suelo.png
assets_prueba/gothicvania/efectos/explosion_suelo.png.import
assets_prueba/gothicvania/efectos/impacto.png
assets_prueba/gothicvania/efectos/impacto.png.import
assets_prueba/gothicvania/efectos/muerte_enemigo.png
assets_prueba/gothicvania/efectos/muerte_enemigo.png.import
assets_prueba/gothicvania/personajes/barquero_lampara.png
assets_prueba/gothicvania/personajes/barquero_lampara.png.import
assets_prueba/gothicvania/personajes/barquero_sale.png
assets_prueba/gothicvania/personajes/barquero_sale.png.import
assets_prueba/gothicvania_cementerio/ORIGEN.txt
assets_prueba/gothicvania_cementerio/esqueleto.png
assets_prueba/gothicvania_cementerio/esqueleto.png.import
assets_prueba/gothicvania_cementerio/fondo/cementerio.png
assets_prueba/gothicvania_cementerio/fondo/cementerio.png.import
assets_prueba/gothicvania_cementerio/fondo/cielo.png
assets_prueba/gothicvania_cementerio/fondo/cielo.png.import
assets_prueba/gothicvania_cementerio/fondo/montes.png
assets_prueba/gothicvania_cementerio/fondo/montes.png.import
assets_prueba/gothicvania_cementerio/tileset_cementerio.png
assets_prueba/gothicvania_cementerio/tileset_cementerio.png.import
assets_prueba/super_grotto/ORIGEN.txt
assets_prueba/super_grotto/murcielago.png
assets_prueba/super_grotto/murcielago.png.import
assets_prueba/super_grotto/recoger.png
assets_prueba/super_grotto/recoger.png.import
dialogues/barquero_otra_vez.json
dialogues/barquero_presentacion.json
dialogues/npc_anciano_cementerio.json
docs/P31_AMBIENTACION_OSCURIDAD.md
docs/P32_MODO_DEV.md
docs/P33_ENEMIGOS_POR_PROFUNDIDAD.md
docs/P34_ENEMIGOS_DE_LOS_PAQUETES.md
docs/P35_DESBLOQUEO_DE_HABILIDADES.md
docs/P36_PESO_DEL_GOLPE.md
docs/P37_MENUS_Y_TIPOGRAFIA.md
docs/P38_IA_DEL_CAPITAN.md
escenas/enemigos/esqueleto.tscn
escenas/enemigos/esqueleto_tumba.tscn
escenas/enemigos/murcielago.tscn
escenas/items/reliquia_habilidad.tscn
escenas/jefes/capitan.tscn
escenas/jefes/cthulhu_jefe.tscn
escenas/jefes/demon_slime_jefe.tscn
escenas/jefes/guardian_hielo.tscn
escenas/jefes/reina_jefe.tscn
escenas/mapas/tiles_cementerio_combate.tscn
escenas/mapas/tiles_jefe_combate.tscn
escenas/mapas/tiles_mazmorra_combate.tscn
escenas/mapas/tiles_mineria_combate.tscn
escenas/mapas/tiles_profundidades_combate.tscn
escenas/mapas/tiles_ruina_combate.tscn
escenas/npc/anciano.tscn
escenas/npc/barquero.tscn
escenas/ui/boss_health_bar.tscn
escenas/ui/dialogue_ui.tscn
escenas/ui/player_hud.tscn
escenas/ui/tema_underkingdom.tres
escenas/ui/texturas/adorno_linea.png
escenas/ui/texturas/adorno_linea.png.import
escenas/ui/texturas/casilla.png
escenas/ui/texturas/casilla.png.import
escenas/ui/texturas/casilla_marcada.png
escenas/ui/texturas/casilla_marcada.png.import
escenas/ui/texturas/casilla_marcada_off.png
escenas/ui/texturas/casilla_marcada_off.png.import
escenas/ui/texturas/casilla_off.png
escenas/ui/texturas/casilla_off.png.import
escenas/ui/texturas/marco_panel.png
escenas/ui/texturas/marco_panel.png.import
escenas/ui/texturas/marco_ranura.png
escenas/ui/texturas/marco_ranura.png.import
escenas/ui/texturas/selector.png
escenas/ui/texturas/selector.png.import
escenas/ui/texturas/tirador.png
escenas/ui/texturas/tirador.png.import
escenas/ui/texturas/tirador_foco.png
escenas/ui/texturas/tirador_foco.png.import
fuentes/Jacquard12-Regular.ttf
fuentes/Jacquard12-Regular.ttf.import
fuentes/OFL_Jacquard12.txt
fuentes/PixelOperator8-Bold.ttf
fuentes/PixelOperator8-Bold.ttf.import
fuentes/PixelOperator8.ttf
fuentes/PixelOperator8.ttf.import
herramientas/constructor_mapas/construir_mapa.gd
herramientas/constructor_mapas/tilesets/cementerio.gd
herramientas/constructor_mapas/tilesets/cementerio.gd.uid
scripts/bosses/captain_boss.gd
scripts/bosses/queen_boss.gd
scripts/bosses/queen_boss.gd.uid
scripts/bosses/simple_boss.gd
scripts/bosses/simple_boss.gd.uid
scripts/camera/bounded_camera.gd
scripts/combat/boss_arena.gd
scripts/combat/lunge_enemy.gd
scripts/combat/lunge_enemy.gd.uid
scripts/combat/rising_enemy.gd
scripts/combat/rising_enemy.gd.uid
scripts/core/dev_mode.gd
scripts/core/dev_mode.gd.uid
scripts/core/input_config.gd
scripts/core/input_config.gd.uid
scripts/environment/locked_door.gd
scripts/environment/map_ambience.gd
scripts/environment/map_ambience.gd.uid
scripts/fx/combat_fx.gd
scripts/items/ability_pickup.gd
scripts/items/ability_pickup.gd.uid
scripts/npc/merchant_npc.gd
scripts/npc/merchant_npc.gd.uid
scripts/npc/npc.gd
scripts/npc/npc.gd.uid
scripts/player/player.gd
scripts/transitions/map_transition.gd
scripts/ui/menu_selector.gd
scripts/ui/menu_selector.gd.uid
scripts/ui/player_hud.gd
```
