#!/usr/bin/env bash
# Fase 2 de TASK.md en modo autónomo: lanza Claude Code una vez por pieza, cada
# una con el contexto limpio, hasta que no quedan piezas o una no avanza.
#
# Uso, desde la raíz del proyecto y en una rama propia:
#   git switch -c edwin/fase-2-auto
#   bash herramientas/fase2_auto.sh
#
# Antes: docs/FASE2_DECISIONES.md tiene que decir "Estado: APROBADO".
# Registro de cada pieza en .fase2_logs/ (fuera de git). Para pararlo entre
# piezas: touch .fase2_stop
set -u
cd "$(dirname "$0")/.."

MAX_PIEZAS="${MAX_PIEZAS:-30}"
LOG_DIR=".fase2_logs"

CLAUDE_BIN="${CLAUDE_BIN:-$(command -v claude || true)}"
if [ -z "$CLAUDE_BIN" ]; then
  CLAUDE_BIN="$(ls -d "$HOME"/.vscode/extensions/anthropic.claude-code-*/resources/native-binary/claude 2>/dev/null | sort -V | tail -1)"
fi
if [ -z "$CLAUDE_BIN" ] || [ ! -x "$CLAUDE_BIN" ]; then
  echo "No encuentro el ejecutable de Claude Code. Pon su ruta en CLAUDE_BIN." >&2
  exit 1
fi

if ! grep -q '^\*\*Estado: APROBADO\*\*\|^Estado: APROBADO' docs/FASE2_DECISIONES.md; then
  echo "docs/FASE2_DECISIONES.md no está aprobado. Revísalo y pon 'Estado: APROBADO'." >&2
  exit 1
fi

rama="$(git branch --show-current)"
if [ "$rama" = "main" ]; then
  echo "Estás en main. Crea una rama antes: git switch -c edwin/fase-2-auto" >&2
  exit 1
fi

# Los registros y las marcas no ensucian git.
for patron in "$LOG_DIR/" ".fase2_fin" ".fase2_stop"; do
  grep -qxF "$patron" .git/info/exclude 2>/dev/null || echo "$patron" >> .git/info/exclude
done
mkdir -p "$LOG_DIR"
rm -f .fase2_stop

# Piezas sin marcar de la Fase 2, sin contar el arte con IA (no se hace solo).
pendientes() {
  awk '/^## Fase 2/,/^## Fase 3/' TASK.md | grep '^- \[ \]' | grep -vc 'Arte con IA'
}

read -r -d '' PROMPT <<'EOF'
Tarea: Fase 2 de TASK.md, en modo autónomo. Haz UNA sola pieza: la siguiente
sin marcar ("- [ ]"), en este orden:
1. las listas numeradas 1 a 7 de la Fase 2, en orden, pero al empezar el paso 4
   (Minas) haz antes la pieza de atuendos "Atuendo actual y OUTFIT_DEFINITIONS"
   (docs/FASE2_DECISIONES.md, G2);
2. después, el resto de piezas de "En paralelo: atuendos", menos "Arte con IA",
   que no se hace en este modo.
Si ya no queda ninguna, crea el archivo .fase2_fin y termina sin hacer nada más.

Antes de escribir código, lee:
- CLAUDE.md (reglas del proyecto, combate, validar cambios);
- docs/FASE2_DECISIONES.md entero: manda sobre lo que tú supondrías;
- en TASK.md, la línea de la pieza y el criterio de "hecho" de la Fase 2;
- docs/P46_MACRO_MAPA.md, secciones 5, 6 y 10, y lo que diga de la pieza la
  cabecera del ASCII de cada zona que la usa (mapas_texto/macro/zonas/);
- docs/P43_ZONA_DE_PRUEBAS.md y la última etapa de docs/ (P48 o posterior),
  como modelo de formato;
- los scripts y escenas que ya hacen algo parecido, para reutilizarlos en vez
  de duplicarlos (locked_door.gd, arena_barrier.gd, boss_arena.gd,
  breakable_object.gd, story_hidden_actor.gd, npc.gd, GameManager…), y las
  piezas que ya hicieron las sesiones anteriores (git log).

Cómo trabajar (no hay nadie para aprobar nada, así que no esperes respuesta):
- Static typing en todo el GDScript. Daño y curación en múltiplos de 0.25.
  Pixel art a escala entera y texto con el tema global (CLAUDE.md).
- Una pieza genérica y configurable desde el editor, que sirva a todas las
  zonas que la piden.
- No toques los mapas de la ruta (tiles_* y sus _combate) ni los ASCII de
  mapas_texto/macro/: la pieza se monta en las zonas en la Fase 3. Sí puedes
  editar la zona de pruebas (zona_pruebas_combate.tscn y, si lleva letra, su
  .txt). No toques los ajustes del temblor al caminar.
- Si falta arte, usa uno provisional que ya exista y apúntalo como pendiente.
- Si necesitas una decisión que no está en docs/FASE2_DECISIONES.md ni en P46,
  elige la opción más conservadora y coherente con P46 y apúntala al final de
  docs/FASE2_DECISIONES.md, en "Decisiones tomadas durante la ejecución"
  (pieza, decisión, alternativa, por qué).
- Si la pieza no se puede terminar cumpliendo el criterio de "hecho" (una
  prueba que no pasa, algo que contradice los documentos, algo que pide
  tocar colisiones validadas o mapas de la ruta), no la fuerces: deja el
  árbol como estaba, marca la pieza "- [~]" en TASK.md, apunta el motivo en
  "Piezas bloqueadas" de docs/FASE2_DECISIONES.md y haz un commit solo con
  esos dos archivos.
- Godot está en ~/.local/bin/godot (no en el PATH de bash).

Al terminar, cumple el criterio de "hecho" de la Fase 2 de TASK.md: prueba en
la zona de pruebas, prueba sin ventana con escena temporal (bórrala),
arranques sin errores (juego, zona de pruebas y mundo_1 si tocaste Player,
enemigos, GameManager o el Capitán), guardado si aplica, etapa nueva en docs/
(la siguiente P libre), P46 secciones 5 y 10, CLAUDE.md si cambia una regla o
una pieza a reutilizar, la pieza marcada "- [x]" en TASK.md con su escena y su
etapa, y UN commit sin push. El árbol de git tiene que quedar limpio.
No añadas líneas Co-Authored-By de Claude al commit.

Termina con un resumen de 5 líneas como mucho: pieza, archivos, pruebas,
decisiones nuevas y lo que quede pendiente.
EOF

n=0
while :; do
  if [ -f .fase2_fin ]; then echo "Fase 2 terminada (.fase2_fin)."; break; fi
  if [ -f .fase2_stop ]; then echo "Parado a petición (.fase2_stop)."; break; fi
  antes=$(pendientes)
  if [ "$antes" -eq 0 ]; then echo "No quedan piezas sin marcar."; break; fi
  if [ "$n" -ge "$MAX_PIEZAS" ]; then echo "Tope de $MAX_PIEZAS piezas."; break; fi
  if [ -n "$(git status --porcelain)" ]; then
    echo "El árbol de git no está limpio; revísalo antes de seguir." >&2; break
  fi

  n=$((n + 1))
  log="$LOG_DIR/$(date +%Y%m%d-%H%M%S)_pieza$n.txt"
  commit_antes=$(git rev-parse HEAD)
  echo "[$(date +%H:%M)] Pieza $n (quedan $antes). Registro: $log"

  "$CLAUDE_BIN" -p "$PROMPT" \
    --permission-mode auto \
    --allowedTools "Read" "Edit" "Write" "Grep" "Glob" \
      "Bash(~/.local/bin/godot:*)" "Bash($HOME/.local/bin/godot:*)" \
      "Bash(git status:*)" "Bash(git diff:*)" "Bash(git log:*)" \
      "Bash(git show:*)" "Bash(git add:*)" "Bash(git commit:*)" \
      "Bash(python3:*)" "Bash(ls:*)" "Bash(grep:*)" \
      "Bash(sed:*)" "Bash(awk:*)" "Bash(cat:*)" "Bash(find:*)" \
    --disallowedTools "Bash(git push:*)" "Bash(git reset:*)" \
      "Bash(git checkout:*)" "Bash(git switch:*)" "Bash(git rebase:*)" \
    > "$log" 2>&1
  estado=$?

  tail -n 8 "$log"
  despues=$(pendientes)
  if [ "$estado" -ne 0 ]; then
    echo "Claude Code salió con error ($estado). Mira $log" >&2; break
  fi
  if [ "$(git rev-parse HEAD)" = "$commit_antes" ] || [ "$despues" -ge "$antes" ]; then
    echo "La pieza $n no avanzó (sin commit o sin marcar). Mira $log" >&2; break
  fi
done

echo
echo "Commits de esta ejecución:"
git log --oneline "@{u}..HEAD" 2>/dev/null || git log --oneline -n "$n"
grep -c '^- \[~\]' TASK.md >/dev/null 2>&1 && \
  echo "Piezas bloqueadas: $(grep -c '^- \[~\]' TASK.md) (ver docs/FASE2_DECISIONES.md)"
