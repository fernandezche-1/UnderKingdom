# Sistema de audio de UnderKingdom

Godot 4.7 · Rama de desarrollo `v4-6ex`

## Arquitectura

`GameAudio` es un Autoload que carga los WAV a demanda, conserva las preferencias del usuario y administra la mezcla. El proyecto asigna el recurso de buses mediante `audio/buses/default_bus_layout`. Las escenas notifican acciones que el juego ya ha aceptado. Los parámetros de movimiento, daño, IA, colisiones, mapas, guiones narrativos, sprites y animaciones se mantienen.

| Bus | Contenido |
| --- | --- |
| `Master` | Volumen general y limitador nativo con techo de −1 dB. |
| `Musica` | Temas de escenas, arenas y jefes. |
| `Efectos` | Movimiento, combate, proyectiles y elementos interactivos del mundo. |
| `Ambiente` | Fondos continuos por zona, como viento, agua, fuego, hielo y resonancia de mazmorra. |
| `Dialogos` | Vocalizaciones digitales de texto y narración existente de la introducción. |
| `Interfaz` | Foco, confirmación, cancelación, pausa, reanudación e interruptores. |

Los cinco buses de categoría pasan por `Master`. El sistema reserva hasta 24 voces posicionales con `AudioStreamPlayer2D` y cinco voces no posicionales de interfaz. La cámara activa determina la escucha. La distancia máxima de los efectos posicionales es 760 px. Una caché de muestras, intervalos mínimos por evento y emisor, exclusión de sonidos fuera de alcance y ganancias con margen limitan el coste y la superposición. Las ráfagas de proyectiles comparten el aviso de lanzamiento.

Música y ambiente disponen de dos `AudioStreamPlayer` nativos por bus. Los cambios de zona y la entrada o salida de un combate cruzan las ganancias durante 1,15 s. Las pistas mantienen su posición al entrar a otra escena de la misma zona si el tema ya está activo. Una arena con un jefe tiene prioridad sobre las oleadas. La pausa mantiene el ambiente, la música y la interfaz disponibles. Los efectos posicionales de juego siguen la pausa.

Menú principal y pausa exponen seis barras de volumen. El valor cero silencia su bus. Las preferencias se guardan en `user://audio.cfg`, aparte de los perfiles de partida y los ajustes de pantalla. Salir desde los menús guarda cualquier cambio pendiente y permite que el mezclador retire las reproducciones activas.

## Integración por sistema

| Sistema | Conexiones realizadas |
| --- | --- |
| Locomoción del jugador | Pasos y carrera al cambiar a los cuadros de apoyo de `run` y detectar desplazamiento real en suelo. Salto cuando se aplica el impulso y aterrizaje al recuperar contacto desde una caída. Rodada al entrar en la acción. Escaleras sincronizadas con sus cuadros. El desarmado alternativo usa distancia trepada cuando carece de esa animación. |
| Espada y guardia | Puñetazo, tajo, ascendente, Golpe final y tajo aéreo al abrir su ventana de daño. Ráfaga cambia la afinación del tajo. Sonidos distintos al cubrirse, bloquear, romper guardia y confirmar parry. Daño, muerte y reaparición responden a sus respectivos eventos. |
| Habilidades y resistencia | Aviso al desbloquear habilidades, entrada en Adrenalina, dash aéreo, curación efectiva de robo de vida, poción usada y reducción por armadura. Los atuendos con resistencia tienen un aviso de adquisición. Fire Knight produce un aviso al cruzar fuego infernal una vez por tramo. El abrigo ya otorga resistencia al frío y el repositorio carece de un evento de daño por frío al que conectar otro sonido. |
| Fuego del jugador | La bola suena al preparar el gesto, salir en el cuadro de liberación y tocar un cuerpo. Ultimate tiene aviso de inicio, bucle ligado a la acción desde la primera ventana, acentos en los cuadros activos 10, 12 y 14 y una cola al finalizar. El bucle termina al perder la acción por golpe, reaparición, muerte, cambio de equipo o salida de escena. |
| Enemigos comunes | Las ventanas reales de los ataques cuerpo a cuerpo, la liberación de ataques a distancia y las señales de daño y muerte disparan muestras por material y afinación de criatura. Hay perfiles por familia sonora para blindaje, hueso, bestias, alas, espíritus, criaturas viscosas y demonios. Las flechas y bolas de fuego tienen salida e impacto propios. |
| Jefes y oleadas | Avisos de entrada y cambios de fase conectados a las arenas y a `phase_changed`. El Capitán, la Reina y el Caballero de la Reina tienen tres fases existentes. Los jefes de dos fases conservan las dos. Hay avisos específicos para la Ultimate del Capitán y la Reina, la descarga y lluvia del Caballero, la curación de la Reina y las explosiones de los jefes que las ejecutan. Las oleadas tienen aviso de comienzo y señal de victoria. |
| Cinemáticas y diálogo | El prólogo emite señales para el ritual y las cadenas en las secuencias existentes. La introducción conserva su MP3 y su reloj de reproducción y recibe un acompañamiento instrumental a −21 dB. Los JSON de diálogo permanecen intactos. La interfaz común revela el texto progresivamente y reproduce pulsos digitales solo en grupos de letras reveladas. Cada identidad dispone de timbre, tono y duración propios mediante cuatro muestras base y sus variaciones. Avanzar, cerrar o liberar la escena corta el pulso. Los controles y las pausas narrativas existentes conservan su funcionamiento. |
| Escenarios | Fondos para Prisión, Calabozo, Castillo, Cementerio, Minas, Mazmorra, Ruina, Profundidades, Infierno y la zona de pruebas. El catálogo cubre también los mapas históricos identificados y asigna a las muestras de la galería el ambiente de la región que presentan. Los cofres, las palancas, las barreras, los puntos de control, el ascensor, el derrumbe y varios recogibles emiten señales posicionales. |
| Interfaz | Foco de botones y barras, activación y cancelación, entrada y salida de pausa y muestra de ajuste. Los controles conservan la navegación existente por teclado, mando y ratón. |

El nombre del hablante distingue personajes que comparten el identificador genérico `friend`. El Guerrero se identifica por `player` aunque el perfil cambie su nombre. Las vocalizaciones son ondas breves sintetizadas. El MP3 existente corresponde a la narración de apertura.

## Archivos y procedencia

| Ruta | Función |
| --- | --- |
| `audio/administrador.gd` | Autoload, buses, mezcladores de zona y combate, voces, intervalos y preferencias. |
| `audio/catalogo.gd` | Perfiles de voces, afinaciones por criatura, identificación de mapas y selección de temas. |
| `audio/buses.tres` | Definición nativa de los seis buses. |
| `audio/interfaz/controles_audio.gd` | Controles de volumen compartidos por ambos menús. |
| `audio/herramientas/generar_audio.py` | Generador determinista de 107 WAV originales. Usa Python y su biblioteca estándar. Los WAV ya están en el proyecto, así que Python solo hace falta para regenerarlos. |
| `audio/efectos/` y `audio/efectos/enemigos/` | 72 efectos originales de juego. |
| `audio/interfaz/`, `audio/dialogos/` | 6 avisos de interfaz y 4 muestras de vocalización originales. |
| `audio/musica/`, `audio/ambiente/` | 15 pistas musicales y 10 bucles ambientales originales. |
| `audio/terceros/brackeys/tap.wav` | Interruptores. Copia del efecto archivado de Brackeys, Asbjørn Thirslund, con relleno RIFF válido y las mismas 1521 muestras. El paquete declara CC0. [Licencia y créditos](audio/terceros/brackeys/LICENCIA_Y_CREDITOS.txt) |
| `audio/narracion/narracion_reina.mp3` | Recurso existente de la introducción, entregado con la cinemática P41. El repositorio no identifica al autor ni indica una licencia separada. [Registro de la cinemática](documentacion/desarrollo/P41_CINEMATICA_INICIAL.md) |

Los WAV originales son PCM mono de 16 bits a 22 050 Hz. Godot importa el banco como PCM para conservar las muestras y evitar la codificación QOA durante la importación. La música, los ambientes, las vocalizaciones y los efectos originales se identifican como **mezcla provisional** hasta completar una escucha con el juego. Se crearon por síntesis a partir de osciladores, ruido filtrado y envolventes, sin muestras de otros videojuegos.

### Archivos existentes modificados

- `project.godot` añade el Autoload y la ruta de los buses.
- `personajes/jugador/player.gd` conecta locomoción, ataques, guardia, vida y habilidades.
- `personajes/jefes/{captain_boss,queen_boss,simple_boss,w2_archer_boss}.gd` conectan avisos de habilidades y explosiones.
- `sistemas/combate/{enemy_base,ranged_demon,boss_arena,wave_arena}.gd` conectan ataques, daño, muerte, fases, música y oleadas.
- `sistemas/proyectiles/{player_projectile,enemy_projectile}.gd` conectan disparos e impactos.
- `sistemas/entorno/{arena_barrier,checkpoint,chest_interactable,collapse_sequence,infernal_fire,lever,mine_elevator}.gd` conectan las interacciones de escenario.
- `objetos/recogibles/{boss_key_pickup,collectible_pickup}.gd` y `sistemas/nucleo/game_manager.gd` conectan recogidas y equipo.
- `interfaces/menu/{menu_principal,pause_menu_overlay,pause_menu_manager}.gd` e `interfaces/dialogos/dialogue_ui.gd` conectan las interfaces y el sonido de los diálogos.
- `narrativa/cinematicas/cinematica_inicial.tscn`, `mapas/tog/prologo_prision/cinematica_prision.gd` y `documentacion/desarrollo/P41_CINEMATICA_INICIAL.md` integran y documentan el audio de las cinemáticas.

## Pruebas y errores encontrados

### Comprobaciones automáticas

Las comprobaciones reproducen eventos y verifican el mezclador en Godot 4.7 sin salida audible. Se ejecutan en una copia temporal con configuración independiente de los perfiles del usuario.

| Comprobación | Resultado |
| --- | --- |
| Carga de audio y pruebas de juego | 165 comprobaciones, 0 fallos. Incluyen la carga de los 108 WAV, los buses y el limitador, la polifonía y la deduplicación, carrera, aterrizaje, rodada, tajo, guardia, Ultimate, enemigos, las tres señales de fase, ajustes en ambos menús y vocalizaciones interrumpidas. |
| Fundido de música | Dos pistas activas durante el fundido de Prisión hacia Calabozo. Solo la pista entrante sigue activa al finalizar. |
| Arranque y cierre de escenas | 21 de 21 con código 0. Se verificaron menú, introducción, prólogo, zona de pruebas, ocho mapas principales y nueve muestras de la galería. Cada proceso comprobó las pistas activas, la recuperación de los volúmenes y el cierre con audio activo. |
| Importación limpia y segunda pasada | Ambas salieron con código 0 y generaron los 108 recursos WAV. Después de precargar la caché solo quedó el aviso de certificados de Windows. |
| Formato y metadatos | 107 WAV originales validados por formato, pico y extremos del bucle. Se verificaron 108 contenedores RIFF con su UID, tres UID de script, 48 claves literales de efectos y las rutas dinámicas de familias, fases y zonas. |
| Verificador de macro mapa | 0 errores y tres avisos existentes por conexiones mediante túnel entre zonas. |

En el entorno de Windows permanece un aviso de Godot al leer el almacén de certificados. El prólogo informa que no encuentra el nodo opcional `MapBounds`. Ambos diagnósticos ya estaban presentes. La primera importación sin caché también puede informar que el tema todavía no encuentra tipografías y texturas. La segunda carga encuentra los recursos ya importados. Las comprobaciones headless confirman la carga y el enrutamiento. El balance audible, la claridad de la narración y el punto de escucha requieren una partida con salida de audio.

Durante la integración se corrigieron la clave del recurso de buses y el byte de relleno que faltaba en la copia activa del WAV de Brackeys. La importación original produjo un fallo nativo aislado y las primeras ejecuciones con cierre forzado reprodujeron el diagnóstico de Godot al salir con audio activo. La última importación usa PCM. El cierre de los menús detiene las reproducciones y espera al mezclador antes de salir. El fallo nativo, el aviso de RIFF y los avisos de cierre no se reprodujeron en la última ejecución. [Ajuste de buses en Godot 4.7](https://docs.godotengine.org/en/4.7/classes/class_projectsettings.html#class-projectsettings-property-audio-buses-default-bus-layout) · [Incidencia de cierre con audio activo](https://github.com/godotengine/godot/issues/76745) · [Importación WAV en Godot](https://docs.godotengine.org/en/4.6/classes/class_resourceimporterwav.html)

### Pruebas auditivas pendientes

1. Probar con auriculares y altavoces. Comprobar que la narración se entiende sobre la música y que el sonido posicional marca de dónde vienen los ataques.
2. Recorrer Prisión, Calabozo y Castillo. Escuchar pasos al cambiar de velocidad, escalera, salto, guardia, rodada y el fundido entre zonas.
3. Probar Ultimate completa e interrumpida. Cruzar el fuego infernal con Fire Knight y comprobar el cierre de las colas tras daño y muerte.
4. Luchar contra el Capitán, la Reina y el Caballero. Comparar las tres fases y escuchar un encuentro con oleadas y uno del Infierno.
5. Ajustar los seis volúmenes en ambos menús, cerrar desde Salir y volver a iniciar. Confirmar que se conservan los niveles. Avanzar rápido varias líneas con la Reina y el Barquero y comprobar que no queda una vocalización anterior.
