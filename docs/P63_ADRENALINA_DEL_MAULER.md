# P63 - La Adrenalina la da el Crystal Mauler

- Última pieza del paso 4 (Minas) de la Fase 2 de `TASK.md`. Sirve a la gruta de cristal (idea 6).
- Decisiones de `docs/historial/FASE2_DECISIONES.md` que aplica: sección "Adrenalina" (sin decisiones nuevas de diseño), G4 y la nota de P46 sección 6.
- Sin script ni escena nuevos: `boss_arena.gd` ya suelta la reliquia de `ability_reward` (P35). Sin guardado nuevo: `SAVE_FORMAT_VERSION` sigue en 5.

## 1. Qué cambia

- `GameManager.STARTING_ABILITIES` pasa a `["air_attack", "parry", "lifesteal"]`: en "Nueva partida" el jugador ya no tiene la adrenalina. Al abrir un mapa directo el Player sigue teniendo todo (`abilities_locked` es falso).
- La Adrenalina solo se consigue venciendo al Mauler: reliquia `reliquia_habilidad.tscn` con `ability_id = "adrenaline"`, que la `BossArena` suelta en `PuntoLlave` menos `ability_offset`. Si muere o sale sin recogerla, vuelve a estar ahí (`_drop_ability`).

## 2. Zona de pruebas

- `zona_pruebas_combate.tscn`, `Objetos/SalaMauler` (`boss_arena.gd`, `encounter_id` `pruebas_sala_mauler`): suelo x 45-60 de las filas 13-18 (16 de ancho, como la gruta). Activador en x 47, `PuertaEntrada` en x 44 (se cierra al empezar), `PuertaSalida` en x 61 dentro de `Atajos` (cerrada hasta vencer), el Mauler sale en x 59.
- **Cierra:** al entrar, `PuertaEntrada` se cierra y aparece el Mauler; sin vencerlo, la salida sigue cerrada.
- **Abre:** al vencerlo se abren las dos puertas y cae la reliquia de Adrenalina; al recogerla `has_ability("adrenaline")` pasa a verdadero.
- Se prueba sin espada con "Nueva partida" simulada: ver 3.

## 3. Pruebas

- Escena temporal sin ventana (borrada), con `reset_abilities_for_new_game()` antes de cargar la zona: adrenalina falsa al inicio; al entrar al activador la entrada se cierra y hay jefe; con daño de sobra el jefe muere, ambas puertas se abren, aparece una sola reliquia de adrenalina y, al recogerla, la adrenalina pasa a verdadera.
- Arrancan sin errores el juego, la zona de pruebas y `mundo_1` (este último con su aviso de spawn de siempre).

## 4. Pendiente

- Montar la sala en la gruta de cristal (trampilla de entrada en `Puertas`, la del suelo en `Atajos`, sin llave) es de la Fase 3.
- Arte propio de la reliquia: usa la de siempre (G4).
