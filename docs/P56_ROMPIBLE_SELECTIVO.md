# P56 - Rompible que solo acepta un tipo de golpe

- Segunda pieza del paso del cementerio en la Fase 2 de `TASK.md`: la losa de la cripta de la primera reina (tajo ascendente con el Golpe final) y la estatua de la Reina (Ultimate).
- Decisiones de `docs/historial/FASE2_DECISIONES.md` que aplica: S4, S5, S6, G3 y G4.
- Piezas:
  - `scripts/environment/selective_breakable.gd` (`UnderkingdomSelectiveBreakable`), que hereda de `breakable_object.gd`: mismos cuadros, escombros, botín, polvo, sacudida y recuerdo de "ya roto";
  - `escenas/objetos/rompible_selectivo.tscn`: raíz `AnimatableBody2D` (la AttackHitbox no detecta `StaticBody2D`, P48), 1 x 3 piezas, origen arriba a la izquierda, `max_health` 1.

## 1. Cómo funciona

- Exportación `accepted_hit`: `FINAL_BLOW` (0, por defecto: la animación `attack 2` con la habilidad `combo_3`) o `ULTIMATE` (1: `attack ultimate`).
- Se rompe con 1 golpe del tipo correcto (S5). Con cualquier otro (tajo descendente, tajo ascendente sin Golpe final, aéreo, puñetazos, bola de fuego, Ultimate si pide Golpe final) no pierde vida, el Player no lo cuenta como golpe (sin hitstop ni destello) y sale una chispa metálica (`block_spark`); la primera vez, el aviso "RESISTE EL GOLPE" (S4).
- Exportaciones del aviso: `wrong_hit_message`, `show_wrong_hit_message` y `spark_cooldown` (0.3 s, para que las ventanas de golpe de un mismo tajo no repitan la chispa).
- Lo detecta por el nombre de la animación que el Player ya pasa a `take_player_attack_from` y `take_player_continuous_attack_from`; no se tocó el Player.
- Las de `breakable_object.gd` siguen valiendo: `coin_drop_count`, `potion_drop_count`, cuadros, `break_puff` y `break_shake_*`.

## 2. Estatua de la Reina y `mundo_1` (S6)

- `estatua_rompible.tscn` solo se usa en `mundo_1` (mapa viejo, sin uso) y su arte (434 x 724 px) no sirve a escala 1. No se tocó: la estatua de la Reina del cementerio será una instancia de `rompible_selectivo.tscn` con `accepted_hit = ULTIMATE` y su propio `SpriteFrames` en la Fase 3. Así `mundo_1` no cambia.

## 3. Guardado

- Usa `GameManager.mark_object_consumed` / `is_object_consumed`, como la pared agrietada: se recuerda al recargar el mapa tras morir y se reinicia en `reset_for_new_game`. `SAVE_FORMAT_VERSION` no cambia.

## 4. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Objetos`, en el pasillo del inicio (cierran el paso a la colina): `LosaGolpeFinal` en `(240, 272)` y `EstatuaUltimate` en `(320, 272)` (`accepted_hit = 1`), con 2 monedas cada una.
- **Cierra:** con puños o con espada, tajo descendente, aéreo o Ultimate (la losa), chispa y aviso; la estatua tampoco cede al tajo ascendente. No se puede pasar.
- **Abre:** la losa cede a un tajo ascendente con el Golpe final y la estatua a la Ultimate (Modo dev, "Dar espada"). Tras romperse sueltan monedas y dejan pasar.

## 5. Pruebas

- Escena temporal sin ventana (borrada): en la zona de pruebas comprobó que
  - `attack`, `air attack`, golpes sin nombre (`take_damage_from` / continuo) y la Ultimate no rompen la losa; `attack 2` sin Golpe final tampoco;
  - `attack 2` con `combo_3` la rompe, la marca consumida y desactiva su colisión;
  - la estatua rechaza `attack 2` y se rompe con `attack ultimate`.
- Arrancan sin errores el juego, la zona de pruebas y `mundo_1` (su aviso de "SpawnPoint con suelo seguro" ya salía antes; no se tocó Player, enemigos, GameManager ni Capitán).

## 6. Pendiente

- Arte propio de la losa (cripta) y de la estatua (Reina). Provisional: la columna del castillo de la pared agrietada, teñida de azul grisáceo (`self_modulate`).
- Montarlos en el cementerio es de la Fase 3.
