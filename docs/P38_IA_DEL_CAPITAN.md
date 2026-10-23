# P38 - IA del Capitán: plataformas

- En la sala del jefe del cementerio hay dos plataformas one-way (fila 52, x 10-14 y 29-33), 80 px por encima del suelo, y una escalera en la columna 25. El Player las usaba y el Capitán no:
  - su `collision_mask` era 1 y las one-way están en la capa 2, así que ni las detectaba;
  - con el Player arriba se quedaba debajo lanzando tajos al aire;
  - colgarse de la escalera dejaba al Player fuera de su alcance.
- Idea: que el Capitán persiga al Player por toda la sala, con avisos claros para que se pueda leer y castigar.

## 1. Sube a la plataforma del Player

- Con `use_platforms` (activo por defecto), el Capitán suma la capa `one_way_collision_layer` (2) a su máscara. Las one-way solo frenan desde arriba: caminar por debajo o saltar a través de ellas no cambia.
- Si el Player está de pie más de `platform_min_rise` (24 px) por encima, y como mucho a `jump_max_rise` (128 px):
  - deja de atacar y se acerca hasta `jump_approach_distance` (56 px);
  - espera `jump_reaction_time` (0.45 s) con el Player arriba, para no saltar cada vez que el Player sube un momento;
  - se agacha `jump_windup_time` (0.22 s), con la pose del primer cuadro del roll, y salta.
- El salto cae a `jump_landing_gap` (40 px) del Player, sobre su plataforma:
  - busca el suelo con rayos;
  - recorre el arco con `test_move` antes de saltar, para no chocar con techos ni paredes;
  - si no cabe, prueba más cerca del Player o al otro lado.
- La altura es la del desnivel más `jump_clearance` (22 px). Velocidad horizontal máxima: `jump_max_horizontal_speed` (230 px/s).
- Al aterrizar ataca como muy pronto a los `landing_attack_delay` (0.25 s). No vuelve a saltar hasta pasado `jump_cooldown` (1 s).
- Animaciones nuevas en `capitan.tscn`: `jump` (fila `j_up` de la hoja) y `fall` (fila `j_down`). También se ven al caer de una plataforma o tras un empujón.

## 2. Baja de las plataformas

- Sobre una one-way, la atraviesa durante `drop_through_time` (0.25 s), igual que el Player al pulsar abajo:
  - si el Player está más abajo;
  - si está a la misma altura, pero el borde no le deja llegar (p. ej. en la otra plataforma).
- Antes también espera `jump_reaction_time`.
- Sobre suelo sólido no hace nada nuevo: se queda en el borde, como antes.

## 3. Tajo aéreo

- La animación `attack` del Capitán ya era el ataque aéreo del sprite (`air_atk`).
- **Escalera:** si el Player está colgado (`Player.is_climbing()`, nuevo), salta hasta su altura a distancia de tajo, ataca en el punto más alto y vuelve al suelo. Ya no se puede esperar en la escalera.
- **Plataforma, fases 2 y 3:** si al caer ya está encima de la plataforma y el Player queda a su alcance, ataca en el aire en vez de esperar a aterrizar. Antes comprueba que tiene suelo debajo, para no frenar en el aire y quedarse corto.
- Los dos usan el daño, la caja de golpe y el enfriamiento de siempre de `attack`.

## 4. Ajustes de fase y detalles

- En fases 2 y 3, la reacción y el aviso se acortan con el mismo multiplicador que el enfriamiento de los ataques (`_phase_cooldown_multiplier()`: 0.72 y 0.58).
- En el aire no se cubre: un golpe le corta el salto y lo empuja.
- El roll espera a que pise suelo.
- Si muere en el aire, cae durante la animación de muerte en vez de quedarse flotando.
- La inmunidad anti-spam cancela el salto.

## Archivos

- `scripts/bosses/captain_boss.gd`:
  - categoría "Capitán - Plataformas";
  - `_chase_target` pasa primero por `_navigate_platforms`;
  - el salto vive en `_process_special_state`, junto al roll.
- `escenas/jefes/capitan.tscn`: animaciones `jump` y `fall`. Recargarla en el editor sin guardar encima.
- `scripts/player/player.gd`: `is_climbing()`.

## Probado

- Sin ventana, con una escena temporal sobre `tiles_cementerio_combate.tscn` (sin la sala ni las cinemáticas), colocando al Player:
  - en una plataforma: el Capitán se acerca, se agacha, salta y cae a su lado (y = 768, la superficie);
  - en la otra plataforma: camina al borde, la atraviesa, cruza por el suelo y sube;
  - en fase 3: tajo aéreo al caer sobre la plataforma;
  - en la escalera: salta y ataca a su altura una y otra vez;
  - el roll sobre la plataforma se para en el borde.
- Arrancan sin errores el menú, el cementerio, `mundo_1` y `primer_boss_mundo_1`.

## Pendiente

- Jugarlo con ventana y ajustar tiempos (`jump_reaction_time`, `jump_windup_time`, `landing_attack_delay`).
- Si el Player entra en la sala y se queda lejos, el Capitán no lo detecta (`detection_range` 260 px; la sala mide 368 px y aparece en el extremo opuesto). Se podría dar aggro al aparecer.
