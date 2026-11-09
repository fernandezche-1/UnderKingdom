# P61 - Fuego infernal (pide E5)

- Pieza del paso 4 (Minas) de la Fase 2 de `TASK.md`. Sirve a la gruta de cristal de las minas, al altar este de las profundidades (`[S7]`) y al paso de las cadenas del infierno.
- Decisiones que aplica: M3, M4, M5 y A1 (E5 resiste el fuego infernal; P59).
- Escena `escenas/sistemas/fuego_infernal.tscn` y script `scripts/environment/infernal_fire.gd` (`UnderkingdomInfernalFire`, `Area2D`). Sin guardado nuevo: `SAVE_FORMAT_VERSION` sigue en 5.

## 1. Qué hace

- Franja de `width_tiles` x `height_tiles` piezas de 16 px (por defecto 3 x 1), con el origen **arriba a la izquierda**. Construye en `_ready` su colisión y una llama por pieza.
- **Sin E5:** cada vez que el Player la toca y no es invulnerable, `take_damage(damage_amount, origen, true)`: quita 0.5 (más el extra por ir sin espada y la reducción de atuendo de siempre) y lo empuja hacia el lado por el que llegó. El script recuerda ese lado mientras el Player está fuera. Insistir mata.
- **Con E5:** `GameManager.has_outfit_resistance("infernal_fire")` es verdadero y no hace nada.
- No es una `burn_zone` (no está en ese grupo): las quemaduras normales y la lava no cambian y el Fire Knight no las resiste. Solo detecta al Player (máscara 1): a los enemigos no les afecta.

## 2. Exportaciones

| Nombre | Por defecto | Para qué |
|---|---|---|
| `width_tiles` / `height_tiles` | 3 / 1 | tamaño en piezas |
| `damage_amount` | 0.5 | daño por golpe (múltiplo de 0.25) |
| `resist_kind` | `infernal_fire` | resistencia del atuendo que lo apaga |
| `flame_tint` | azulado | tinte provisional |

## 3. Arte provisional

- Las llamas son las de `sprites/trampas/fuego_rojo.png` (las de `trampa_fuego.tscn`) con un tinte azulado para distinguirlas. **Pendiente:** arte propio y, si se quiere, un resplandor visible desde lejos (el ASCII de la gruta dice que se ve desde la veta).

## 4. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Objetos`: `FuegoInfernal` en `(688, 304)`, 2 piezas de ancho (x 43-44), justo tras el fuego normal de x 42.
- **Cierra:** sin atuendo, tocarlo quita vida y devuelve al Player al lado de donde llegó.
- **Abre:** con el Fire Knight (Modo dev, "Siguiente atuendo" hasta E5) se cruza sin daño. Más allá sigue el fuego normal de x 42, que sí quema.

## 5. Pruebas

- Escena temporal sin ventana (borrada), con la zona cargada: entrando por la derecha sin E5, la vida pasa de 4.0 a 2.5 en tres golpes (0.75 cada uno: 0.5 más 0.25 por ir sin espada) y el Player no pasa de x 726 (borde en 720); con `grant_outfit("fire_knight")` cruza el fuego sin perder vida (la muerte posterior es de la `burn_zone` normal, como debe).
- Arrancan sin errores el juego y la zona de pruebas. No se toca Player, enemigos, `GameManager` ni el Capitán: `mundo_1` no se ha probado.

## 6. Cómo se monta en la Fase 3

- Minas: pasillo del fuego, x 133-141, fila 55 (`width_tiles` 9). Profundidades: altar este de `[S7]`. Infierno: paso de las cadenas, x 41-44, fila 12. En los ASCII figuran como `F`; al generar, el constructor las trata como trampas de fuego normales (`F`), así que hay que sustituirlas por esta escena en la `_combate` (o enseñarle la letra al constructor).
