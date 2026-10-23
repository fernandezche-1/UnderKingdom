"""Read-only branch/dependency audit; writes a reviewable integration report."""
from pathlib import Path
import collections
import json
import re
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]


def git(*args):
    return subprocess.check_output(['git', *args], cwd=root)


base = git('merge-base', 'v4', 'origin/edwin/integrar-0.04.047').decode().strip()
ours = set(git('diff', '--no-renames', '--name-only', base, 'v4').decode().splitlines())
theirs = set(git('diff', '--no-renames', '--name-only', base, 'origin/edwin/integrar-0.04.047').decode().splitlines())
shared = sorted(ours & theirs)
conflicts = []
with tempfile.TemporaryDirectory() as temp:
    for name in shared:
        blobs = []
        for ref in ['v4', base, 'origin/edwin/integrar-0.04.047']:
            blobs.append(git('show', ref + ':' + name))
        if any(b'\0' in data for data in blobs):
            conflicts.append({'path': name, 'type': 'binary'})
            continue
        paths = []
        for index, data in enumerate(blobs):
            path = Path(temp) / str(index)
            path.write_bytes(data.replace(b'\r\n', b'\n'))
            paths.append(str(path))
        result = subprocess.run(['git', 'merge-file', '-p', *paths], capture_output=True)
        if result.returncode:
            conflicts.append({'path': name, 'type': 'text', 'regions': result.returncode})
files = git('ls-files', '-z', '--cached', '--others', '--exclude-standard').decode().split('\0')
missing = []
uids = collections.defaultdict(list)
for name in files:
    path = root / name
    if not name or not path.is_file():
        continue
    if name.endswith('.gd.uid'):
        uids[path.read_text().strip()].append(name)
    if path.suffix not in ('.gd', '.tscn', '.tres', '.godot'):
        continue
    text = path.read_text(encoding='utf-8-sig')
    for reference in re.findall(r'["\'](res://[^"\'\n]+)["\']', text):
        if reference == 'res://validation_resources.json':
            continue  # Generated only in the isolated test project.
        if reference == 'res://mapas_texto/paleta_niveles':
            continue  # Output prefix; the constructor appends .png and .gpl.
        if '%' in reference or reference.endswith('/') or '*' in reference:
            continue
        if not (root / reference.removeprefix('res://')).exists():
            missing.append({'source': name, 'reference': reference})
geometry = []
for name in sorted(files):
    if not re.match(r'escenas/mapas/tiles_[^/]+\.tscn$', name) or name.endswith('_combate.tscn'):
        continue
    before = git('show', 'v4:' + name).decode().replace('\r\n', '\n')
    after = (root / name).read_text(encoding='utf-8')
    normalize = lambda s: re.sub(r'(target_scene_path = "res://escenas/mapas/tiles_\w+)_combate(\.tscn")', r'\1\2', s)
    geometry.append({'path': name, 'unchanged_except_transition_targets': normalize(before) == normalize(after)})
report = {
    'branch': git('branch', '--show-current').decode().strip(),
    'shared_files': shared, 'predicted_git_conflicts': conflicts,
    'branch_comparison_v4_to_edwin': [dict(zip(['status', 'path'], line.split('\t', 1))) for line in git('diff', '--no-renames', '--name-status', 'v4', 'origin/edwin/integrar-0.04.047').decode().splitlines()],
    'unresolved_git_entries': git('ls-files', '-u').decode().splitlines(),
    'missing_literal_resources': missing,
    'duplicate_script_uids': [names for names in uids.values() if len(names) > 1],
    'existing_map_geometry': geometry,
    'working_changes': git('-c', 'core.quotepath=false', 'status', '--short', '--untracked-files=all').decode().splitlines(),
}
target = root / 'docs/integracion_edwin_047_audit.json'
target.write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(json.dumps({key: report[key] for key in ['shared_files', 'predicted_git_conflicts', 'missing_literal_resources', 'duplicate_script_uids', 'existing_map_geometry']}, ensure_ascii=False, indent=2))
