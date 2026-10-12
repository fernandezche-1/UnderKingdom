# P7 — Combate y prioridades

## Player
Animaciones existentes conectadas:
- attack
- attack 2
- attack 3
- air attack
- defende
- roll
- attack ultimate

El Hitbox aplica daño durante la parte central de cada animación y cada objetivo
recibe un solo golpe por etapa del combo.

## Defensa
Q o click derecho: reduce el daño recibido en 65 %.

## Roll
Shift: reproduce `roll` y concede invulnerabilidad durante la mayor parte de la animación.

## Ultimate
E: reproduce `attack ultimate`, aumenta temporalmente el alcance y causa más daño.
Cooldown inicial: 6 segundos.

## Enemigos de prueba
`aprendis.tscn` y `vanguardia.tscn` ahora pueden:
- recibir daño;
- recibir knockback;
- reproducir take hit / take hiit;
- morir;
- desaparecer al ser derrotados.

## Prioridad siguiente
1. Validar combo / Hitbox / roll / defensa / Ultimate.
2. IA base con detección izquierda/derecha y ataque.
3. Hitbox de enemigos para dañar al Player.
4. Checkpoints.
5. Transición real Mundo 1 -> Primer Boss.
6. Jefes y sus tres fases.
