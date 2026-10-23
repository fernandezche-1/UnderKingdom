# Edwin visible sobre Underkingdom v4

Trabajo realizado en `prueba-integracion-edwin-047`, sin commit ni push.
Al comenzar, la copia estaba en `v4` y todos los cambios anteriores estaban
preparados en el índice. Las dos ramas apuntaban a `0437606`; se volvió a la
rama de prueba conservando el índice y el directorio de trabajo antes de editar.

Se compararon `v4`, `origin/edwin/integrar-0.04.047` (`3d456bd`) y la integración
efectiva del índice/directorio de trabajo. Como no se han creado commits, leer
solo el HEAD de la rama de prueba no representa el contenido integrado.
El video no estaba adjunto: la referencia visual fue el código de Edwin y P37.

## Comparación y ubicación del contenido

| Cambio | Estado anterior | Qué se puede observar ahora / dónde |
| --- | --- | --- |
| Tipografías y tema | Archivos presentes, sin aplicarse a los menús conservados | PixelOperator y Jacquard aplicados localmente al menú principal y a pausa. El HUD y los diálogos de prisión no reciben un cambio global de tema. |
| Menú principal | Aspecto de v4 | Título gótico, adorno, lista a la izquierda, sombra lateral, ánimas celestes, fundido de entrada y selector animado de Edwin. |
| Funciones de menú | Ya funcionales en v4 | Nueva partida, nombre, tres ranuras, continuar, eliminar con confirmación/cancelación, opciones, pantalla completa y salir conservan sus conexiones. Los botones de ranuras reconstruidos también heredan el nuevo tema. |
| Pausa | Funcional, presentación de v4 | Marcos y tipografía nuevos, botones de lista y pestañas adaptadas. Conserva Datos, Llaves, Mejoras, Poderes y Guardar. |
| Capacidades adicionales | Existían, sin estar listadas en Poderes | Rodar, parry, robo de vida y adrenalina son botones navegables en Pausa → Poderes. Desplazarse hacia abajo para ver toda la lista; seleccionar muestra el detalle real de GameManager. |
| Esqueleto | Escena sin instancia jugable | `tiles_cementerio_combate.tscn`, `Enemigos/EsqueletoEdwin`, posición `(440,454)`, primer recorrido inferior del cementerio. |
| Esqueleto enterrado | Escena sin instancia jugable | Mismo mapa, `Enemigos/TumbaEdwin`, `(1096,742)`. Se aproxima el jugador para despertarlo; permanece invulnerable enterrado. |
| Murciélago | Escena sin instancia jugable | Mismo mapa, `Enemigos/MurcielagoEdwin`, `(808,672)`, sobre el siguiente tramo del recorrido. |
| Capitán | Ya conectado | Arena del cementerio; recompensa `combo_2` → `attack_2`. |
| Caballero | Ya conectado | Arena de minería; recompensa `combo_3` → `attack_3`. |
| Reina | Ya conectada | Arena de mazmorra; recompensa Ultimate. No sustituye a la Reina del Agua ni su diálogo en prisión. |
| Guardián de Hielo | Arena conectada, sin recompensa aérea | Arena de ruinas; ahora suelta una reliquia `air_attack`, compatible con el fragmento del alma de v4. |
| Demon Slime / Cthulhu | Ya conectados | Arenas de profundidades y jefe, respectivamente. |
| Anciano | Ya instanciado | Cementerio, `Personajes/Anciano`, `(24,464)`. Acercarse y usar interacción; diálogo `npc_anciano_cementerio.json`. |
| Barquero y tienda | Ya instanciados y conectados | Cementerio, `(1704,1192)`, y otras arenas. Sale de la tierra, habla y abre la pestaña Mejoras existente. Tiene presentación y diálogo de visitas posteriores. |
| Ambiente y efectos | Ya conectados en parte | Ambientación del cementerio/minería; efectos de golpes, recogida, avisos de habilidades y cámara durante el combate. No se añadieron nuevas capas que dupliquen una ambientación ya existente. |

Los tres enemigos son adiciones en la escena heredada de combate: no se
eliminaron enemigos anteriores ni se modificaron tiles, plataformas, posiciones
originales o límites de los mapas. Las posiciones de tumba y murciélago proceden
de las colocaciones de Edwin; el esqueleto se colocó en el mismo piso existente
que sus enemigos vecinos, evitando superponerlo a una instancia anterior.
El balance y la accesibilidad física completa de esos tramos requieren recorrido.

## Progreso y narrativa conservados

Nueva partida sigue comenzando en Cámara del Sellado del Alma, con protagonista
personalizado, Reina del Agua y diálogo, cinemática y devolución del control.
No se ha cambiado el orden de escenas del prólogo: su salida conserva el destino
al cementerio. Escape del calabozo, interior y castillo editable siguen intactos.

La recompensa del Guardián utiliza `unlock_ability("air_attack")`, que modifica
el mismo estado de habilidades que `grant_soul_fragment`. No hay un segundo
inventario o sistema de estadísticas. Combo 2/3 y Ultimate conservan su traducción
al progreso de v4. Guardado y carga conservan el formato 1 y la lógica anterior.

Rodar ya estaba disponible en v4. Su reliquia del cementerio se retira al detectar
esa disponibilidad: no se bloquea una capacidad anterior para hacer aparecer una
recompensa redundante. El desbloqueo aéreo nuevo es una recompensa efectiva.

## Qué sigue excluido o no conectado por completo

- No se sustituyeron enteros los scripts de menú o pausa, sus escenas ni el
  sistema de perfiles. No se adoptó el segundo autoload DisplaySettings.
- No se aplicó el tema globalmente: la presentación de prisión y otras escenas
  queda protegida. El fundido de salida de Edwin no se conectó a Nueva partida,
  para conservar el flujo de confirmaciones y creación de perfil existente.
- No se reemplazaron todos los enemigos por la distribución completa de Edwin,
  ni se reactivaron las cavernas o el cementerio alternativo descartados antes.
- Los guardados antiguos que apuntan a un mapa base `tiles_*.tscn` conservan
  ese destino. Los contenidos añadidos a `*_combate.tscn` aparecen al entrar
  en esa variante. Para comprobarlos, usar una ranura nueva o viajar y regresar
  por las transiciones de combate. No se migraron automáticamente los guardados,
  sus claves de objetos consumidos o sus posiciones.
- Fuerza, Resistencia y mejora de poder de Llama Ancestral siguen sin implementar.
  El volumen sigue sin persistencia entre sesiones; pantalla completa sí persiste.
- Falta contraste directo con el video, que no estaba disponible en la conversación.

## Archivos de esta ampliación

- `scripts/ui/edwin_menu_style.gd`: presentación compartida, aplicada solo a menús.
- `escenas/menu/menu_principal.gd`: aplicación del estilo y herencia del tema para ranuras.
- `scripts/ui/pause_menu_overlay.gd`: estilo, lista de capacidades adicionales y
  detalle seleccionado. La estadística Ultimate ahora indica Bloqueada cuando corresponde.
- `escenas/mapas/tiles_cementerio_combate.tscn`: tres instancias nuevas de enemigos.
- `escenas/mapas/tiles_ruina_combate.tscn`: recompensa aérea del Guardián.
- `tools/validate_edwin_visibility.gd`: pruebas específicas de la ampliación.
- `tools/preview_edwin_menus.gd`: capturas con renderizado real, sin partidas reales.
- `tools/run_integration_validation.py`: modos `--visibility` y `--preview`, con
  registros separados para conservar la evidencia anterior.

El estado anterior preparado en Git no se sustituyó ni se volvió a preparar.
Los cambios nuevos quedan sin commit en la rama de prueba.

## Validación realizada

**75 comprobaciones específicas, cero fallos**, con datos temporales separados:

- Fuentes, tema local, adornos, selector, posición y conexiones de los botones.
- Tres perfiles, nueva partida en prisión, nombre y presencia de Reina/cinemática.
- Enemigos instanciados en cementerio, daño y protección del enterrado.
- NPC conectados, contenido de sus diálogos y apertura/compras de tienda.
- Pausa, cuatro pestañas, botones, pantalla completa y detalles de capacidades.
- Activadores que crean jefes reales y pasan a combate en cementerio, minería,
  mazmorra, profundidades y jefe.
- Caída y recogida de la reliquia aérea al completar la arena del Guardián;
  guardado/carga del desbloqueo en el sistema de v4.
- Continuar y eliminación con confirmación y cancelación tras los cambios visuales.

Las comprobaciones de recompensa completan la arena por su API; no afirman que
se haya ganado una pelea completa con teclado. Los activadores de las otras
cinco arenas sí se ejercitaron para comprobar aparición y estado de combate.

También se ejecutó Godot con **OpenGL y renderizado real** para capturar menú,
perfiles, pausa y Poderes. Las imágenes se inspeccionaron y se corrigieron el
ajuste de la guía de fragmentos y la navegación de las capacidades adicionales.

No se repitió la batería anterior de 300 comprobaciones ni la prueba independiente
del castillo, porque esta ampliación no modifica sus mapas, cinemática o colisiones.
Los resultados históricos permanecen en sus archivos originales.

Persisten advertencias conocidas de suelo seguro y MapBounds en las escenas
ejercitadas; no se ocultaron. No hubo errores de script o carga en las ejecuciones
finales de esta ampliación. Esto no sustituye el recorrido completo de la partida.

Evidencia:

- [Inventario comparativo y grafo de recursos](edwin_visibility_inventory.json).
- [Resultado de las pruebas específicas](edwin_visibility_validation.json).
- [Registro específico](integracion_edwin_047_visibility.log).
- [Resultado del renderizado](edwin_preview_validation.json).
- [Menú principal](edwin_preview_main.png), [perfiles](edwin_preview_profiles.png),
  [pausa](edwin_preview_pause.png), [Poderes](edwin_preview_abilities.png),
  [detalle de parry](edwin_preview_abilities_extra.png).

Para repetir solo cuando una modificación lo justifique:

```powershell
python tools/run_integration_validation.py "C:\Users\ferna\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --visibility
python tools/run_integration_validation.py "C:\Users\ferna\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" --preview
```

## Recorrido manual recomendado antes de v4

1. Usar una ranura nueva, poner nombre, terminar la prisión y entrar al cementerio.
2. Buscar Anciano y los tres enemigos en los tramos indicados. Probar interacción,
   despertar de la tumba, combate y legibilidad con el ambiente oscuro.
3. Completar las arenas de Capitán, Caballero y Reina; recoger sus recompensas,
   guardar y continuar. Comprobar puertas, llaves y ausencia de recompensas duplicadas.
4. Completar Guardián de Hielo en ruinas, recoger su reliquia y usar el ataque aéreo.
   Guardar/cargar y regresar para comprobar que el desbloqueo persiste.
5. Buscar Barquero, hablar de nuevo tras la primera compra y comprobar la tienda.
6. Navegar por todas las capacidades de Poderes con ratón, teclado y mando;
   revisar pausa, guardar, reanudar, opciones, volver al menú y salir.
7. Probar ventana/F11/pantalla completa y reiniciar; recorrer transiciones y
   reapariciones con advertencias; revisar también las escenas de escape y castillo.
