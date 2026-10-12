# Underkingdom — P2 Player de prueba

Esta versión agrega un Player funcional para probar el mapa jugando.

## Controles

- `A / D` o flechas izquierda/derecha: movimiento
- `Espacio`, `W` o flecha arriba: salto
- `H`: quita 0.25 de corazón (prueba del futuro BurnZone)
- `K`: muerte inmediata
- `R`: reaparecer manualmente

## Qué puede probarse ya

- Colisiones sólidas de Mundo 1.
- Gravedad, desplazamiento y salto.
- Cámara que sigue al personaje (la que ya estaba en Mundo 1).
- Muerte y respawn.
- KillZone de caída real colocada debajo de Mundo 1.
- Sistema de vida en cuartos de corazón mediante la tecla H.
- Animaciones idle/run/jump/take hit/death del Fire Knight existente.

## Respawn

El Player guarda como respawn la posición en la que aparece al iniciar la escena.
Al morir vuelve a ese punto con la vida completa.

## Aún pendiente

- Colocar las KillZones rojas/rosadas exactas según las marcas visuales.
- Colocar los BurnZones blancos exactos.
- Convertir las plataformas verdes concretas a One Way.
- Coyote time, jump buffer, wall slide/wall jump, roll, defensa y ataques.
- Player de prueba dentro de cada mapa; por ahora la prueba principal se realiza en Mundo 1, que es la escena inicial.
