"""Build, verify and render only the new room in an isolated Godot project.

Usage: python escenas/mapas/prologo/trono_gotico/pipeline.py <godot.exe> [--preview-only]
Never edits project.godot or existing maps, branches, index or real saves.
"""
from pathlib import Path
import json
import hashlib
import os
import re
import subprocess
import sys
import tempfile
import uuid

folder = Path(__file__).resolve().parent
root = folder.parents[3]
relative = folder.relative_to(root)
if (folder/'castillo_trono_gotico.tscn').exists() and not any(flag in sys.argv for flag in ['--rebuild','--art-only','--preview-only','--validate-only']):
    raise SystemExit('The editable room already exists. Use --validate-only or --preview-only. Regeneration requires explicit --rebuild and replaces manual edits to this new room.')
godot = Path(sys.argv[1]).resolve()
engine = Path(str(godot).replace('_console.exe', '.exe'))
if engine.exists():
    godot = engine
destination = Path(tempfile.mkdtemp(prefix='underkingdom-gothic-throne-'))
namespace = 'UnderkingdomGothicThroneValidation_' + uuid.uuid4().hex
files = subprocess.check_output(['git', 'ls-files', '-z', '--cached', '--others', '--exclude-standard'], cwd=root).decode().split('\0')
for name in files:
    source = root / name
    if not name or not source.is_file():
        continue
    target = destination / name
    target.parent.mkdir(parents=True, exist_ok=True)
    if source.suffix in ('.gd','.godot','.tscn','.tres','.import','.uid','.json','.log') or source.parent==folder:
        target.write_bytes(source.read_bytes())
    else:
        os.link(source,target)
for source in (root / '.godot').rglob('*'):
    if not source.is_file() or 'editor' in source.relative_to(root / '.godot').parts:
        continue
    target = destination / source.relative_to(root)
    target.parent.mkdir(parents=True, exist_ok=True)
    if source.suffix in ('.ctex','.fontdata'):
        os.link(source,target)
    else:
        target.write_bytes(source.read_bytes())
config = destination / 'project.godot'
config.write_text(config.read_text(encoding='utf-8').replace('config/name="UnderKingdom"','config/name="'+namespace+'"'),encoding='utf-8')
phases = [('build','construir_trono.gd',True),('validation','validar_trono.gd',True),('preview','previsualizar_trono.gd',False)]
if '--preview-only' in sys.argv:
    phases=phases[-1:]
if '--validate-only' in sys.argv:
    phases=phases[1:2]
if '--art-only' in sys.argv:
    phases=[phase for phase in phases if phase[0]!='validation']
results={'isolated_project':str(destination),'namespace':namespace,'phases':[]}
failed=False
print('Isolated project: '+str(destination),flush=True)
for label, script, headless in phases:
    log=folder/(label+'.log')
    args=['--headless'] if headless else ['--rendering-method','gl_compatibility']
    command=[str(godot),*args,'--path',str(destination),'--script','res://'+relative.as_posix()+'/'+script]
    with log.open('wb') as stream:
        process=subprocess.Popen(command,stdout=stream,stderr=subprocess.STDOUT)
        try:
            status=process.wait(timeout=100)
        except subprocess.TimeoutExpired:
            process.kill(); process.wait(); status=-1
    output=log.read_text(encoding='utf-8',errors='replace')
    errors=re.findall(r'^.*(?:SCRIPT ERROR:|ERROR:|Assertion failed).*$',output,re.M)
    passed=status==0 and not errors
    results['phases'].append({'name':label,'passed':passed,'exit_code':status,'errors':errors})
    summary=re.search(r'THRONE RESULT: (\d+) checks, (\d+) failures',output)
    if summary:
        results['phases'][-1]['checks']=int(summary[1])
        results['phases'][-1]['failures']=int(summary[2])
    print(label+': '+('PASS' if passed else 'FAIL')+'\n'+output[-7000:],flush=True)
    if label=='build' and passed:
        for filename in ['tileset_trono.tres','castillo_trono_gotico.tscn']:
            (folder/filename).write_bytes((destination/relative/filename).read_bytes())
    if label=='preview' and passed:
        # Copy the file rather than updating a hardlinked preview in place.
        source=destination/relative/'vista_general.png'
        if source.exists():
            (folder/'vista_general.png').write_bytes(source.read_bytes())
    if label=='validation' and passed:
        scene=(folder/'castillo_trono_gotico.tscn').read_text(encoding='utf-8')
        geometry={}
        for block in re.split(r'(?=\[node )',scene):
            if not block.startswith('[node '):
                continue
            name=re.search(r'name="([^"]+)"',block)[1]
            if name in ['Terreno','Plataformas','Peligros']:
                data=re.search(r'tile_map_data = (.+)',block)[1]
                geometry[name]=hashlib.sha256(data.encode()).hexdigest()
        (folder/'colisiones_aprobadas.json').write_text(json.dumps(geometry,indent=2)+'\n',encoding='utf-8')
    if not passed:
        failed=True
        break
report='validacion_visual.json' if '--art-only' in sys.argv or '--preview-only' in sys.argv else 'validacion.json'
(folder/report).write_text(json.dumps(results,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
sys.exit(1 if failed else 0)
