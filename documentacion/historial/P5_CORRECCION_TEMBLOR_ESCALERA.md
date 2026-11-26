# Underkingdom — P5: corrección de temblor y escalera de Mundo 1

## Temblor al caminar

Se corrigieron tres posibles causas combinadas:

1. El `floor_snap_length` bajó de 12 px a 4 px.
2. La Camera2D dejó de usar smoothing de posición y se sincroniza con física.
3. Se activó pixel snapping 2D a nivel de proyecto.

También se redujo `safe_margin` del CharacterBody2D a 0.02.

Esto busca evitar que las pequeñas variaciones de los CollisionPolygon2D y el
movimiento subpíxel hagan que el Player/cámara parezca vibrar mientras camina.

## Escalera derecha de Mundo 1

La colisión original `ColisionPoligono_03` coincide con la escalera mostrada en
la captura (aprox. x=1498..1650, y=483..614).

No se eliminó ni redibujó la geometría hecha por el usuario. Se cambió únicamente
a colisión One Way:

- se puede atravesar desde abajo;
- se puede apoyar/caminar sobre su superficie;
- mantiene la forma original de la escalera.

Se aumentó además el ángulo máximo de piso del Player a 65°.

## Pendiente

La transición azul exacta al siguiente mapa sigue sin colocarse hasta usar la
marca visual exacta del usuario. La infraestructura de transiciones P4 se conserva.
