# P37 - Menús y tipografía pixel

- Los dos menús se veían simples y no encajaban con el juego:
  - letra vectorial (la de Godot por defecto) escalada 3x, nada pixel;
  - marco y botones de madera de caricatura (`FantasyUIfree`), que no van con el cementerio gótico;
  - en la pausa, el marco nueve-parche se rompía, el texto se salía de los paneles, la barra de vida no se veía y los botones apagados usaban el estilo gris de Godot.
- Idea: un tema global en pixel que vista cualquier control del juego, y rehacer los dos menús encima de él.

## 1. Fuentes

- En `fuentes/`, importadas sin antialiasing, sin hinting y sin posicionamiento subpíxel:

  | Fuente | Uso | Tamaño | Licencia |
  |---|---|---|---|
  | Pixel Operator 8 (y Bold) | todo el texto | 8 (o 16) | CC0, Jayvee Enaguas; venía en `otra vez/brackeys_platformer_assets/fonts` |
  | Jacquard 12 | títulos y encabezados, góticos | 21 o 42 | OFL 1.1, Soft Type Project; licencia en `fuentes/OFL_Jacquard12.txt` |

- Las fuentes pixel solo se ven nítidas a múltiplos de su rejilla: **8 y 16 para Pixel Operator, 21 y 42 para Jacquard**. Otro tamaño deforma las letras.
  - Se cambiaron a 8 los que había en 5, 6, 9, 10, 11 y 12 (HUD, diálogo, barra de jefe). Quedan los 16 de los avisos de sala de jefe.
  - `DebugHUD` de `player.tscn` sigue en 5: está oculto y su panel no cabe a 8.
- Jacquard en mayúsculas no se lee; usarla en mayúsculas y minúsculas ("Underkingdom", "Pausa").
- Pixel Operator no tiene → ni ▶ ni ♥. El diálogo usa ahora "»". Para `º` (modo dev) y `↑` (HUD de depuración) queda el respaldo de fuentes del sistema.

## 2. Tema global

- `escenas/ui/tema_underkingdom.tres`, puesto en `gui/theme/custom` del proyecto. Todo `Control` lo hereda: HUD, diálogo, carteles, modo dev.
- Paleta: texto pergamino, ámbar de vela para foco y acento, bronce para bordes, fondo casi negro morado.
- Texturas pixel en `escenas/ui/texturas/`, dibujadas a mano por código y editables en cualquier programa de pixel art:
  - `marco_panel.png`: nueve-parche de 24 px con márgenes de 8 y remaches en las esquinas;
  - `marco_ranura.png`: marco del retrato;
  - `selector.png`, `casilla*.png`, `tirador*.png`, `adorno_linea.png`.
- Variaciones de tipo (`theme_type_variation`):

  | Variación | Base | Uso |
  |---|---|---|
  | `Titulo` | Label | Jacquard a 42, título del menú |
  | `Encabezado` | Label | Jacquard a 21, cabecera de la pausa y la tienda |
  | `TextoFuerte` / `TextoTenue` / `TextoAcento` | Label | negrita, gris, ámbar |
  | `BotonMenu` | Button | opción de lista sin caja; ámbar con foco |
  | `BotonPestana` | Button | pestaña con subrayado ámbar cuando está activa |
  | `PanelFila` / `PanelRanura` | PanelContainer | fila de lista y marco del retrato |

- Los `Label` llevan una sombra de 1 px por defecto para leerse sobre cualquier fondo.

## 3. Menú principal (`menu_principal.gd`)

- Cementerio de fondo, oscurecido por la izquierda y por abajo con degradados para que el texto se lea sin tapar la escena.
- Ánimas: `CPUParticles2D` de 2 px, celestes, que suben despacio.
- Título "Underkingdom" en Jacquard y un adorno debajo.
- Lista de texto con `UnderkingdomMenuSelector` (`scripts/ui/menu_selector.gd`): una flecha que se mueve con el foco y oscila 1 px. Pasar el ratón por un botón le da el foco, así teclado, mando y ratón marcan lo mismo.
- Opciones en el mismo sitio que la lista: volumen con porcentaje, pantalla completa y Volver. Esc o B vuelven.
- Fundido de entrada (0.6 s) y de salida antes de "Nueva partida" (0.35 s).
- "Continuar" sigue apagado y sin foco hasta que haya guardado.

## 4. Menú de pausa (`menu_pausa.tscn`, `pause_menu_overlay.gd`)

- Escena rehecha con contenedores: nada tiene posición fija dentro de los paneles y el texto ya no se sale.
- Panel izquierdo con tres pestañas. Con teclado o mando, moverse por ellas ya cambia de página.
  - **Datos**: retrato a 64 px (escala 1), nombre, barra de vida ("4 / 4", o "3.75 / 4" con cuartos), estado de la Ultimate, tabla de estadísticas y las habilidades de `ABILITY_DEFINITIONS`. Las que faltan salen como "???".
  - **Llaves**: una fila por llave con icono; las pendientes, apagadas.
  - **Mejoras**: monedas arriba y una fila por cada mejora de `UPGRADE_DEFINITIONS` (nombre, nivel, valor actual » siguiente, botón con precio). Las filas salen del diccionario: una mejora nueva aparece sola, y su texto se pone en `UPGRADE_TEXTS`.
- Panel derecho: Reanudar, Opciones, Menú principal y Salir con la misma flecha. Opciones se abre en el mismo panel.
- La tienda (`PauseMenu.open_shop`) pone el nombre del vendedor de cabecera y da el foco al primer botón de compra que se pueda pagar.
- B del mando vuelve de Opciones o cierra la pausa. Esc lo sigue gestionando `PauseMenu` con la acción `pause`.
- La API pública no cambió: `open_pause`, `open_shop`, `close_pause`, `is_pause_open`, `is_options_open`, `show_pause_menu`, `focus_resume`, `set_player`.

## 5. HUD

- El inventario muestra solo el número junto al icono ("12", "3  [C]"). Con la fuente pixel, "Pociones: 0 [C]" no cabía, y el icono ya dice qué es. El recuadro se estrechó.

## Pendiente

- Sonidos de mover y aceptar en los menús.
- Una pantalla de controles en Opciones, y la tecla o el botón según el dispositivo en la línea de ayuda.
- Pasar los textos fijos de los mapas (avisos de sala de jefe) a `Encabezado` para usar la letra gótica.
