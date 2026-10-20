# P36 - Peso del golpe

- Con el desbloqueo de habilidades (P35), la partida empieza solo con el primer tajo, y se sentía lento y monótono:
  - pulsar ataque durante el tajo no hacía nada, porque no había etapa siguiente, así que había que esperar la animación entera (unos 1 s);
  - el golpe salía a los 0.37 s;
  - al conectar no pasaba nada más que el destello del enemigo.
- Idea: que la espada pese en el impacto, no en la espera.

## 1. El primer tajo se encadena consigo mismo

- Sin la Ráfaga (`combo_2`), una pulsación guardada durante el tajo lo repite desde `attack_1_chain_frame` (7), igual que hoy se encadena con la Ráfaga.
- El tajo repetido empieza en `attack_1_repeat_frame` (2): los cuadros 0-1 son una preparación agachada con la misma pose que el final, y saltárselos deja el ciclo limpio.
- En `player.gd`:
  - `_remaining_combo_inputs()` sustituye a `_max_combo_step() - _combo_step` en el buffer del combo;
  - `_repeats_first_attack()` dice si toca repetir;
  - `_start_attack()` acepta un cuadro de inicio opcional.
- Con la Ráfaga, todo sigue como antes: 1 → 2 → 3.
- Machacando el botón salen unos 4 tajos en 2 s, antes 2. Sigue siendo bastante menos que la Ráfaga, así que conseguirla vale la pena.

## 2. Primer tajo más rápido

- `attack_1_speed_multiplier` (1.35) sustituye a `combo_base_speed_multiplier` (1.20) solo para `attack`. El golpe sale a los 0.33 s y el tajo repetido conecta a los 0.16 s de empezar.

## 3. Paso hacia delante (lunge)

- Los perfiles de `attack` y `attack 3` tienen `"lunge": true` en `ATTACK_PROFILES`. Al empezar, el Player avanza `attack_lunge_distance` (10 px) en `attack_lunge_time` (0.12 s) y luego frena como antes.
- Solo en el suelo. La Ráfaga (giro) y el ataque aéreo no lo llevan.

## 4. Hitstop y temblor

- `UnderkingdomCombatFX.hit_stop(duración, escala)`: baja `Engine.time_scale` durante esa duración en tiempo real.
  - El temporizador es del SceneTree, así que la velocidad vuelve a 1 aunque el Player muera o se cambie de mapa.
  - Si llega uno nuevo, solo el último devuelve la velocidad.
- Se lanza al conectar con un enemigo, no con rompibles, una vez por golpe:

  | Golpe | Hitstop | Temblor |
  |---|---|---|
  | Con empuje (el último de cada ataque) | `hit_stop_time` 0.06 s | `hit_shake_strength` 2 px |
  | Remate con área "blast" (Golpe final, Ultimate) | `hit_stop_heavy_time` 0.1 s | `hit_shake_heavy_strength` 4 px |
  | Intermedio de una ráfaga | `hit_stop_continuous_time` 0.02 s | ninguno |

- `bounded_camera.gd` tiene `shake(fuerza, duración)`.
  - Solo mueve `offset`, en píxeles enteros, y se apaga solo.
  - No toca el smoothing ni el proceso en física que quitaron el temblor al caminar.
  - Usa tiempo real, así que sigue durante el hitstop.
- Todo se afina en el inspector del Player, categoría "Impacto". Un 0 desactiva cada efecto.

## Comprobado sin ventana

- Escena temporal, ya borrada, con el Player en un suelo de prueba:
  - partida nueva, machacando ataque 2 s: 4 tajos seguidos (`attack` repetido);
  - lunge de 7 px a los 5 cuadros;
  - todo desbloqueado: el combo sigue `attack` → `attack 2` → `attack 3`;
  - contra un esqueleto: los dos tajos conectan, la escala de tiempo baja a 0.05 y vuelve a 1, y la cámara tiembla y vuelve a (0, 0).
- Arranque, cementerio, minas y `mundo_1` sin errores.

## Pendiente

- Probarlo jugando y ajustar los números. Si con esto sigue faltando variedad al principio, la siguiente opción es adelantar la reliquia de la Ráfaga al inicio del cementerio (P35).
