# P41 - Cinemática inicial

- "Nueva partida" pasa ahora por una cinemática de ilustraciones narradas antes de la prisión: menú → `escenas/cinematica/cinematica_inicial.tscn` → `prologo_prision/camara_sellado_alma.tscn`.
- `menu_principal.gd` sigue llamando a `GameManager.reset_for_new_game()` y `create_new_profile` antes de salir. Solo cambia la escena a la que salta (`NEW_GAME_SCENE`). `GAME_SCENE` se queda porque es el fondo del menú.
- "Continuar" no la repite: la partida guardada arranca en la prisión. Tampoco se guarda nada en la cinemática; quien cierre el juego durante ella continúa en la prisión.

## 1. Recursos

- Están en `assets/cinematica/`: 16 ilustraciones y `narracion_reina.mp3`.
- El audio llegó como `.mp3.mpeg`, que Godot no importa. Es el mismo archivo con la extensión cambiada.
- **Tamaños:** las 10 primeras miden 1672x941 (16:9) y llenan la pantalla. Las 11 y 12 miden 360x248, y de la 13 a la 16, 360x338: no son 16:9.
- `STRETCH_KEEP_ASPECT_CENTERED` las muestra enteras, con barras negras a los lados. `STRETCH_KEEP_ASPECT_COVERED` cortaba cabezas y coronas de las seis últimas.
- Son ilustraciones, no sprites del juego: su escala no es entera. Llevan filtro Nearest y no se mueven, así que no hay parpadeo.

## 2. Escena

- `FondoNegro`, `Ilustracion`, `Fundido`, `FondoOmitir`, `Omitir` y `Voz` (bus Master).
- `Omitir` usa la variación `TextoTenue`, sin overrides. Es gris y sin sombra, así que lleva detrás la franja `FondoOmitir` para leerse sobre las imágenes claras.
- Omiten `ui_accept` y `ui_cancel`: Espacio, Enter, Esc y los botones A y B del mando. El menú de pausa no captura Esc porque aquí no hay Player.
- Al omitir o al acabar: fundido a negro, la voz baja a la vez y se salta a `next_scene_path`.

## 3. Tiempos

- Un solo audio de 100.2 s. Los cortes salen de una transcripción con sus marcas de tiempo y caen dentro de una pausa de la voz.
- El reloj es la posición del audio, así que un tirón no desfasa imagen y voz. Si no hay voz, o al terminar, sigue un reloj propio.
- Cada imagen cambia en el segundo de "Empieza", a mitad de un fundido de `fade_time` (0.35 s por lado). Las pausas de la voz duran entre 0.4 y 1 s: un fundido más largo pisaría la frase.
- **Para afinar:** cambiar `duration` en `slides`, al principio de `cinematica_inicial.gd`. Si un corte se mueve, restar lo mismo a la diapositiva siguiente para no desplazar las demás.

| # | Imagen | Empieza | `duration` | Narración |
|---|---|---|---|---|
| 1 | `01_castillo_en_paz` | 0.00 | 6.60 | Hace muchos años existió un reino donde la paz y la prosperidad parecían eternas. |
| 2 | `02_rey_y_primera_reina` | 6.60 | 7.60 | Gobernado por un rey justo y su amada esposa, el reino prosperó bajo la protección de la corona. |
| 3 | `03_enfermedad_de_la_primera_reina` | 14.20 | 7.90 | Pero incluso los días más brillantes conocen su final. Una enfermedad arrebató la salud de la reina. |
| 4 | `04_funeral_de_la_primera_reina` | 22.10 | 7.20 | Su muerte dejó un vacío en el corazón del monarca y sumió al reino en un profundo luto. |
| 5 | `05_guerra_y_asedio` | 29.30 | 5.45 | Sus enemigos aprovecharon aquella debilidad. La guerra regresó, |
| 6 | `06_princesa_cautiva` | 34.75 | 6.60 | consumiendo ciudades y arrebatando incontables vidas. Tras años de sufrimiento, |
| 7 | `07_matrimonio_por_la_paz` | 41.35 | 4.55 | una nueva unión prometió devolver la paz a aquellas tierras. |
| 8 | `08_reina_ayuda_al_pueblo` | 45.90 | 4.10 | La nueva soberana pronto se ganó el cariño de su pueblo. |
| 9 | `09_reina_y_los_prisioneros` | 50.00 | 4.80 | Su generosidad parecía anunciar una nueva era de esperanza. |
| 10 | `10_magia_prohibida` | 54.80 | 3.85 | Sin embargo, detrás de las puertas del castillo, |
| 11 | `11_poder_del_agua` | 58.65 | 4.75 | un poder desconocido comenzaba a alterar el destino de la corona. |
| 12 | `12_rey_bajo_control` | 63.40 | 9.25 | Con el paso del tiempo, la voluntad del rey comenzó a desvanecerse, mientras la autoridad de su esposa se volvía absoluta. |
| 13 | `13_guerrero_enfrenta_reina` | 72.65 | 8.95 | Cuando la tragedia alcanzó al rey, su guardián más fiel levantó su espada contra la soberana, pero fue derrotado. |
| 14 | `14_guerrero_acusado` | 81.60 | 7.65 | Despojado de su honor, el guerrero fue acusado de traición ante aquellos a quienes había jurado proteger. |
| 15 | `15_guerrero_encadenado` | 89.25 | 5.85 | Su nombre fue condenado al olvido, su espada le fue arrebatada, |
| 16 | `16_despertar_en_la_mazmorra` | 95.10 | 6.60 | y en las profundidades del castillo su destino parecía sellado. (Lo que sobra tras el fin del audio, 1.5 s, deja la imagen en silencio.) |

## Pendiente

- Validar los cortes escuchándolos en una ventana. La transcripción es automática: los tiempos están medidos, pero el reparto de las diapositivas 6 y 9 es una interpretación, porque ninguna frase las nombra.
- Sin música ni efectos: solo voz.
- Las imágenes 11 a 15 traen de origen un borde claro de 1 píxel a la derecha o abajo, que se nota junto a las barras negras. No se retocaron.
