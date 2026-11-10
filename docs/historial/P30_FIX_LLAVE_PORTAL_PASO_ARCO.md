# P30 - Correcciones Mundo 1

- La llave funcional está precolocada en `(506, 492)` y permanece oculta/inactiva hasta que Capitán muere.
- Al derrotar a Capitán, la llave se activa; al tocarla se registra en GameManager y se desbloquea `PuertaJefeM1Bloqueo`.
- El portal azul de prueba usa `(365, 317)`, igual que `SpawnSalida`, justo sobre la reja.
- `PasoPuertaWS` y `OneWayPasoPuertaWS` NO se modificaron.
- `ColisionPoligono_04` conserva el terreno pero incorpora un hueco local para atravesar horizontalmente el arco negro.
