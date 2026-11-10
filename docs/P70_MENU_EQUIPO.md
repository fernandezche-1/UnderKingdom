# P70 - Pestaña "Equipo" del menú de pausa

- Cuarta pieza de "En paralelo: atuendos" de la Fase 2 de `TASK.md` (P46, sección 10, "Implementación": "Menú de pausa").
- Decisiones de `docs/historial/FASE2_DECISIONES.md` que aplica: A2 (lista los encontrados, lo que da cada uno y marca el puesto; no se cambia a mano) y G4; las nuevas están al final de ese archivo.
- Cambian: `escenas/menu/menu_pausa.tscn` (pestaña `TabEquipo` y página `PaginaEquipo` con `ListaEquipo`) y `scripts/ui/pause_menu_overlay.gd`.
- Sin guardado nuevo: lee `outfits_found`, `has_sword` y `get_outfit_id()` (P59). `SAVE_FORMAT_VERSION` sigue en 5.

## 1. La pestaña

- Va tras "Mejoras": Datos, Llaves, Mejoras, Equipo. Como las demás, se elige con clic o moviendo el foco con teclado o mando.
- Una fila por atuendo (`PanelFila`), por nivel de menor a mayor: "E<n>  <nombre>" y, debajo, su `hint` de `OUTFIT_DEFINITIONS`. A la derecha, "Puesto" (`TextoAcento`) en el que se lleva y "Encontrado" (`TextoTenue`) en los demás.
- Qué se lista:
  - los atuendos de `outfits_found`;
  - los harapos si se tiene espada, aunque no se hayan recogido (armería, modo dev);
  - el desnudo solo si es el que se lleva;
  - los que faltan no salen.
- Debajo, "En total": los rasgos sumados de todos (alcance, daño de tajo, reducción en golpes fuertes, resistencias), porque se combinan entre todos los encontrados. No sale si no hay ninguno.
- Se refresca cada 0.2 s con el menú abierto, como las demás pestañas, y solo se rehace si algo cambió.
- Con los cinco atuendos la lista pasa del alto de la página y se desplaza (`ScrollContainer`, como Llaves). El ancho del panel no cambia (284 px).
- Los métodos `get_equipment_entries()` y `get_equipment_traits_text()` del overlay dan lo que se dibuja, para probarlo sin ventana.

## 2. Zona de pruebas

- Sin cambios en `zona_pruebas_combate.tscn`: se usan `Objetos/EspadaOxidada` y `Objetos/AtuendoSoldado` (P69) y "Siguiente atuendo" del modo dev.
- **Cierra:** al empezar, sin espada, la pestaña solo muestra "E0  Desnudo", Puesto, sin línea de total.
- **Abre:** tras tomar el soldado salen los harapos (Encontrado) y el soldado (Puesto), con "alcance x1.25" en el total; con el Fire Knight, este pasa a Puesto y el total suma "tajo +0.25" y "resiste el fuego infernal".

## 3. Pruebas

- Escena temporal sin ventana (borrada), con la zona de pruebas y el menú: los dos casos de arriba, el foco en la pestaña cambia de página, y con los cinco atuendos el panel sigue en 284 px.
- Arrancan sin errores el juego, la zona de pruebas y `mundo_1`.

## 4. Pendiente

- Un retrato o icono por atuendo en cada fila (hoy solo texto; el retrato de la pestaña Datos sigue siendo el del Fire Knight).
- Los `hint` y los rasgos son provisionales (A1) y se ajustan jugando.
