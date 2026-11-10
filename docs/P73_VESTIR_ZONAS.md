# P73 - Vestir las zonas: arte y enemigos nuevos en la Fase 3

- Método para meter en cada zona de la Fase 3 de `TASK.md` arte nuevo (tileset, decorados, fondo, luces) y enemigos nuevos que todavía no están en el repo.
- Decidido el 2026-11-10:
  - el arte sale de packs de terceros y de la IA;
  - en cada zona va primero la estructura y después el arte ("vestirla");
  - la lista de cada zona se arma entre los dos: Claude propone y el usuario aprueba.
- No cambia ninguna regla de P46. Un enemigo nuevo sigue la regla de profundidad (P33), y ningún reto obligatorio puede pedir lo que el jugador no tiene al llegar (P46, sección 10).

## 1. Por qué en dos pasadas

El constructor genera la escena base desde el `.txt` de la zona. La base incluye:
- el tileset (`tileset:` y `bloques:`);
- los decorados por letra;
- el fondo (`fondo:` / `parallax:`);
- los enemigos con letra (`ENEMIES` en `herramientas/constructor_mapas/construir_mapa.gd`).

Jefe, puertas, objetos y luces van en la `_combate`, que hereda de la base y no se pierde al regenerar.

Por eso una zona se puede generar y jugar con el arte de hoy y vestirla después. Basta con cambiar la cabecera y las letras de su `.txt` y regenerar la base.

## 2. Los cuatro pasos de cada zona

Cada paso es una sesión con su commit, sin push.

### A. Estructura
- Es el paso de la Fase 3 de `TASK.md`: generar la zona desde su ASCII con el tileset y los enemigos de hoy, montar su `_combate` y jugarla.
- Si la ficha ya pide un enemigo que todavía no existe, su sitio se reserva con una letra de la misma profundidad (tabla de P33) y se apunta en la ficha como provisional.

### B. Ficha de la zona
Claude la propone y el usuario la aprueba. Va en la sección 3 de este documento y tiene estos apartados:
- **Ambientación:**
  - de qué tileset y fondo parte y cuál se propone;
  - los decorados nuevos y qué letra reutiliza cada uno;
  - las luces (`DECOR_LIGHTS` de `scripts/environment/map_ambience.gd`).
- **Enemigos:**
  - los que se quedan y los nuevos;
  - de cada enemigo nuevo:
    - profundidad;
    - script base (`enemy_base.gd`, `lunge_enemy.gd`, `rising_enemy.gd` o `ranged_demon.gd`);
    - vida, daño (múltiplos de 0.25) y letra;
    - dónde va en el ASCII.
- **Origen del arte:**
  - el pack de `assets/terceros/` o el nuevo por bajar, con su licencia;
  - o la receta para la IA.
- **Reto obligatorio:** se revisa contra la fila de la zona en "Desbloqueos por zona" (P46, sección 10).

Arte que ya está en el repo y no se usa: el tileset `mainlev_build` y los props de `pixelfantasy_caves`, el resto de `monster_creatures_2` (Mimic), lo que queda de Gothicvania y de `super_grotto`, y lo apartado en `archivo/sin_uso/assets/`.

### C. Piezas nuevas en la zona de pruebas
Cada pieza se prueba en la zona de pruebas antes de ir a un mapa de la ruta.

**Tileset nuevo** (`mapas_texto/LEYENDA.md`, sección 8):
1. Traer el pack a `assets/terceros/<pack>/` con su `ORIGEN.txt`. Lo que no se use va a `archivo/sin_uso/assets/`.
2. Crear `herramientas/constructor_mapas/tilesets/<tema>.gd`:
   - copia el atlas de la mazmorra en las filas 0-15 y añade lo suyo debajo, como `castillo.gd` y `cementerio.gd`;
   - así las letras de decorado siguen valiendo y cada tileset las reinterpreta.
3. En los bloques, solo piezas macizas: la colisión se deduce de la opacidad de las esquinas de cada pieza.
4. Si alguna pieza da luz, añadir sus coordenadas a `DECOR_LIGHTS`.
5. Probarlo en una sala de la galería (`herramientas/zona_pruebas/galeria.py`).

**Enemigo nuevo** (P34, secciones 1 y 2):
1. Hacer una hoja con una fila por animación, sin cambiar el arte del pack.
2. Crear `escenas/enemigos/<nombre>.tscn`:
   - con el script base que pida la ficha y `collision_layer = 5`;
   - con un script propio solo si su comportamiento no cabe en los métodos que se pueden sobrescribir de `enemy_base.gd`.
3. Darle letra y color en `COLORS` / `ENEMIES` del constructor:
   - regenerar la paleta (`-- --paleta`);
   - ponerlo en la tabla de LEYENDA (sección 5) y en la de P33.
4. Montar su sala en `galeria.py`, con un cartel que diga a qué zona va.
5. Probarlo sin ventana con una escena temporal, que se borra al acabar. Tiene que comprobar que:
   - tras 3 s de física sigue en su sitio;
   - recibe golpes;
   - hace daño en múltiplos de 0.25.

**Arte con IA para enemigos:**
- `herramientas/sprites/tira_ia_a_hoja.py` está pensado para el Player (864x384 por cuadro, escala 1/3).
- Primero se prueba con `--escala` y `--fila-pies`.
- Solo si no basta se le añade un modo para enemigos, sin cambiar lo que hace con el Player.

**Una pieza de C está hecha cuando:**
- funciona en la galería;
- pasó la prueba sin ventana;
- arrancan sin errores el juego y la zona de pruebas (y las zonas ya generadas si se tocó `enemy_base.gd`);
- su ficha y las tablas que la nombran están al día;
- hay un commit.

### D. Vestir la zona
1. En `mapas_texto/tiles_<zona>.txt`:
   - cambiar la cabecera (`tileset`, `bloques`, `fondo` / `parallax`);
   - cambiar las letras provisionales por las nuevas;
   - colocar los decorados.
2. Regenerar la base. La `_combate` solo se toca para las luces o para un enemigo sin letra.
3. Comparar las celdas sólidas de la base antes y después. Con piezas macizas no deberían cambiar, pero la zona ya se jugó, así que se comprueba (regla de las colisiones validadas de CLAUDE.md). Si cambian, preguntar antes de seguir.

**Una zona vestida está hecha cuando:**
- arranca sin errores con `godot --headless res://escenas/mapas/tiles_<zona>_combate.tscn --quit-after 120`;
- `python3 herramientas/macro_mapa/verificar_mundo.py` da 0 errores;
- se jugó a mano;
- se regeneró el Atlas con `herramientas/macro_mapa/datos_atlas.py` y se publicó de nuevo;
- su ficha está marcada como vestida en `TASK.md`;
- hay un commit.

## 3. Fichas por zona

El estado de partida sale de la cabecera de cada ASCII (`mapas_texto/macro/zonas/`) y de la tabla de P33. Lo demás está por armar.

### Calabozo
- Parte de: tileset `castillo`, `fondo: castillo`. Enemigos de P33, profundidad 0 (rata, slime, murciélago grande, carcelero).
- Ficha: por armar.

### Castillo
- Parte de: tileset `castillo`, `fondo: castillo`. Guardia, Vanguardia, murciélago; el Rey Caído.
- Ficha: por armar.

### Cementerio
- Parte de: tileset `cementerio`, parallax de `gothicvania_cementerio/fondo` (cielo, montes y cementerio). Vanguardia, murciélago, esqueleto de tumba; el Capitán.
  - Pendiente de P34, sección 5: el cielo se ve también dentro de las cuevas, porque cada mapa tiene un solo parallax.
- Ficha: por armar.

### Minas
- Parte de: tileset `mazmorra` con `bloques: madera`, parallax de `pixelfantasy_caves`. Kolbos y murciélago; el Caballero y el Crystal Mauler.
- Ficha: por armar.

### Mazmorra
- Parte de: tileset `mazmorra` con `bloques: oliva`, parallax de `gothicvania/castillo_viejo`. Aprendis, mino, kolbo3, esqueleto; la Reina.
- Ficha: por armar.

### Ruina
- Parte de: tileset `mazmorra` con `bloques: ladrillo`, parallax de `gothicvania/cavernas`. Los mismos de la profundidad 3-4; el Guardián de hielo.
- Ficha: por armar.

### Profundidades
- Parte de: tileset `mazmorra` con `bloques: oro`, parallax de `gothicvania/lava`. Diablillo; el Demon Slime. Faltan los minijefes de los altares (P46, sección 7).
- Ficha: por armar.

### Infierno
- Parte de: tileset `mazmorra` con `bloques: ladrillo`, parallax de `gothicvania/lava`. La mezcla de los más duros (P46); Cthulhu. Faltan los enemigos definitivos.
- Ficha: por armar.
