# P44 - Daño por contacto

- Hasta ahora un enemigo solo hacía daño con la ventana de golpe de su ataque. Ahora también al tocarlo.

## 1. Cuánto quita

| Quién | `contact_damage` |
|---|---|
| Enemigos normales, Carcelero y Rey Caído | 0.25 (valor por defecto) |
| Capitán, Caballero de la Reina, Reina, Guardián de hielo, Demon Slime y Cthulhu | 0.5 |

- El Rey Caído se queda en 0.25 porque su ataque quita 0.5: el contacto no debe valer lo mismo que un golpe.
- Sin espada se suma `unarmed_extra_damage_taken`, como en todo golpe: 0.5 con la mayoría y 0.75 con los jefes. En el calabozo, cada toque de una rata quita medio corazón.
- `contact_damage = 0` quita el contacto a un enemigo.

## 2. Cómo funciona

- `enemy_base.gd` crea un `ContactArea` con la forma del cuerpo, `contact_margin` (2 px) más grande. Hace falta el margen: los cuerpos chocan y nunca llegan a solaparse.
- Tras dañar, ese enemigo espera `contact_cooldown` (0.9 s). La invulnerabilidad del Player dura 0.45 s y no bastaría contra una pared.
- El daño pasa por `take_contact_damage_from` del Player, no por `take_damage_from`.

## 3. Cuándo no hace daño

- El enemigo:
  - está quieto por una cinemática (`ai_enabled` en falso);
  - está atacando: la invulnerabilidad del contacto se tragaría el golpe, que quita más;
  - está aturdido;
  - duerme o está saliendo de la tierra (`rising_enemy.gd`).
- El Player:
  - se cubre: no gasta guardia ni hace parry, porque si no bastaría pegarse al enemigo para aturdirlo;
  - rueda, de principio a fin, también en el 18 % final que no da invulnerabilidad;
  - ataca: el paso adelante del tajo lo mete en el enemigo y, sin esta regla, la rata cortaba el tajo antes de que conectara.
- Cualquier estado de invulnerabilidad del Player (cinemáticas, Ultimate) también lo evita, porque acaba en `take_damage`.

## 4. Pruebas

- Escena temporal, sin ventana, caminando contra 25 enemigos y jefes con los ataques apagados:
  - con el retroceso apagado, 24 hacen daño al tocarlos;
  - el Caballero de la Reina (`w2_archer_boss.gd`) tiene movimiento propio y se escapó en todas las pasadas, así que su contacto no se comprobó;
  - con 6 s de empujar a una rata, sale un daño cada 54 cuadros (0.9 s);
  - el tajo conecta desde la distancia a la que se paran rata, esqueleto, Guardia, slime y mino.
- Arrancan sin errores el menú, calabozo, castillo, cementerio, minas, `tiles_jefe_combate`, la zona de pruebas y `mundo_1`.

## 5. Pendiente

- En un pasillo plano y sin paredes, varios enemigos con `_chase_target` se alejan al acercarse el Player y no se les alcanza corriendo en línea recta: esqueleto de lanza, Guardia, Carcelero, Aprendis, diablillo, Vanguardia, Reina y Capitán. Con el retroceso apagado sí tocan, y falta probar con ventana cómo se siente acorralándolos.
