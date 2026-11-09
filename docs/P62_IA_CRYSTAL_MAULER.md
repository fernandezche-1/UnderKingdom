# P62 - IA del Crystal Mauler

- Pieza del paso 4 (Minas) de la Fase 2 de `TASK.md`. Sirve a la gruta de cristal de las minas (idea 6, jefe opcional).
- Decisiones de `docs/FASE2_DECISIONES.md` que aplica: M6, M7, M8 y G4.
- Escena nueva `escenas/jefes/crystal_mauler.tscn`, con `scripts/bosses/simple_boss.gd` (sin script nuevo). `boss_mina.tscn` no se toca: lo usa `mundo_2` (mapa viejo, sin uso). Sin guardado nuevo: `SAVE_FORMAT_VERSION` sigue en 5.

## 1. Qué hace

- Escala 1, colisión de 20 x 35 px en `(6, 45.5)` (el cuerpo no está centrado en el cuadro de 288 x 128, por eso `mirror_sprite_on_flip`). 16 de vida, contacto 0.5, armadura durante el ataque (la de `simple_boss.gd`), `BossHealthBar` "CRYSTAL MAULER". Sin patrulla: persigue desde lejos y no se cae de los bordes.
- Los `SpriteFrames` salen de las tiras sueltas de `Elementals_Crystal_Mauler_Free_v1.0/.../animations/PNG`: `idle`, `run`, `1_atk`, `2_atk`, `3_atk`, `sp_atk`, `take hit` y `death`. No usa `air_atk`, `defend` ni `roll`.
- **Fase 1:** `1_atk`, `2_atk` (cuadros 3-5, 0.5) y `3_atk` (cuadros 8-14, 0.5; golpe largo de unos 132 px). Se alternan al azar sin repetir el anterior.
- **Fase 2** (por debajo de la mitad de vida; reglas de `simple_boss.gd`: más rápido, persigue más, espera menos): además `sp_atk` (cuadros 8-13, 1.0; unos 140 x 84 px hacia delante).
- Con el Player sin espada, cada golpe suma 0.25 (`unarmed_*`): los tajos quitan 0.75 y `sp_atk` 1.25.

## 2. Perfiles de ataque (relativos al centro del cuerpo)

| Animación | Cuadros | Daño | Hitbox (tamaño / desplazamiento) | Fase |
|---|---|---|---|---|
| `1_atk` | 3-5 | 0.5 | 52 x 48 / (24, 38) | 1 |
| `2_atk` | 3-5 | 0.5 | 48 x 52 / (22, 36) | 1 |
| `3_atk` | 8-14 | 0.5 | 132 x 76 / (66, 26) | 1 |
| `sp_atk` | 8-13 | 1.0 | 140 x 84 / (72, 21) | 2 |

Los alcances salen de la caja opaca de cada cuadro. Los números son provisionales: se ajustan jugando.

## 3. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Enemigos`: `CrystalMauler` en `(448, 225)`, sobre la meseta de la colina (x 25-31, fila 18), que lo mantiene sin poder alejarse. Ahí no hay sitio para esquivar el `sp_atk`: en la gruta real (16 x 14) hay que ponerse detrás o rodar.
- **Cierra:** vivo ataca y quita vida; el golpe no lo empuja.
- **Abre:** vencerlo (16 de vida): hace `death` y desaparece. La recompensa (Adrenalina) es la pieza siguiente.

## 4. Pruebas

- Escena temporal sin ventana (borrada), con la zona cargada y el Player al lado: salen los cuatro ataques (`sp_atk` solo en fase 2), los tajos quitan 0.75 y `sp_atk` 1.25 al Player sin espada; con 9 de daño pasa de 16 a 7 de vida y entra en fase 2; con daño de sobra muere y se libera.
- Arrancan sin errores el juego y la zona de pruebas. No se toca Player, `GameManager` ni el Capitán: `mundo_1` no se ha probado.

## 5. Pendiente

- La Adrenalina (`ability_reward adrenaline` en la `boss_arena`) es la pieza siguiente.
- Montarlo en la gruta, con la `boss_arena` y el fuego infernal, es de la Fase 3. La `BossHealthBar` va sin `show_only_with_aggro`.
- Sin sonidos ni efectos propios; el `sp_atk` no levanta onda en el suelo (el arte no la trae).
