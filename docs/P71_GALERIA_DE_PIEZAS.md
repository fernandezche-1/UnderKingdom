# P71 - Galería de piezas en la zona de pruebas

- Las piezas de la Fase 2 (P48 a P70) se habían ido poniendo en la zona de pruebas donde cabían. Quedaron unas encima de otras: la losa del Golpe final y la estatua de la Ultimate cerraban el pasillo del inicio, la arena con oleadas iba sobre el inicio con rectángulos de color, y no se sabía qué era cada cosa.
- Ahora cada pieza tiene un cuarto cerrado en una galería debajo del mapa, en el orden de la ruta, con un cartel que dice qué pieza es, a qué zona va y cómo se prueba.
- Cambian:
  - `mapas_texto/zona_pruebas.txt`, que pasa de 146 x 24 a 146 x 82 piezas, y la escena generada `zona_pruebas.tscn`;
  - `zona_pruebas_combate.tscn`, que vuelve a llevar solo los tres enemigos de corral sin letra y la galería;
  - `scripts/player/player.gd`: bajar por la escalera atraviesa una plataforma de una vía (sección 3).
- Nuevos:
  - `escenas/mapas/zona_pruebas_galeria.tscn`, instanciada en `Objetos` de la `_combate`;
  - `herramientas/zona_pruebas/galeria.py`, que la genera.
- Sin guardado nuevo.

## 1. Cómo es

- El tramo de arriba (filas 0-23) no cambia, salvo la bajada a la galería: una escalera en la columna 3, junto al spawn, con el cartel "GALERIA DE PIEZAS. Baja por la escalera (S)".
- Debajo hay tres pisos en zigzag. Cada piso es un pasillo con los cuartos debajo, y los pisos se unen por un pozo con escalera:

| Piso | Filas | Sentido | Zonas |
|---|---|---|---|
| A | 24-42 | a la derecha | calabozo y castillo |
| B | 43-61 | a la izquierda | cementerio y minas |
| C | 62-81 | a la derecha | mazmorra, ruina, profundidades e infierno |

- Cada pasillo tiene un checkpoint al empezar.
- En el pasillo, encima de cada zona va su nombre con la letra de títulos (`Encabezado`), y encima de cada cuarto, el nombre de la pieza (`TextoAcento`).
- Dentro del cuarto, arriba, va el cartel: la pieza con su etapa (Pxx), "Va en:" con las zonas que la usan y cómo se prueba.
- Cada cuarto está cerrado. Se baja con S por su escalera y se sube trepando.
- Las puertas, rejas y el fuego llevan encima una columna maciza. No se pueden saltar: el hueco que queda por encima está a 8 piezas del suelo.
- Los cuartos, en orden:
  - **Calabozo:** pared agrietada (P48), palanca y barrera (P49), objeto de lore (P50), empuñadura (P51), espada oxidada y harapos (E1, P69).
  - **Castillo:** reja baja (P52), mostrar u ocultar (P53), fragmentos de vida (P54), atuendo del soldado (E2, P69).
  - **Cementerio:** sellos (P55; el tercero lo enciende una palanca, en el juego el Capitán), rompible selectivo (P56), puerta de velas (P57), amuleto (P58).
  - **Minas:** ascensor (P60; la cabina de arriba está en una cornisa del mismo cuarto y la palanca da la corriente), fuego infernal (P61), Crystal Mauler y su sala (P62, P63).
  - **Mazmorra:** derrumbe (P64). El suelo que se hunde está sobre un foso. Se huye a la derecha y se sale por una segunda escalera.
  - **Ruina:** llama eterna, hielo y zona oscura (P65); dash en el aire (P66), con un pasillo de 4 de alto y un foso de pinchos de 6.
  - **Profundidades:** no pide piezas nuevas; el cuarto lo dice y lleva el maniquí del Fire Knight (E5, P68).
  - **Infierno:** arena con oleadas (P67).
  - La pestaña "Equipo" (P70) se prueba con la espada oxidada y el soldado.
- Se quitaron tres cosas:
  - el Crystal Mauler suelto: el de su sala es el mismo;
  - el hielo con la llave de prueba `pruebas_llama`: era la misma pieza que el hielo de la llama eterna;
  - los rectángulos de color de la arena y del pasillo del dash, que ahora son tiles del mapa.
- Las posiciones en la zona de pruebas que dan las etapas P48 a P70 ya no valen: cada pieza está en su cuarto.

## 2. Cómo se cambia

- `herramientas/zona_pruebas/galeria.py` escribe el mapa de letras (deja igual las filas 0-23 y la cabecera) y reescribe entera `zona_pruebas_galeria.tscn`.
- Para añadir o cambiar un cuarto: se edita su `room(...)` en el script, se corre y se regenera la base:
  ```
  python3 herramientas/zona_pruebas/galeria.py
  ~/.local/bin/godot --headless res://herramientas/constructor_mapas/construir_mapa.tscn -- mapas_texto/zona_pruebas.txt
  ```
  La galería no se edita a mano en el editor: el script la sobrescribe.
- `zona_pruebas_combate.tscn` no la toca el script. Lo que se ponga ahí para probar (un enemigo sin letra, un sprite suelto) se conserva, como siempre.
- Texto de los carteles:
  - van en el tema global, a tamaño 8, con borde negro para leerse sobre el ladrillo;
  - como mucho 6 líneas, para no pisar la columna de las puertas;
  - sin mayúsculas con tilde: Pixel Operator 8 no tiene la "Í" y la pinta en minúscula.

## 3. Escalera bajo una plataforma de una vía

- La caja del preso mide 20 px y el hueco de una escalera, 16. Con la boca abierta o con "=H=", al cruzarla caminando se caía al cuarto. Por eso cada boca la tapa una plataforma de una vía de tres piezas ("===") y la escalera empieza en la fila de debajo. La zona de la escalera llega una pieza más arriba, así que al trepar se sale encima de la plataforma.
- Antes, al pulsar abajo encima de esa plataforma, el Player se ponía a trepar y la plataforma lo frenaba. Ahora, en `_process_climbing` de `player.gd`, bajar estando en el suelo apaga la capa de una vía `drop_through_time` segundos, igual que S fuera de la escalera.
  - Sobre suelo macizo no cambia nada.
  - Ningún mapa de la ruta ni ASCII de `mapas_texto/macro/zonas/` tiene una plataforma encima de una escalera, así que no cambia nada de lo que ya se jugó.

## 4. Pruebas

- Capturas con ventana de los tres pisos (borradas): los carteles se leen y no se montan sobre las piezas.
- Escena temporal sin ventana (borrada):
  - de pie en el suelo de cada cuarto y de cada pasillo;
  - cruzar caminando la boca de una escalera sin caer;
  - bajar con S a un cuarto y volver a subir;
  - bajar desde el inicio, y los dos pozos entre pisos, bajando y subiendo;
  - la palanca abre su reja; los tres sellos abren la suya; el anciano aparece y el barquero se va;
  - al entrar en la sala del Mauler se cierra la reja y el jefe aparece en `Galeria/Enemigos`;
  - el derrumbe se marca y sella su reja;
  - al llegar por el ascensor, el Player sale en la cabina de arriba.
- Arrancan sin errores el juego, la zona de pruebas, el calabozo, el castillo, el cementerio y `mundo_1`. El aviso de `mundo_1` "No se encontró un SpawnPoint con suelo seguro" ya salía antes del cambio.

## 5. Pendiente

- Jugarla con F6 y ajustar los textos que no se entiendan.
- Al añadir una pieza nueva, darle su cuarto en el script.
