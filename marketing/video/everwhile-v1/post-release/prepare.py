"""Public storefront provenance and code-native QR assets; no credentials."""
from pathlib import Path
import hashlib, json, subprocess, os
import qrcode
from PIL import Image

here = Path(__file__).resolve().parent
root = here.parent
repo = root.parents[2]
out = here / 'outputs'
out.mkdir(exist_ok=True)
assets = here / 'assets'
assets.mkdir(exist_ok=True)
sha = lambda p: hashlib.sha256(p.read_bytes()).hexdigest()
evidence = {'checkedDate': '2026-11-23', 'appID': 6818551574, 'storefronts': {}}
agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/154.0.0.0 Safari/537.36'
def fetch(url):
    # Reuse host's existing network route. Direct mainland egress redirects US
    # pages to /cn/iphone/today; never count that generic HTTP200 as an app page.
    args = ['curl.exe', '-fLsS', '--proto', '=https', '--proto-redir', '=https',
            '--connect-timeout', '10', '--max-time', '35', '-A', agent,
            '--proxy', os.environ.get('EVERWHILE_PUBLIC_PROXY', 'http://127.0.0.1:10808'),
            '--noproxy', '', '-w', '\n__FETCH_META__%{http_code} %{url_effective}', url]
    result = subprocess.run(args, check=True, capture_output=True, timeout=45).stdout
    body, meta = result.rsplit(b'\n__FETCH_META__', 1)
    code, final = meta.decode().split(' ', 1)
    assert code == '200'
    return body, final
for lang, country in [('en', 'us'), ('zh-Hans', 'cn')]:
    lookup = f'https://itunes.apple.com/lookup?id=6818551574&country={country}'
    body, _ = fetch(lookup)
    data = json.loads(body)
    assert data['resultCount'] == 1
    app = data['results'][0]
    assert app['trackId'] == 6818551574 and app['bundleId'] == 'com.zhangsfish.elapse'
    assert app['trackName'] == 'Everwhile'
    url = f'https://apps.apple.com/{country}/app/everwhile/id6818551574'
    html, final = fetch(url)
    assert b'Everwhile' in html and '6818551574' in final
    qr = qrcode.QRCode(error_correction=qrcode.constants.ERROR_CORRECT_M, box_size=12, border=4)
    qr.add_data(url)
    qr.make(fit=True)
    qr.make_image(fill_color='black', back_color='white').convert('RGB').save(assets / f'qr-{lang}.png')
    evidence['storefronts'][lang] = {'lookupURL': lookup, 'url': url,
        'HTTPStatus': 200, 'resolvedURL': final, 'trackName': app['trackName'], 'bundleID': app['bundleId'],
        'version': app['version'], 'qrSHA256': sha(assets / f'qr-{lang}.png'),
        'qrModules': qr.modules_count, 'quietZoneModules': 4}
source = repo / 'store-assets/captures/zh-Hans/04-today.png'
crop = assets / 'today-zh-Hans.png'
Image.open(source).crop((200, 650, 1120, 1735)).convert('RGB').save(crop)
evidence['chineseToday'] = {'source': str(source.relative_to(repo)).replace('\\', '/'),
    'sourceSHA256': sha(source), 'cropLTRB': [200, 650, 1120, 1735], 'cropSHA256': sha(crop), 'repaint': False}
evidence['fontsLocalOnly'] = {str(p): sha(p) for p in [root/'assets/fonts/InterVariable.ttf', Path('C:/Windows/Fonts/msyh.ttc'), Path('C:/Windows/Fonts/msyhbd.ttc')]}
(here / 'PUBLIC_PROVENANCE.json').write_text(json.dumps(evidence, ensure_ascii=False, indent=2)+'\n', encoding='utf8')
print('Public US/CN listings verified; QR and exact Chinese crop prepared.')
