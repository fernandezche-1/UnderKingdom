# P34 - Enemigos y arte de los paquetes nuevos

- Llegaron paquetes nuevos de Ansimuz, todos CC0:
  - Legacy Collection (Gothicvania);
  - Super Grotto Escape;
  - Gothicvania Cemetery.
- Esta etapa los usa en el orden acordado:
  1. murciélago;
  2. esqueletos;
  3. efectos de muerte e impacto;
  4. la Reina como jefe de la mazmorra;
  5. tileset del cementerio;
  6. jefes de ruina, profundidades e infierno;
  7. NPC con los que se habla y el mercader.
- Cada paquete se descomprime fuera del proyecto. Solo se copia lo que se usa, con su `ORIGEN.txt` en `assets_prueba/<paquete>/`.

## 1. Murciélago (`m`)

- **Arte:** Bat de Super Grotto Escape, 5 cuadros de 48x48, en `assets_prueba/super_grotto/murcielago.png`. Se ve de frente, así que no hace falta girarlo.
- **Escena:** `escenas/enemigos/murcielago.tscn`.
- **Script nuevo:** `scripts/combat/lunge_enemy.gd` (`UnderkingdomLungeEnemy`), que extiende `enemy_base.gd`. Es para criaturas sin animación de golpe:
  - el ataque se queda quieto un momento como aviso (`lunge_windup`);
  - luego se lanza hacia el torso del Player (`lunge_speed`, `lunge_duration`);
  - solo hace daño durante el impulso;
  - los voladores se lanzan también en vertical; los de suelo frenan antes de un borde.
- **Valores:**
  - 1,5 de vida: dos golpes del primer tajo, o uno del tercero más otro;
  - ¼ de corazón de daño, cada 1,4 s;
  - vuela a la altura del torso del Player (`fly_target_offset_y = 34`);
  - lo detecta a 190 px.
- **Letra `m`**, color `#402060`, en `COLORS` / `ENEMIES` del constructor. Se dibuja en la pieza donde flota. Se regeneraron la paleta y la tabla de `LEYENDA.md`.
- **Dónde está** (coordenadas en piezas):
  - **Cementerio:** cripta (50, 42) y (73, 42); abismo (60, 66) y (95, 66).
  - **Minas:** los dos huecos de la veta ardiente que dejó P33, (58, 79) y (80, 78); galería alta (62, 23); galería media (88, 38).
- **Comprobado sin ventana:**
  - frente al Player en un suelo de prueba: se acerca, se queda a la altura del torso, avisa, se lanza y quita ¼ de corazón; un golpe de 0,75 le deja 0,75;
  - tras regenerar el cementerio y las minas, solo cambian los nodos de `Enemigos` y los identificadores internos (tileset, `unique_id`), como en P33;
  - las dos escenas `_combate` cargan, y tras 3 s de física los 4 murciélagos de cada mapa siguen donde se dibujaron.

## 2. Esqueletos (`e` y `u`)

- **Arte:** el esqueleto de Gothicvania Cemetery, de 44x52 por cuadro, con su animación de salir de la tierra y la nube de muerte del mismo paquete.
  - Los cuadros sueltos se juntaron sin cambiar el arte en `assets_prueba/gothicvania_cementerio/esqueleto.png`, una fila por animación (ver su `ORIGEN.txt`).
  - Se descartó el esqueleto de Super Grotto Escape que proponía el plan: es cabezón y de estilo tierno, y no pega con el resto. Además tampoco trae animación de golpe.
- **Las dos escenas usan la embestida del murciélago** (`lunge_enemy.gd`), porque el arte no trae golpe: avisan 0,35 s, se lanzan 57 px y solo dañan durante el impulso.
  - Valores comunes: 3 de vida, ½ corazón de daño cada 1,6 s, patrulla lenta.
  - Muerte con la nube del paquete (animación `death`).
- **`escenas/enemigos/esqueleto.tscn` (`e`):** camina desde el principio. Va en la mazmorra y la ruina.
- **`escenas/enemigos/esqueleto_tumba.tscn` (`u`), con ropa:** usa el script nuevo `scripts/combat/rising_enemy.gd` (`UnderkingdomRisingEnemy`).
  - Mientras duerme se ve solo un montículo de tierra. No se mueve, no recibe daño y está en la capa 0: el Player lo atraviesa y su ataque no lo detecta.
  - Cuando el Player llega a 85 px en horizontal y 60 px en vertical, sale de la tierra hacia él. Sigue siendo invulnerable mientras se levanta.
  - Va en el cementerio.
- **Dónde están** (piezas):
  - **Cementerio (`u`):**
    - superficie (18, 29), junto al inicio, para enseñar la mecánica, y (95, 29);
    - cripta (68, 47);
    - catacumbas (49, 56);
    - abismo (70, 75).

    Ninguno está en la sala del jefe.
  - **Mazmorra (`e`):** (38, 33), (45, 40) y (68, 69).
  - **Ruina (`e`):** (42, 20), (14, 39) y (85, 56).

  Todos van sobre suelo llano de 6 piezas o más, con tres filas libres encima y sin pinchos ni lava. Donde se pudo, junto a monedas o cofres, que ya se sabe que se alcanzan.
- **Comprobado sin ventana:**
  - frente al Player, el esqueleto se acerca, embiste y quita ½ corazón;
  - el de tumba lejos del Player sigue dormido 7 s y rechaza un golpe; cerca, sale de la tierra y pelea;
  - tras regenerar, cementerio, mazmorra y ruina cargan, y los 11 esqueletos siguen sobre el suelo a los 3 s (los de tumba, dormidos).
