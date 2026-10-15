# UnderKingdom 0.04.037

Reconstruida desde el `UnderKingdom.zip` suministrado por el usuario, no desde 0.04.036.

Cambios de Mundo 1:
- Checkpoint previo al Capitán en el Area2D colocado por el usuario.
- Barrera de la arena: abierta antes de entrar, se cierra al activar el checkpoint y se abre al derrotar al Capitán.
- Aprendis de la plataforma previa al jefe con gravedad, control de borde y patrulla corta.
- Caja rompible con cuatro estados y drop de una moneda.
- Dos estatuas rompibles con cuatro estados y escombros persistentes.
- Ataque 3 reconoce objetos del grupo `breakable`.
- GameManager incorpora contador básico de monedas para los drops.
- En escaleras, el Player usa la animación `run` reducida de velocidad para evitar que se vea demasiado grande.

Sistema reutilizable de escalera conservado en:
- `scripts/environment/climb_zone.gd`
- `escenas/sistemas/climb_zone.tscn`

El proyecto se entrega sin `.git` ni `.godot` para poder importarlo como copia independiente en Godot.
