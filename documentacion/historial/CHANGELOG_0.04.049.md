# UnderKingdom 0.04.049 — seguridad de spawns del castillo

- Ajustados los dos spawns del Castillo Oscuro a Y=260, con 3 px de separación entre los pies de la colisión del jugador y la plataforma inicial.
- El controlador espera al frame de física y comprueba que un spawn no esté solapado con el suelo y tenga una superficie debajo.
- Las posiciones guardadas y los checkpoints se restauran si son seguras; si no, se usa un spawn válido y se conserva el resto del estado de la partida.
- Quitadas las colisiones duplicadas de las salidas; cada transición conserva la colisión de su escena compartida.

## Verificación

Revisión estática completada. La ejecución interactiva queda pendiente porque el ejecutable de Godot no está disponible en este entorno.
