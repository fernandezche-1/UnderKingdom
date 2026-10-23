# Castillo del trono gótico — escena editable

Abrir **`castillo_trono_gotico.tscn`** en Godot 4.7.2 y ejecutar la escena con
**F6**. No se modificó `project.godot` ni se insertó este mapa en Nueva partida.
La salida derecha, mediante **E**, conduce al castillo oscuro existente.
Las escenas actuales y sus conexiones no se modificaron.

La referencia gráfica no estaba adjunta al mensaje. La composición sigue la
descripción: interior gótico azul/morado, trono izquierdo, gran arco, galerías,
escalera central, cofre, cajas, lámparas, cadenas y pinchos inferiores.

## Archivos principales

- `castillo_trono_gotico.tscn`: sala de **1152 × 448 px**, editable y jugable.
- `tileset_trono.tres`: TileSet local reutilizable, cuadrícula **8 × 8 px**.
- `vista_general.png`: captura real del mapa renderizado. **No se utiliza como
  recurso de la escena** ni como fondo del juego.
- `validacion.json`, `validation.log`: comprobaciones de jugabilidad.
- `validacion_visual.json`: historial de ajustes de arte. `preview.log` y
  `vista_general.png` corresponden al último renderizado, también registrado
  en `validacion.json` cuando se ejecuta la validación completa.
- `colisiones_aprobadas.json`: huellas de los datos de tiles de Terreno,
  Plataformas y Peligros usados para conservar la geometría validada.

## Las ocho capas

| Capa | Contenido | Colisiones |
| --- | --- | --- |
| FondoAtmosfera | Mampostería oscura pintada con tiles | No |
| MuroFondo | Piedra azul/morada del interior | No |
| Arquitectura | Cornisas, columnas, ventanas, arco del trono, soportes y puerta | No |
| Terreno | Suelo, límites de sala, estrado y escalones | Sólidas, capa física 1 |
| Plataformas | Galerías y pasos superiores, puente del foso | Unidireccionales, capa física 2 |
| Decoracion | Trono compuesto de tiles, cadenas, antorchas, lámparas, jarrones y restos | No |
| ElementosInteractivos | Cajas visuales, cofre funcional y detector de escalera | Solo detectores de interacción/trepado |
| Peligros | Pinchos pintados y detector letal independiente | Detector letal para el jugador |

Todas son `TileMapLayer` persistidas con celdas pintadas. Los arcos y ventanas
grandes están en subcapas TileMapLayer, con escala entera para mantener el pixel
art; expandir Arquitectura para editarlas individualmente. No son imágenes de
la sala completa.

Fuentes de atlas del TileSet:

- **0:** Dark Castle visual, de `dark_castle_tileset.png`.
- **1:** Dungeon Platformer visual, de `dungeontilesetfull.png`.
- **2:** Tilesetv3 para detalles góticos, mobiliario y escalera.
- **3:** Dark Castle sólido, con polígonos en la capa física 1.
- **4:** Dark Castle para plataformas, con polígonos unidireccionales en la 2.

Para pintar nuevos suelos, usar 3 o 4. Las fuentes 0, 1 y 2 son visuales y no
convierten automáticamente una decoración en obstáculo.

## Qué ya se puede jugar

- Jugador actual, cámara limitada a la sala y entrada en `SistemasMapa/SpawnEntrada`
  (`spawn_id = SpawnInicio`). El controlador existente no duplica el jugador.
- Estrado y escalones: se suben saltando. Se conservan velocidad, gravedad y
  salto originales; no se cambiaron parámetros del jugador.
- Ruta superior: estrado → galería izquierda → balcón central → apoyo intermedio
  → balcón derecho. También se puede saltar al puente sobre los pinchos.
- Escalera central: usar W/arriba y S/abajo con el sistema de trepado existente.
  La boca del balcón deja un hueco de 40 px para permitir el descenso. Saltar
  ese hueco o salir lateralmente de la escalera para cruzar el balcón.
  Salir lateralmente de la escalera para apoyarse en una galería.
- `ElementosInteractivos/CofreBalcon`: cofre real con E, tres monedas y una poción,
  usando el sistema de botín y persistencia existente. No es un placeholder.
- `Peligros/PinchosLetales`: muerte al contacto y reaparición en la entrada.
- `SistemasMapa/SalidaDerecha`: E solicita una transición real a
  `res://escenas/mapas/prologo/castillo_oscuro.tscn`, spawn `SpawnInicio`.
  Se puede cambiar el destino desde el Inspector.
- Marcador adicional `SpawnSalida`, con ID `DesdeSalida`, disponible para
  futuras conexiones sin modificar otros mapas.

Los objetos recogidos conservan el comportamiento del GameManager actual.
F6 no crea un perfil: la persistencia en disco requiere un perfil activo,
igual que en los demás mapas del proyecto.

## Qué es únicamente visual

Trono, ventanas, balconadas/barandillas, columnas, cadenas, lámparas, cajas,
jarrones y restos. No tienen interacción ni colisión que bloquee la ruta.
Las antorchas tienen llamas animadas y luces locales; las lámparas también
iluminan. No hay enemigos ni nuevos diálogos en esta sala.

## Validación

Se ejecutó el proyecto temporalmente con un nombre de aplicación distinto, sin
leer o escribir partidas reales. Las comprobaciones incluyen:

- Apertura del `.tscn` guardado y ocho capas pintadas y persistidas.
- Un solo jugador y ausencia de generador conectado a la raíz del mapa.
- Suelo físico en la entrada y límites explícitos de cámara.
- Cinco saltos con la física real del jugador y aterrizaje en sus plataformas.
- Ascenso y descenso real por escalera, incluido el paso por la boca del balcón.
- Apertura del cofre y entrega de su botín.
- Entrada física a la salida y transición real al castillo existente.
- Contacto con pinchos, muerte real y reaparición segura.

La primera validación aprobó 38 comprobaciones. Después se ajustaron recortes
visuales y se dejó la boca de la escalera abierta para permitir también el
descenso: esa modificación de colisión justificó una nueva validación de la
ruta y del descenso, cuyos resultados finales están en `validacion.json` y
`validation.log`. La escena final también se carga y renderiza con OpenGL.

**Resultado final: 39 comprobaciones, cero fallos; construcción, validación y
renderizado aprobados.** El `.tscn` final referencia el TileSet externo local.

El controlador de aparición existente todavía registra la advertencia
«No se encontró un SpawnPoint con suelo seguro». Se mantuvo visible y no se
modificó ese sistema global. La simulación de esta sala sí comprobó suelo,
aterrizajes y reaparición correctos. No hay errores de sintaxis o carga en las
ejecuciones finales registradas. Queda el recorrido manual con teclado/mando y
la comparación visual exacta cuando se disponga de la imagen original.

## Edición y herramientas opcionales

Editar directamente la escena y el TileSet desde Godot. El mapa **no necesita**
ejecutar `construir_trono.gd`: ya está horneado en los archivos de recursos.

`pipeline.py` crea una copia temporal y protege los guardados. Comandos útiles:

```powershell
python escenas/mapas/prologo/trono_gotico/pipeline.py "RUTA\Godot.exe" --validate-only
python escenas/mapas/prologo/trono_gotico/pipeline.py "RUTA\Godot.exe" --preview-only
```

`construir_trono.gd` es una herramienta de autoría, no un script de juego.
**Regenerar con `--rebuild` reemplaza las ediciones manuales de esta escena nueva
y de su TileSet.** Hacer una copia antes. El comando sin opción se niega a
regenerar si la escena ya existe. No usar regeneración para las ediciones normales.

No se realizó commit, push ni cambio de rama.
