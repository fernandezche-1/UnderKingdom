# P69 - Atuendo para recoger (generaliza la espada oxidada)

- Tercera pieza de "En paralelo: atuendos" de la Fase 2 de `TASK.md` (P46, sección 10, "Implementación": "Objeto para recoger").
- Decisiones de `docs/FASE2_DECISIONES.md` que aplica: G3 (textos en mayúsculas y exportados), G4 (arte provisional), G5 (con E) y A3; las nuevas están al final de ese archivo.
- Archivos nuevos: `escenas/objetos/atuendo.tscn` y `scripts/items/outfit_pickup.gd` (`UnderkingdomOutfitPickup`).
- Cambian: `scripts/items/sword_recovery.gd` (tres métodos que se pueden cambiar) y `escenas/objetos/espada_oxidada.tscn`, que ahora hereda de `atuendo.tscn` con `outfit_id` `harapos`.
- Sin guardado nuevo: lo recogido va a `outfits_found` (P59) y el objeto a `consumed_objects`. `SAVE_FORMAT_VERSION` sigue en 5.

## 1. La escena

- `atuendo.tscn`: un `Node2D` con `outfit_pickup.gd`, un `Sprite2D` (`atuendo_preso.png` a escala 2, ropa en el suelo, 44 x 20) y el `Prompt` "E - TOMAR ATUENDO". Se toma con E delante, como la espada.
- Exporta:
  - `outfit_id` (`soldado` por defecto): un id de `GameManager.OUTFIT_DEFINITIONS`;
  - `requires_sword_mission` (falso): solo se ve desde que empieza la misión de la espada; lo usa la espada oxidada;
  - de `sword_recovery.gd`: `interaction_radius` (56), `notice_title` y `notice_text`. Vacíos, el aviso usa el nombre y el `hint` de la tabla.
- Al tomarlo: `GameManager.grant_outfit(outfit_id, player)` (da la espada si el atuendo la trae y no se tenía, su habilidad y sus rasgos), destello, aviso de historia y el objeto se consume.
- No sale, o deja de poder tomarse, si ese atuendo ya está en `outfits_found`, o si son los harapos y ya se tiene espada (no darían nada).
- Para E2 a E5 basta con instanciar `atuendo.tscn` y cambiar `outfit_id`; para otro dibujo, cambiar la textura del `Sprite2D` en la instancia o en una escena heredada.

## 2. La espada oxidada

- `espada_oxidada.tscn` hereda ahora de `atuendo.tscn`: `outfit_id` `harapos`, `requires_sword_mission` verdadero, el dibujo de la espada teñida con la ropa al lado, y los mismos textos de antes.
- En el calabozo se comporta igual: se ve desde que empieza la misión (el carcelero la empieza al cargar) y da la espada. Además apunta los harapos en `outfits_found`, que no cambia nada (`get_outfit_id()` ya daba `harapos` con espada).
- `sword_recovery.gd` gana `_already_owned()`, `_is_available()` y `_grant()`; con sus valores, `espada_recuperable.tscn` hace lo mismo que antes. Si la recogida falla, el dibujo vuelve a su sitio (antes se quedaba invisible).

## 3. Zona de pruebas

- `zona_pruebas_combate.tscn`, `Objetos/EspadaOxidada` (x 240, con `requires_sword_mission` falso) y `Objetos/AtuendoSoldado` (x 296), en el pasillo del inicio, entre el objeto de lore y las mejoras.
- **Abre:** sin espada, E delante de la espada oxidada da la espada y los harapos; E delante del soldado da el soldado y el alcance pasa a 1.25.
- **Cierra:** tomado el soldado primero, la espada oxidada ya no se puede tomar ni muestra el aviso; reiniciar la escena no vuelve a sacar ninguno de los dos.

## 4. Pruebas

- Escena temporal sin ventana (borrada), con la zona de pruebas: lejos no se puede tomar; E da espada y harapos, luego el soldado con alcance 1.25; al recargar no están; en partida nueva, el soldado primero da espada y deja la oxidada sin poder tomarse; el guardado lleva `soldado`. En el calabozo la espada oxidada sigue con su título y visible al empezar la misión.
- Arrancan sin errores el juego, la zona de pruebas, el calabozo y `mundo_1`.

## 5. Pendiente

- Arte de cada atuendo en el suelo o en su soporte (la armería, la tumba de la cripta, el secreto de la ruina, las profundidades): hoy todos usan la ropa del preso.
- Colocar E2 a E5 en sus zonas en la Fase 3.
