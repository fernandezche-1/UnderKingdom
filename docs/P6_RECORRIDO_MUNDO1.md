# Underkingdom — P6: recorrido de Mundo 1

Base oficial:
`UNDERKINGDOM_COMPLETO_P5_FIX_TEMBLOR_ESCALERA(1).zip`

## Cambios
- Corregido el carácter accidental antes de `extends Node2D` en `map_bounds.gd`.
- Salto: `jump_velocity` de -520 a -560.
- Cámara: se conserva la configuración P5 sin temblor y solo se baja 16 unidades.
- Escalera derecha: usa layer 2 y permite bajar con S/↓.
- Acceso a la puerta superior: se añadió una ClimbZone sobre el pilar de acceso.
  W/↑ sube, S/↓ baja y A/D corrige lateralmente.
- Las colisiones sólidas P5 no se redibujaron.

## Importante
No se modificaron los ajustes de smoothing/pixel snapping/floor snap que el usuario
confirmó que ya eliminaron el temblor.
