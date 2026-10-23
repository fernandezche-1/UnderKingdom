"""Run Godot regression checks in an isolated project and save namespace.

Usage: python tools/run_integration_validation.py <path-to-godot-console.exe>
The real project's saves and preferences are never loaded or changed.
"""
from pathlib import Path
import json
import os
import re
import subprocess
import sys
import tempfile
import uuid

root = Path(__file__).resolve().parents[1]
godot = Path(sys.argv[1]).resolve()
# Use the engine directly; the Windows console wrapper can leave a child after a timeout.
engine = Path(str(godot).replace('_console.exe', '.exe'))
if engine.exists():
    godot = engine
destination = Path(tempfile.mkdtemp(prefix='underkingdom-validation-'))
namespace = 'UnderkingdomIntegrationValidation_' + uuid.uuid4().hex
files = subprocess.check_output(
    ['git', 'ls-files', '-z', '--cached', '--others', '--exclude-standard'], cwd=root
).decode().split('\0')
for name in files:
    if not name:
        continue
    source = root / name
    if not source.is_file():
        continue
    target = destination / name
    target.parent.mkdir(parents=True, exist_ok=True)
    # Copy scripts/scenes/config, hardlink immutable assets to keep this lightweight.
    if source.suffix in ('.gd', '.godot', '.tscn', '.tres', '.import', '.uid'):
        target.write_bytes(source.read_bytes())
    else:
        os.link(source, target)
for source in (root / '.godot').rglob('*'):
    if not source.is_file() or 'editor' in source.relative_to(root / '.godot').parts:
        continue
    target = destination / source.relative_to(root)
    target.parent.mkdir(parents=True, exist_ok=True)
    if source.suffix in ('.ctex', '.fontdata'):
        os.link(source, target)
    else:
        target.write_bytes(source.read_bytes())
config_path = destination / 'project.godot'
config = config_path.read_text(encoding='utf-8')
config = config.replace('config/name="UnderKingdom"', 'config/name="' + namespace + '"')
config_path.write_text(config, encoding='utf-8')
resources = []
for name in files:
    if name.endswith(('.gd', '.tscn', '.tres')):
        resources.append('res://' + name)
(destination / 'validation_resources.json').write_text(json.dumps(resources), encoding='utf-8')
commands = [
    ('regressions', ['--script', 'res://tools/validate_integration.gd']),
    ('editable_castle', ['--script', 'res://tools/validate_castillo_editable.gd']),
    ('main_menu', ['--quit-after', '8']),
]
visibility_only = '--visibility' in sys.argv[2:]
preview_only = '--preview' in sys.argv[2:]
if visibility_only:
    commands = [('visibility', ['--script', 'res://tools/validate_edwin_visibility.gd'])]
if preview_only:
    commands = [('preview', ['--script', 'res://tools/preview_edwin_menus.gd'])]
display_args = ['--headless'] if not preview_only else ['--rendering-method', 'gl_compatibility']
failed = False
results = {'isolated_project': str(destination), 'save_namespace': namespace, 'checks': []}
print('Isolated project: ' + str(destination), flush=True)
for label, args in commands:
    log = root / 'docs' / ('integracion_edwin_047_' + label + '.log')
    try:
        with log.open('wb') as stream:
            process = subprocess.Popen([str(godot), *display_args, '--path', str(destination), *args], stdout=stream, stderr=subprocess.STDOUT)
            try:
                returncode = process.wait(timeout=300)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
                raise
        output = log.read_text(encoding='utf-8', errors='replace')
        # Non-zero process status is insufficient: Godot may log script errors and exit 0.
        errors = re.findall(r'^.*(?:SCRIPT ERROR:|ERROR:|Assertion failed).*$' , output, re.M)
        passed = returncode == 0 and not errors
        results['checks'].append({'name': label, 'passed': passed, 'exit_code': returncode, 'errors': errors, 'log': str(log)})
        print(f'{label}: {"PASS" if passed else "FAIL"}', flush=True)
        print(output[-9000:], flush=True)
        failed |= not passed
    except subprocess.TimeoutExpired as error:
        output = log.read_text(encoding='utf-8', errors='replace')
        results['checks'].append({'name': label, 'passed': False, 'error': 'timeout', 'log': str(log)})
        print(label + ': TIMEOUT\n' + output[-9000:], flush=True)
        failed = True
report_name = 'edwin_visibility_validation.json' if visibility_only else 'edwin_preview_validation.json' if preview_only else 'integracion_edwin_047_validation.json'
if preview_only:
    for source in destination.glob('edwin_preview_*.png'):
        (root / 'docs' / source.name).write_bytes(source.read_bytes())
(root / 'docs' / report_name).write_text(json.dumps(results, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print('Artifacts: ' + str(destination), flush=True)
sys.exit(1 if failed else 0)
