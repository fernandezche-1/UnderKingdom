# UnderKingdom 0.04.040

## Capitán: fase 2/3 más agresiva
- Fase 1 conserva velocidad normal.
- Fase 2: animaciones de ataque a 1.30x y cooldown al 72%.
- Fase 3: animaciones de ataque a 1.50x y cooldown al 58%.
- Las ventanas de daño siguen sincronizadas con la animación acelerada.

## Capitán: respuesta anti-spam
- El Player envía al jefe un identificador por cada ejecución de ataque.
- `attack`, `attack 2` y `attack 3` cuentan como ataques básicos.
- Los múltiples impactos internos de una misma animación cuentan una sola vez.
- 4 ataques básicos conectados dentro de 1.6 s activan 1.15 s de inmunidad total.
- Durante esa inmunidad el Capitán usa su animación de defensa y no ataca.
- Tras activarse, existe un cooldown adicional de 3.5 s antes de poder responder otra vez al spam.
- Ultimate y roll conservan sus inmunidades anteriores.
