"""Freeze R2 derivatives: no painting of actual Today capture."""
from pathlib import Path
import hashlib, json, subprocess
from PIL import Image
root=Path(__file__).resolve().parents[1];out=root/'assets/r2';out.mkdir(parents=True,exist_ok=True)
ffmpeg='E:/video_to_md/readable-transcript/resource/bin/ffmpeg.exe'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def transcode(source,target,vf):
    subprocess.run([ffmpeg,'-v','error','-y','-i',str(source),'-t','6','-an','-vf',vf,'-c:v','libx264','-crf','16','-preset','fast','-g','1','-pix_fmt','yuv420p','-movflags','+faststart',str(target)],check=True)
drama=root/'tmp/drama-source.mp4';coffee=root/'tmp/coffee-source.mp4'
assert sha(drama)=='f2985790a1a31253e90667394c6c1f80348f41cc04c7541bc768861bf08bdd57'
assert sha(coffee)=='f2ca77f0df0a2efc534e262380d9c4b8e8fe08a69d50329d04244da44f969dcd'
transcode(drama,out/'drama.mp4','crop=608:1080:530:0,scale=1080:1920:flags=lanczos,fps=60')
transcode(coffee,out/'coffee.mp4','scale=1080:1920:flags=lanczos,fps=60')
for name in ['drama','coffee']:
    subprocess.run([ffmpeg,'-v','error','-y','-ss','1.2','-i',str(out/(name+'.mp4')),'-frames:v','1',str(out/(name+'.jpg'))],check=True)
social=root/'tmp/social-source.jpg';Image.open(social).convert('RGB').save(out/'social.jpg',quality=97,subsampling=0)
raw=root/'assets/reference/today-quick-start.png';crop=[200,650,1120,1735]
Image.open(raw).crop(crop).save(out/'today-detail.png')
m={'privateData':[],'today':{'source':'assets/reference/today-quick-start.png','sourceSHA256':sha(raw),'cropLTRB':crop,'output':'assets/r2/today-detail.png','outputSHA256':sha(out/'today-detail.png'),'repaint':False,'displayWidth':800,'uniformScale':800/920,'exampleValues':['30m','App A','20m','App B','10m']},
'sources':[
{'name':'drama','sourceSHA256':sha(drama),'creator':'RDNE Stock project','url':'https://www.pexels.com/video/couple-having-a-intense-conversation-in-front-of-the-door-5617887/','native':'1920×1080, 24fps family','derivative':'crop=608:1080:530:0; Lanczos1080×1920; repeats to60fps'},
{'name':'coffee','sourceSHA256':sha(coffee),'creator':'Michael Burrows','url':'https://www.pexels.com/video/pouring-black-coffee-into-a-cup-7118100/','native':'2160×3840,25fps','derivative':'Lanczos1080×1920; repeats to60fps'},
{'name':'social','sourceSHA256':sha(social),'creator':'kaya Yu','url':'https://www.pexels.com/photo/street-in-city-in-sunlight-16249816/','download':'https://images.pexels.com/photos/16249816/pexels-photo-16249816.jpeg?cs=srgb&dl=pexels-kaya-yu-505472119-16249816.jpg&fm=jpg','native':list(Image.open(social).size),'derivative':'RGB JPEG97; city photograph; no account data'}],
'license':{'url':'https://www.pexels.com/license/','checked':'2026-10-07','use':'free commercial editing; no endorsement or negative actor attribution'},
'files':[{'file':p.relative_to(root).as_posix(),'sha256':sha(p),'bytes':p.stat().st_size} for p in sorted(out.iterdir()) if p.is_file()],
'audioFrozen':[{'file':'review/'+n,'sha256':sha(root/'review'/n)} for n in ['music.wav','sfx.wav','mix.wav']]}
(root/'ASSET_MANIFEST_R2.json').write_text(json.dumps(m,indent=2)+'\n',encoding='utf8')
print('R2 native derivatives and exact UI crop frozen.')
