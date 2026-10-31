# P43 - Zona de pruebas para sprites y enemigos

- Mapa aparte para probar sprites, animaciones y enemigos nuevos antes de llevarlos a un mapa de la ruta.
- Se abre `escenas/mapas/zona_pruebas_combate.tscn` y se pulsa F6.
- No forma parte de la ruta: no tiene salidas y ninguna escena lleva a él. La regla de enemigos por profundidad no aplica aquí.

## 1. El mapa

- `mapas_texto/zona_pruebas.txt` (mapa de letras, 146 x 24 piezas, tileset `castillo`) genera `escenas/mapas/zona_pruebas.tscn`.
- `zona_pruebas_combate.tscn` hereda de esa escena y agrega los enemigos sin letra. Regenerar la base no los borra.
- Tramos, de izquierda a derecha:
  1. Inicio (x 2-22): pasillo plano para idle y correr, checkpoint, cofre y poción.
  2. Colina con rampas (x 24-32).
  3. Foso de pinchos (x 36-38), que prueba la muerte, y fuego en x 42, que prueba la quemadura.
  4. Plataformas de una vía (x 45-63), de dos en dos filas, hasta la galería alta.
  5. Escalera que atraviesa el piso (x 69, filas 11-19), con checkpoint en x 64.
  6. Escalera de la galería a la cornisa (x 83, filas 5-10), con cofre y poción, y un kolbo en la galería.
  7. Corrales de enemigos en el piso de abajo, separados por columnas de 2 piezas (x 73-143).
- Los corrales llevan, en orden: rata, slime, esqueleto, esqueleto de lanza, Guardia, Aprendis, y mino con diablillo.
  - Rata, slime y esqueleto de lanza no tienen letra: viven en la escena `_combate`.

## 2. Medidas

- Todo se cruza también sin espada, que es lo más limitado: el salto sube 3 piezas y cruza unas 4.
- Por eso las plataformas suben de 2 en 2 filas, las columnas miden 2 piezas y el foso mide 3 de ancho.

## 3. Cómo probar

- El Player es `prisn.tscn`, el de la partida: sale sin espada.
- **Con espada:** Modo dev (tecla º), "Dar espada". Cambia a los sprites con espada en el momento.
- **Sin espada otra vez:** reiniciar con F6.
- **Teclas de prueba** (`depuracion: si`): R reaparecer, H daño de ¼, J daño de 1, K morir, además del panel de depuración.
- **Sprite nuevo del Player:** se ve al jugar el mapa; no hace falta tocar nada.
- **Enemigo nuevo con letra:** se pone en el `.txt` y se regenera.
- **Enemigo nuevo sin letra o sprite suelto:** se añade a `zona_pruebas_combate.tscn`, en `Enemigos` u `Objetos`.

## 4. Comprobado

- Prueba sin ventana, con y sin espada: rampas, foso, las cuatro plataformas, llegada a la galería, las dos escaleras y salida hacia los lados, y salto de una columna.
- Todos los enemigos caen a su sitio y se quedan en su corral al arrancar.
- Al salir por arriba de la escalera x 69 hay que seguir pulsando arriba mientras se va al lado; si se suelta antes, se cae por el hueco. Es el comportamiento normal de la escalera con hueco de 3 piezas.
- La espada se dio con el Modo dev y el Player cambió a sus sprites con espada.
- `arena_enemigos.tscn` sigue existiendo, pero las pruebas nuevas van aquí.
