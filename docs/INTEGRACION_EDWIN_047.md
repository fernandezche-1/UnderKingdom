# Integración conservadora de Edwin sobre v4

> Estado histórico anterior a la ampliación visual. Consultar
> [EDWIN_CAMBIOS_VISIBLES.md](EDWIN_CAMBIOS_VISIBLES.md) para menús adaptados,
> enemigos conectados y recompensa aérea del Guardián.

Fecha: 22 de octubre de 2026. Rama de trabajo: `prueba-integracion-edwin-047`.

Base conservada: `v4`, commit `04376061ebaab1fbaa59fd77e7522f080b2410b8`.
Edwin revisado: referencia local `origin/edwin/integrar-0.04.047`, commit
`3d456bd20d8fc89a65c0f3ef2c73ca6cc97b00f0`.
Ancestro común: `e151dc547ff6a357a5ab4ec8a8dc2e08bc86b698`.

Se revisaron las referencias disponibles en el repositorio; no se hizo fetch.
No se hizo commit, push, eliminación de ramas ni cambio de `v4`. Esta es una
integración selectiva del contenido, sin crear un commit ni estado de merge.

## Trabajo existente protegido

La rama ya partía de `v4` y contenía 36 archivos preparados en el índice, relativos
al castillo editable, sus recursos, respaldos y herramientas. Se conservaron.
El índice no se reemplazó: los cambios de esta integración quedan en el directorio
de trabajo, junto a los nuevos archivos sin seguimiento. Las dos escenas de
respaldo del castillo conservan su contenido; únicamente se retiró su UID de escena
duplicado para evitar que compitieran con el castillo activo en el registro de Godot.

## Inventarios completos

- [Comparación, conflictos, dependencias y archivos del directorio de trabajo](integracion_edwin_047_audit.json).
- [Decisión inicial por archivo de Edwin](integracion_edwin_047_inventory.json).
- [Resultados ejecutables](integracion_edwin_047_validation.json).
- [Registro de regresiones](integracion_edwin_047_regressions.log).
- [Registro del castillo editable](integracion_edwin_047_editable_castle.log).
- [Registro del menú](integracion_edwin_047_main_menu.log).

El inventario inicial registra adiciones, modificaciones y eliminaciones de Edwin
respecto del ancestro común. La auditoría añade la comparación directa entre las
dos ramas y la lista final de cambios. Los adaptadores manuales y las decisiones
posteriores se explican abajo; el inventario inicial no representa por sí solo
el resultado final de cada archivo.

## Conflictos encontrados y decisiones

Diez archivos fueron modificados por ambas ramas. Una combinación textual de tres
versiones detecta conflictos en nueve. No hay entradas de Git sin resolver.

| Archivo | Resolución |
| --- | --- |
| `project.godot` | Mantener escena inicial, versión, resolución y autoloads de v4. Añadir InputConfig y DevMode. UserSettings sigue siendo el único gestor de preferencias. |
| `escenas/menu/menu_principal.gd` | Mantener construcción del menú, perfiles, nombre, continuar y confirmación de borrado de v4. Añadir sincronización de la casilla al usar F11. |
| `escenas/menu/menu_pausa.tscn` | Conservar íntegra la escena de v4: botones, guardar, estadísticas, llaves, mejoras y habilidades. |
| `scripts/ui/pause_menu_overlay.gd` | Conservar conexiones y lógica de v4. Añadir apertura de la tienda desde el NPC, sincronización de pantalla completa y disponibilidad de compras del modo de desarrollo. Mostrar correctamente el estado de Llama Ancestral sin fingir una mejora de poder. |
| `scripts/core/game_manager.gd` | Conservar guardado, restauración, autosave, nombre, inventario, llaves, mejoras, historia y fragmentos de v4. Añadir API de compatibilidad para las recompensas de Edwin. |
| `scripts/player/player.gd` | Incorporar controles por acciones, mejoras del combo, impacto, cámara y soporte del modo de desarrollo, conservando las restricciones de habilidades de v4. |
| `scripts/dialogue/dialogue_ui.gd` | Mantener nombres personalizados, retratos y presentación especial de prisión de v4. Admitir avance mediante la acción compartida de teclado/mando. |
| `scripts/items/collectible_pickup.gd` | Mantener botín persistente y animación de salida del cofre de v4. Añadir efecto de recogida después de registrar correctamente la recogida. |
| `escenas/mapas/tiles_cementerio.tscn` | Conservar la escena de v4, sin reemplazar TileMapLayer, geometría, objetos ni posiciones. Integrar novedades en la escena heredada de combate. |

El décimo archivo común, `scripts/transitions/map_transition.gd`, es combinable
textualmente: se incorporó la interacción por acción manteniendo el autosave
de entrada al cementerio y sus datos de spawn de v4.

### Incompatibilidades funcionales que Git no resuelve

1. **Dos progresiones para los mismos ataques.** Edwin usa `combo_2`/`combo_3` y v4
   `attack_2`/`attack_3`. La nueva API los traduce al diccionario de habilidades
   de v4. `air_attack` y `ultimate` también usan ese estado. No hay dos estados
   de desbloqueo que puedan desincronizarse. Los guardados mantienen formato 1.
2. **Desbloqueos iniciales distintos.** Se conserva la fragmentación de v4. Rodar,
   parry, robo de vida y adrenalina conservan su disponibilidad previa. La reliquia
   de rodar se retira sola porque esa capacidad ya está disponible.
3. **Pantalla completa duplicada.** No se añadió el autoload DisplaySettings de
   Edwin ni se migraron las preferencias a `ajustes.cfg`. UserSettings conserva
   `settings.cfg`, ajuste de tamaño de ventana y persistencia; ahora admite F11
   incluso en pausa y notifica a las casillas del menú.
4. **Escenas de pausa incompatibles.** Se adaptó la tienda del Barquero a la pestaña
   de mejoras existente, sin reemplazar la escena ni quitar Guardar/Habilidades.
5. **Mapas regenerados.** Se conservaron los siete mapas base `tiles_*`. Solo se
   actualizaron destinos de transiciones para acceder a las nuevas escenas de
   combate. La auditoría compara el contenido completo después de normalizar
   exclusivamente esos destinos y confirma que el resto coincide con v4.
6. **Reaparición y consultas físicas.** Se conserva íntegro el controlador de
   aparición de v4 y sus comprobaciones de posición guardada, suelo y respaldo.
   Las advertencias de posiciones sin suelo seguro se mantienen visibles;
   no se suprimen ni se reubican marcadores para ocultarlas.
7. **Mejora de robo de vida con semántica diferente.** Se conserva el valor y
   escalado de curación de v4; no se sustituye por la reducción de daño requerido
   que propone Edwin. Esto evita cambiar el significado de mejoras ya guardadas.

## Funcionalidades conservadas y nuevas

| Funcionalidad | Estado real |
| --- | --- |
| Nueva partida y nombre personalizado | Implementados; inicio en Cámara del Sellado del Alma. |
| Continuar y borrar con confirmación/cancelación | Implementados, con tres ranuras y validación de datos. |
| Opciones, salir, ventana/pantalla completa | Implementados. F11 se añade como atajo. |
| Preferencias persistentes | Pantalla completa persiste. El volumen se modifica durante la sesión; su persistencia no estaba implementada y no se simula. |
| Pausa, guardado desde pausa, estadísticas, llaves, mejoras y pestaña de habilidades | Conservados. |
| Prisión y recuperación de control | Cinemática, nombre en diálogos, HUD, cámara y desbloqueo de salida conservados. |
| Escape, interior del castillo y castillo oscuro editable | Escenas conservadas; el castillo usa capas persistidas, no se reemplaza por generación en ejecución. |
| Guardado, carga, autosave y respawn | Se mantiene la lógica y formato de v4. |
| HUD y combate | Se añaden avisos de habilidad, efectos de recogida, hitstop y temblor de cámara, controles por acciones y mejoras del combo. |
| Jefes y recompensas | Capitán actualizado; nuevas escenas de Reina, Guardián de Hielo, Demon Slime y Cthulhu, con arenas heredadas. Recompensas de combo 2, combo 3 y Ultimate conectadas al progreso de v4. |
| NPC y tienda | Anciano y Barquero, diálogos y tienda en la pestaña de mejoras existente. |
| Nuevos enemigos y ambientación | Escenas de esqueletos y murciélagos, scripts, gráficos, luces y ambientación incorporados. No se reemplazaron en bloque los enemigos o diseños de los mapas base. |
| Tema y tipografías de Edwin | Recursos disponibles. No se aplica globalmente su diseño porque reemplazaría la presentación funcional de v4. |
| Modo de desarrollo | Disponible en compilaciones debug, con opciones desactivadas inicialmente. |

Se conservaron los archivos eliminados por Edwin si existían en v4, incluidos
respaldos y recursos. No se aplicó una limpieza destructiva del proyecto. Las
cavernas y el cementerio alternativos que v4 había eliminado desde el ancestro
común no se reactivaron: no forman parte de las nuevas arenas integradas.

## Funciones que siguen pendientes

- Mejoras de Fuerza, Resistencia y poder de Llama Ancestral: la interfaz ya
  indica que no están implementadas. Solo funcionan vida máxima, robo de vida
  y enfriamiento de Ultimate cuando la habilidad está desbloqueada.
- El ataque aéreo conserva el bloqueo de v4 y sus hooks de fragmentos. No se
  encontró una recompensa colocada que lo desbloquee en el recorrido actual.
  No se añadió un desbloqueo gratuito para ocultar ese pendiente.
- La integración mantiene las ubicaciones originales de enemigos de los mapas
  base; el reemplazo por todas las colocaciones nuevas de Edwin queda diferido
  porque exigiría revisar y alterar el diseño de los mapas.

## Validación reproducible

Motor utilizado: Godot 4.7.2 estable para Windows, en modo headless.

```powershell
python tools/audit_integration.py
python tools/run_integration_validation.py "C:\Users\ferna\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
```

El ejecutor crea una copia temporal con un nombre de aplicación único. Los
guardados, preferencias, compras y eliminaciones de las pruebas se realizan
en ese espacio separado; no utiliza partidas reales. El script GDScript rechaza
ejecutar pruebas de guardado si no detecta ese espacio aislado.

La importación del editor se ejecutó también sobre el proyecto real. Los primeros
intentos detectaron un error de indentación del adaptador de recogida y UIDs
duplicados en respaldos del castillo; ambos se corrigieron. El arnés de pruebas
se ajustó para cargar clases de juego después de inicializar autoloads y para
reconocer los spawns generados por WorldTestRoute en mapas de prueba antiguos.

Los resultados finales, número de comprobaciones y advertencias pendientes se
registran en `integracion_edwin_047_validation.json` y en los registros enlazados.

Resultado final: **300 comprobaciones, cero fallos** en regresiones, más las
ejecuciones independientes del menú principal y del castillo editable aprobadas.
Las comprobaciones incluyen carga de scripts/escenas/recursos y comportamiento;
no equivalen a 300 recorridos manuales completos.

Se verificaron nueva partida, nombre personalizado, cinemática completa y
recuperación de control, pausa/opciones/reanudación, apertura de tienda, mejoras,
guardado/carga, traducción de recompensas al progreso de v4, daño a jugador y
a ocho escenas de enemigos/jefes, HUD, destinos de transiciones y confirmación/
cancelación de borrado. También se verificó que el esqueleto enterrado rechaza
daño antes de despertar y lo recibe después.

El castillo conserva **34 816 píxeles sólidos idénticos, 16 plataformas físicas**,
atlas válidos, capas persistidas y ausencia de colisiones duplicadas. La auditoría
no encuentra recursos literales faltantes ni UIDs de scripts duplicados.

La ejecución de regresiones todavía registra **25 advertencias de suelo seguro**
y **3 advertencias de MapBounds**. No son errores de sintaxis ni se han ocultado.
Los destinos y sus IDs existen, y las posiciones observadas son finitas, pero
esto no demuestra que cada punto elegido por el respaldo sea el correcto.
La validación manual de ubicación de apariciones sigue pendiente.

## Pruebas manuales y riesgos pendientes

- Comprobar pantalla completa y modo ventana en una ventana real, tamaños,
  monitor y reinicio de la aplicación. Headless comprueba llamadas, archivo y
  sincronización de controles, pero no el comportamiento visual del monitor.
- Revisar presentación, audio, legibilidad del HUD, retratos y efectos de combate.
- Recorrer de ida y vuelta todas las transiciones con teclado y mando, y revisar
  puntos de aparición, colisiones y puertas durante una partida completa.
- Jugar los encuentros completos de cada jefe y comprobar balance, acceso a
  recompensas y visibilidad bajo las luces nuevas. Cargar una arena y aplicar
  daño no sustituye una pelea completa.
- Abrir y editar las capas del castillo en el editor. La validación automática
  comprueba que siguen siendo TileMapLayer con tiles y colisiones persistidas.
- Probar salir desde menú y pausa en una ejecución interactiva.
- El flujo inicial conservado de v4 sale de la prisión hacia el cementerio.
  Escape del calabozo, interior del castillo y castillo oscuro siguen disponibles
  con sus conexiones; no se ha afirmado ni creado un recorrido narrativo nuevo
  que pase automáticamente por todas esas escenas desde Nueva partida.

Esta integración no afirma haber terminado esos recorridos visuales o completado
las mecánicas pendientes indicadas arriba.
