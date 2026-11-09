# P64 - Suelo que se hunde y huida del derrumbe (`[!5]`)

- Primera pieza del paso 5 (Mazmorra) de la Fase 2 de `TASK.md`. Sirve a la sala de la Reina y a la huida hacia la ruina.
- Decisiones de `docs/FASE2_DECISIONES.md` que aplica: Z1, Z2 (escombros, no frente de derrumbe), Z3, G3 y G4.
- Script `scripts/environment/collapse_sequence.gd` (`UnderkingdomCollapse`, `Node2D`) y `scripts/environment/falling_rubble.gd` (el escombro, que se crea por código). Sin escena propia. Sin guardado nuevo: usa `completed_encounters`, así que `SAVE_FORMAT_VERSION` sigue en 5.

## 1. Qué hace

1. **Dispara:** cuando `GameManager` marca `trigger_encounter` (el `encounter_id` de la `BossArena` de la Reina) o al llamar a `start()`. Con `wait_for_ability` (por ejemplo `ultimate`) espera a que el Player recoja esa reliquia, porque flota y no cae con el suelo.
2. **Temblor** (`tremor_time`, 1.5 s): texto "TODO SE DERRUMBA", la cámara tiembla (`shake()`), las piezas del suelo vibran 1 px y sale polvo. Las `sealed_barriers` (la trampilla de entrada) se cierran.
3. **Hundimiento:** cada pieza espera según su distancia al centro (`crumble_stagger`), vibra `crumble_shake_time`, pierde su colisión y cae 160 px apagándose. Se marca `collapse_id`. Un Player sobre el suelo cae a la fosa, sin daño de caída.
4. **Huida**, sin tiempo límite: cada `rubble_interval` (1.6 s) cae un escombro en el siguiente `Marker2D` de `Escombros` que esté a menos de `rubble_range` del Player. Antes sale polvo arriba durante `rubble_warning_time` (0.8 s). Cada escombro quita 0.5 (más el extra de ir sin espada, como todo golpe) y empuja. La cámara tiembla un poco (`escape_shake_strength`).
5. **Fin:** al entrar el Player en `exit_area_path` se marca `collapse_id` + `_huida`. Ya no tiembla ni cae nada.

## 2. Qué recuerda (Z3)

| Marca | Significado | Al cargar |
|---|---|---|
| ninguna | sin derrumbe | construye el suelo; si el disparo ya estaba marcado, empieza solo |
| `collapse_id` | suelo hundido, huida en curso | sin suelo, barreras cerradas, siguen el temblor y los escombros |
| `collapse_id` + `_huida` | huida terminada | sin suelo, barreras cerradas, todo quieto |

Las barreras se cierran después, en diferido, porque la `BossArena` abre sus puertas en su propio `_ready`.

## 3. Exportaciones

| Nombre | Por defecto | Para qué |
|---|---|---|
| `trigger_encounter` | vacío | encuentro que lo dispara |
| `wait_for_ability` | vacío | habilidad que hay que recoger antes del temblor |
| `collapse_id` | `derrumbe` | marca del hundimiento (único por zona) |
| `sealed_barriers` | vacío | rutas a barreras que se cierran para siempre |
| `exit_area_path` | vacío | `Area2D` que termina la huida |
| `floor_width_tiles` / `floor_height_tiles` | 15 / 1 | suelo, en piezas; origen arriba a la izquierda del nodo |
| `piece_texture` / `piece_tint` | provisional / blanco | dibujo de cada pieza (16 x 16) |
| `tremor_time` | 1.5 | segundos de temblor |
| `crumble_stagger` / `crumble_shake_time` | 0.06 / 0.3 | cómo se rompe el suelo |
| `rubble_interval` / `rubble_warning_time` | 1.6 / 0.8 | ritmo y aviso de los escombros |
| `rubble_fall_height` / `rubble_damage` / `rubble_range` | 128 / 0.5 / 240 | altura, daño (múltiplo de 0.25) y alcance |
| `collapse_message` | `TODO SE DERRUMBA` | aviso |

Hijo `Escombros`: un `Marker2D` por sitio de caída, a la altura del suelo donde se estrella.

## 4. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Objetos`: `PalancaDerrumbe` (x 96), `SelloDerrumbe` (reja en x 98, abierta al empezar) y `Derrumbe` (suelo de 15 piezas en x 99-113, fila 11, a continuación de la galería). Tres puntos de escombros en el suelo del piso de abajo y la zona `Salida` en x 113-120.
- **Cierra:** tirar de la palanca y correr sobre el suelo. La reja se cierra, el suelo se rompe a trozos y el Player cae al piso de abajo (con el corral de enemigos de siempre).
- **Abre:** no hay nada que abrir: es la huida la que acaba. Entrar en la `Salida` (x 113-120) la termina y ya no cae nada. Se reinicia con F6.

## 5. Pruebas

- Escena temporal sin ventana (borrada), con la zona cargada: antes de la palanca, suelo presente y reja abierta; al tirar, fase de temblor con la reja cerrada; a los 1.8 s el derrumbe marcado; a los 4 s sin suelo y el Player en y 258 (cayó); con los enemigos quitados, un escombro bajo el Player le quita 0.75 (0.5 más 0.25 por ir sin espada); en la salida la huida se marca y 2.5 s después no hay escombros; recargando la escena con la huida marcada no hay suelo y la reja está cerrada; sin la marca de huida la recarga vuelve a la fase de huida.
- `wait_for_ability = "ultimate"`: con el disparo marcado se queda esperando y, al desbloquear la habilidad, empieza el temblor.
- Arrancan sin errores el juego y la zona de pruebas. No se toca Player, enemigos, `GameManager` ni el Capitán: `mundo_1` no se ha probado.

## 6. Cómo se monta en la Fase 3

- Sala de la Reina: nodo `Derrumbe` en x 8, fila 75 (15 piezas, `floor_width_tiles` 15), `trigger_encounter` = el de la `BossArena`, `wait_for_ability` `ultimate`, `sealed_barriers` = `TrampillaEntrada`, `exit_area_path` = zona sobre `[!5]` (x 115-117, filas 87-89). `Escombros` en los fosos y escalones de la huida (x 27-118).
- **El suelo del ASCII es bloque (P46).** El suelo de esta pieza es un cuerpo aparte, así que en el nivel generado hay que dejar libres esas 15 celdas (o quitarlas de la capa `Terreno` al montar la `_combate`) y rellenarlas con la pieza. Es cambio de la Fase 3, y las colisiones validadas de la mazmorra no se tocan hasta entonces.
- **Punto de reaparición:** con la trampilla sellada, un checkpoint en la fosa evita que morir en la huida deje al Player en la antesala sin camino. Se coloca en la Fase 3.

## 7. Pendiente

- Arte: la piedra del suelo (el tile de la mazmorra, `piece_texture`), el escombro de 12 x 12 y el polvo son provisionales (G4).
- La escalera del colector y su trampilla (que se abre desde abajo) usan la palanca y la barrera de P49; no necesitan pieza nueva.
