# P67 - Arena con oleadas (`wave_arena.gd`)

- Pieza del paso 7 (Infierno) de la Fase 2 de `TASK.md`: las arenas cerradas del coliseo de los condenados y del salón de los verdugos (P46, sección 9, infierno). Sirve también al coliseo de ceniza de las profundidades (altar oeste, "oleadas de diablillos y el demonslime"): su sello escucha el `encounter_id` de la arena (`listen_encounter`, P55).
- Decisiones de `docs/FASE2_DECISIONES.md` que aplica: I1, I2, I3 y G3; las nuevas están al final de ese archivo.
- Script nuevo: `scripts/combat/wave_arena.gd` (`UnderkingdomWaveArena`). Sin escena propia, como `boss_arena.gd`: se monta en la `_combate` sobre un `Node2D`.
- Sin guardado nuevo: solo marca su `encounter_id` en `completed_encounters`. `SAVE_FORMAT_VERSION` sigue en 5.

## 1. Montaje

Hijos, con los mismos nombres que `boss_arena.gd`:
- `Activador` (`Area2D`): al entrar el Player empieza el combate.
- `Puertas/*` (`arena_barrier.gd`): abiertas; se cierran al empezar y se abren al acabar. En el coliseo, la reja de la columna 44; en el salón, la trampilla de arriba (x 3-5, fila 107).
- `Atajos/*` (opcional, `arena_barrier.gd`): cerrados hasta superar la arena. En el coliseo, la trampilla del suelo (x 96-98, fila 61); en el salón, la reja de salida (columna 32).
- `Oleadas/<n>/*`: un nodo por oleada, en orden, con sus enemigos colocados donde tienen que aparecer. Al cargar, la arena los saca del árbol (no se ven, no colisionan ni procesan); su `_ready` ya corrió, así que guardan su punto de origen.
- `UI/Aviso` (`Label`, opcional): avisos de oleada y de victoria.

Exportaciones:
- `encounter_id` (vacío = ruta de la escena + nodo). En el coliseo del infierno, `infierno_animas_liberadas`, la marca que abre la jaula del rey encadenado.
- Ritmo: `start_delay` 0.8 (de cerrarse las puertas a la primera oleada), `wave_delay` 1.5 (entre oleadas, I1) y `finish_delay` 1.0 (de vencer la última a abrirse).
- Avisos (G3): `wave_message` "OLEADA %d/%d" (número y total; vacío = sin aviso), `victory_message` "ARENA SUPERADA" y `message_time` 1.6.
- Señales: `combat_started`, `wave_started(wave_index, wave_count)`, `wave_cleared(wave_index)` y `encounter_completed(encounter_id)`.

## 2. Comportamiento

- Cada enemigo aparece con la nube de `UnderkingdomCombatFX.spawn_puff`, la misma de los jefes de `boss_arena.gd`.
- Una oleada se vence cuando todos sus enemigos emiten `died` o salen del árbol (respaldo para lo que no sea un `enemy_base.gd` o caiga a una kill zone que lo libere). Una oleada vacía se salta.
- Al vencer la última: se abren `Puertas` y `Atajos`, sale "ARENA SUPERADA" y se marca `encounter_id` (lo escuchan `open_on_encounter`, los sellos y `encounter_visibility.gd`).
- Al morir (I2) el mapa se recarga y, como el encuentro no está marcado, la arena vuelve a empezar: puertas abiertas y oleadas desde la primera. Superada, al volver está abierta y sin enemigos.
- Los enemigos de cada oleada y su número se deciden en la Fase 3, por instancia (I3). No se tocan los enemigos ni el Player.

## 3. Zona de pruebas

En `zona_pruebas_combate.tscn`, `Objetos`, sobre el inicio (todo con rectángulos de color, arte provisional):
- `EscaleraArena`: escalera en la columna 3 (filas 11-19), junto al spawn.
- `SueloArena`: suelo propio en la fila 11, x 5-22 (y 176), con 9 filas de alto hasta el techo.
- `ArenaOleadas` (`encounter_id` `pruebas_arena_oleadas`): reja de entrada en x 6 (`Puertas`), activador en x 9 y reja de salida en x 21 (`Atajos`), las dos de 9 piezas con las rejas del tileset del castillo. Oleada 1: rata y slime; oleada 2: esqueleto de lanza.
- **Cierra:** al entrar se cierra la reja de entrada; hasta vencer la segunda oleada no se sale por ningún lado.
- **Abre:** vencidas las dos, se abren las dos rejas; por la de salida se cae al lado de la colina.
- Para repetirla, reiniciar la escena (F6) con una partida nueva o el encuentro sin marcar.

## 4. Pruebas

Escena temporal sin ventana (borrada), con el Player de la zona de pruebas invulnerable:
- al cargar: 2 oleadas, ningún enemigo en el árbol, entrada abierta y salida cerrada;
- subiendo por la escalera y andando a la derecha se entra: se cierra la entrada y a los 0.8 s salen la rata y el slime (la oleada 2 sigue fuera);
- andando a la izquierda se para en la reja de entrada (x 121); vencida la oleada 1, la 2 sale a los 1.5 s; vencida la 2, andando a la derecha se para en la de salida (x 325) y el encuentro no está marcado;
- al segundo de vencerla: encuentro marcado, las dos rejas abiertas, aviso "ARENA SUPERADA", y se sale por la derecha;
- al recargar superada: abierta y sin enemigos; al recargar a mitad de combate (como al morir): estado inicial, oleadas enteras y puertas abiertas.
- Arranques sin errores: juego y zona de pruebas. No se tocó el Player, los enemigos, el `GameManager` ni el Capitán.

## 5. Pendiente

- Fase 3: montar las dos arenas del infierno (coliseo con `encounter_id` `infierno_animas_liberadas`; salón de los verdugos) y la del coliseo de ceniza de las profundidades, y decidir sus oleadas.
- Arte: la escalera y el suelo de la prueba son rectángulos; las rejas usan las piezas del tileset de cada nivel.
