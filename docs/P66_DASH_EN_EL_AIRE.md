# P66 - Dash en el aire (`air_dash`)

- Segunda pieza del paso 6 (Ruina) de la Fase 2 de `TASK.md`. Es el premio del Guardián de hielo (`ability_reward air_dash`, P46 sección 6) y la llave de los secretos con pasillo de 4 de alto y foso de 6 (ruina, minas, mazmorra).
- Decisiones de `docs/FASE2_DECISIONES.md` que aplica: R3, R4, R5 y G3 a G5; las nuevas están al final de ese archivo.
- No hay escena ni script nuevos: es una acción más del Player (`PlayerAction.AIR_DASH`, al final del enum) y una fila de `ABILITY_DEFINITIONS`.
- Sin guardado nuevo: las habilidades ya se guardan por `ABILITY_DEFINITIONS`. `SAVE_FORMAT_VERSION` sigue en 5.

## 1. Comportamiento

- Botón: el de rodar (Shift), pulsado en el aire. Rodar solo funciona en el suelo, así que no chocan. Hace falta espada y la habilidad `air_dash`.
- Recorre `air_dash_distance` (112 px, 7 piezas) en `air_dash_time` (0.18 s): velocidad horizontal fija (unos 622 px/s), sin gravedad y sin velocidad vertical. Va hacia donde se pulsa; sin dirección, hacia donde mira.
- Una vez por salto: `_air_dash_used` se recarga al tocar el suelo o una escalera.
- Sin invulnerabilidad (la rodada sí la tiene). Recibir un golpe corta el dash (pasa a `HURT`). Una pared lo detiene.
- Al acabar conserva la velocidad de caminar, no la del dash.
- Solo se puede empezar sin otra acción en curso: no durante un tajo, ni cubriéndose.
- Arte provisional (R5): la animación de rodar acelerada al tiempo del dash. Falta una animación y una estela propias.
- Exportaciones del Player (categoría de combate): `air_dash_distance` y `air_dash_time`. Métodos: `is_air_dashing()` y `has_air_dashed()`.

## 2. Zona de pruebas

En `zona_pruebas_combate.tscn`, `Objetos`, a continuación del suelo que se hunde (P64), a la altura de la galería alta (suelo en y 176), desde x 1824:
- `ReliquiaDash` (1844, 160): reliquia con `ability_id` `air_dash`.
- `PasilloDash`: pasillo de 4 de alto (techo en y 112), suelo de entrada de 5 piezas (x 1824-1904), foso de 6 (x 1904-2000) con `PinchosFoso` y suelo de llegada (x 2000-2144) con pared al fondo. Dibujado con rectángulos de color (arte provisional).
- **Cierra:** sin el dash no se cruza el foso, ni con la Agilidad (el techo limita el salto a unos 20 px de subida).
- **Abre:** con el dash se cruza y se llega al otro lado.
- Ojo: el derrumbe de P64 hunde el suelo de la galería que lleva al pasillo; reiniciar la escena (F6) lo restablece.

## 3. Pruebas

Escena temporal sin ventana (borrada), con el Player con espada y `abilities_locked`:
- sin el dash, saltando desde el borde: cae (base y Agilidad, en todas las pruebas); con el dash, a los 0.08 s del salto: cruza y llega a la pared (también con la Agilidad);
- Shift en el suelo rueda y no gasta el dash; en el aire da el dash; el segundo Shift del mismo salto no hace nada; al tocar el suelo se recarga;
- la reliquia da `air_dash` al acercarse.
- Arranques sin errores: juego, zona de pruebas y `mundo_1` (se tocó el Player y `GameManager`).

## 4. Pendiente

- Arte: animación y estela del dash; arte del pasillo.
- Fase 3: dar `ability_reward air_dash` al Guardián de hielo y montar los tres pasillos (ruina, minas, mazmorra) según los ASCII.
