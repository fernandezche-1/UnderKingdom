# P28 — Correcciones de Mundo 1 y attack 3

Cambios de esta versión de prueba:

- Llave de Capitán:
  - aparece por encima del punto de muerte;
  - pickup por body_entered;
  - fallback por overlaps para recogerla aunque aparezca ya superpuesta al Player.
- Puerta/reja:
  - se conserva PuertaJefeM1Bloqueo;
  - se desactiva al registrar la llave en GameManager;
  - no se modifican PasoPuertaWS ni OneWayPasoPuertaWS.
- Transición azul de Mundo 1:
  - movida después de la zona de la reja;
  - requiere la llave de Capitán;
  - al regresar desde Primer Boss usa SpawnSalida detrás de la puerta.
- attack 3:
  - giro detecta CollisionShape2D reales con una consulta física circular;
  - alcance simétrico delante/detrás;
  - mantiene daño progresivo;
  - puede recibir daño, pero no se interrumpe durante frames 0-17 del giro/windup;
  - la muerte sí interrumpe normalmente.

Pendientes posteriores ya reportados:
- Mundo 2: partes/elementos fuera de posición.
- Escaleras: animación/comportamiento claro al subir y bajar.
