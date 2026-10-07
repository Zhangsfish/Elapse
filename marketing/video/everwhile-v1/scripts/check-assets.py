"""Standard-library-only immutable artifact gate for ordinary CI."""
from pathlib import Path
import hashlib, json, wave, subprocess

root=Path(__file__).resolve().parents[1]
manifest=json.loads((root/'ASSET_MANIFEST.json').read_text(encoding='utf8'))
assert manifest['privateData']==[]
for asset in manifest['assets']:
    if asset['file'].startswith('assets/fonts/'):
        assert asset['redistributed'] is False
        continue
    p=root/asset['file']
    assert p.is_file(),str(p)
    assert hashlib.sha256(p.read_bytes()).hexdigest()==asset['sha256'],str(p)
for name in ['music.wav','sfx.wav','mix.wav']:
    with wave.open(str(root/'review'/name)) as w:
        assert w.getnframes()==864000
        assert w.getframerate()==48000
        assert w.getnchannels()==2
        assert w.getsampwidth()==2
tracked=subprocess.check_output(['git','ls-files','--','marketing/video/everwhile-v1/assets/fonts'],cwd=root, text=True)
assert not any(p.lower().endswith(('.ttf','.otf','.woff','.woff2')) for p in tracked.splitlines())
artifacts=root/'review/ARTIFACTS.json'
if artifacts.exists():
    for artifact in json.loads(artifacts.read_text(encoding='utf8'))['files']:
        p=root/artifact['file']
        assert hashlib.sha256(p.read_bytes()).hexdigest()==artifact['sha256'],str(p)
print('PROMO-P01 immutable sources / no-private-data / 48k stems PASS')
