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
