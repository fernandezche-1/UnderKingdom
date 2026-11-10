# P50 - Objeto de lore que abre un diálogo

- Tercera pieza de la Fase 2 de `TASK.md` (paso del calabozo): un objeto con el que se lee un texto (acta, diario, restos) usando el diálogo de siempre.
- Sirve al acta del prisionero (depósito del alcaide), al diario de la Reina (3 páginas), la fosa de los soldados leales, los restos de los condenados, la carta de la primera reina y el alma del rey encadenado: el lore de marcador de P46.
- Piezas:
  - `escenas/objetos/objeto_lore.tscn`, con `scripts/environment/lore_object.gd` (`UnderkingdomLoreObject`), que hereda de `UnderkingdomNPC` (`npc.gd`);
  - un diálogo de ejemplo, `dialogues/lore_acta_prisionero.json`.
- Decisiones de `docs/historial/FASE2_DECISIONES.md` que aplica: C5, C6, G3, G4 y G5.

## 1. El objeto

- Reutiliza `npc.gd` y `dialogue_ui` sin duplicar nada: aviso flotante, E (`interactable`), Player quieto durante el diálogo, enfriamiento tras cerrarlo. Solo cambia `prompt_text` ("E  Leer"), `face_player` (apagado) y añade el marcado de lectura.
- Es una escena genérica: el sprite (`sprite_frames`, animación `idle`) y el diálogo (`dialogue_path`) se cambian por instancia. Las líneas son las de cualquier diálogo JSON: `speaker_id` `friend` (sin retrato) o `player`, y `name`, que da el título ("ACTA", "DIARIO DE LA REINA, I").
- **C5, releer:** el objeto se queda y se puede releer cuantas veces se quiera.
- **Primera lectura:** al cerrar el diálogo por primera vez marca `lore_<lore_id>` en `GameManager.completed_encounters` (con autoguardado) y emite `read_first_time`. Es para una futura pestaña de diario, que no se hace en esta fase.
- Sin `lore_id` avisa con `push_warning` y funciona, pero no guarda la lectura.

| Propiedad | Valor | Qué hace |
|---|---|---|
| `lore_id` | `""` | id del texto; se guarda como `lore_<id>` |
| `dialogue_path` | `""` | JSON de `dialogues/` (en la escena, el del acta) |
| `prompt_text` | `E  Leer` | aviso flotante (G5) |
| `interaction_radius` / `interaction_vertical_range` | 32 / 72 | distancias de `npc.gd` |
| `face_player` | apagado | un objeto no se gira |

## 2. Guardado

- No hay variable nueva: usa `completed_encounters`, que ya se guardaba y se reiniciaba. `SAVE_FORMAT_VERSION` no cambia.
- El id lo pone el editor, no la ruta del nodo: el objeto se puede mover o renombrar sin perder lo leído.

## 3. Arte y textos provisionales

- Sprite: una bolsa de tela de `assets/terceros/craftpix-net-218281-free-pixel-art-dungeon-objects-asset-pack/PNG/supplies_objects.png` (región `(0, 256, 16, 20)`), 16 x 20, escala 1. El origen está en el centro: un objeto sobre el suelo se coloca 10 px por encima de la fila del suelo.
- **Pendiente:** arte propio de papel, libro y restos; Armando escribe los textos definitivos (el JSON del acta está marcado "TEXTO PROVISIONAL").

## 4. Zona de pruebas

- `zona_pruebas_combate.tscn`, en `Objetos`: `ObjetoLore` en `(264, 310)`, columna 16 del tramo de inicio, sobre el suelo. `lore_id` `acta_prisionero`.
- **Cierra:** lejos del objeto no sale el aviso y la E no hace nada (lanza la Ultimate, como siempre).
- **Abre:** E junto al objeto abre el diálogo; con `dialogue_advance` se lee y se cierra. Se puede releer.

## 5. Pruebas

- Escena temporal sin ventana que carga la zona de pruebas y simula entradas (borrada al terminar):
  - lejos: `can_interact` falso; cerca: verdadero y con el aviso visible;
  - E abre el diálogo (`UnderkingdomDialogueUI` en el árbol) y deja al objeto en `_talking`;
  - antes de leer, `lore_acta_prisionero` no está marcado; al avanzar todas las líneas el diálogo se cierra y queda marcado en `completed_encounters`;
  - tras el enfriamiento, se puede volver a leer.
- Arrancan sin errores el juego y la zona de pruebas. No se tocó el Player, un enemigo, `GameManager` ni el Capitán: `mundo_1` no se comprobó.
