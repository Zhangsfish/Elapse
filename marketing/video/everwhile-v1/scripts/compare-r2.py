"""Actual encoded old/new synchronized comparison, equal360×640 columns."""
from pathlib import Path
import subprocess,hashlib,json
from PIL import Image,ImageDraw,ImageFont
root=Path(__file__).resolve().parents[1];out=root/'review/director-r2';tmp=root/'tmp'
ff='E:/video_to_md/readable-transcript/resource/bin/ffmpeg.exe';fp='E:/video_to_md/readable-transcript/resource/bin/ffprobe.exe'
old=root/'review/EVERWHILE_P01_EN_720.mp4';new=out/'EVERWHILE_R2_EN_1080.mp4'
banner=Image.new('RGB',(720,40),'#e9edf4');d=ImageDraw.Draw(banner);font=ImageFont.truetype(str(root/'assets/fonts/InterVariable.ttf'),20)
d.text((12,8),'P01 · encoded',font=font,fill='#172128');d.text((372,8),'R2 · encoded',font=font,fill='#172128');banner.save(tmp/'compare-banner.png')
target=out/'OLD_VS_NEW_EN.mp4'
subprocess.run([ff,'-v','error','-y','-i',str(old),'-i',str(new),'-loop','1','-framerate','60','-i',str(tmp/'compare-banner.png'),'-filter_complex','[0:v]scale=360:640:flags=lanczos[l];[1:v]scale=360:640:flags=lanczos[r];[l][r]hstack=inputs=2[p];[2:v][p]vstack=inputs=2[v]','-map','[v]','-map','1:a:0','-t','18','-r','60','-c:v','libx264','-preset','fast','-crf','18','-pix_fmt','yuv420p','-c:a','copy','-movflags','+faststart',str(target)],check=True)
subprocess.run([ff,'-v','error','-i',str(target),'-f','null','-'],check=True)
probe=json.loads(subprocess.check_output([fp,'-v','error','-count_frames','-show_streams','-of','json',str(target)]));v=probe['streams'][0]
assert (v['width'],v['height'],int(v['nb_read_frames']))==(720,680,1080) and float(v['duration'])==18
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
(out/'COMPARISON_QA.json').write_text(json.dumps({'oldSHA256':sha(old),'newSHA256':sha(new),'outputSHA256':sha(target),'displayColumns':[360,640],'output':[720,680],'frames':1080,'seconds':18,'audio':'new film approved mix only; copied AAC','subjectiveViewing':'NOT_RUN'},indent=2)+'\n',encoding='utf8')
m=json.loads((out/'ARTIFACTS.json').read_text());relative=target.relative_to(root).as_posix();m['files']=[item for item in m['files'] if item['file']!=relative];m['files'].append({'file':relative,'sha256':sha(target),'bytes':target.stat().st_size});(out/'ARTIFACTS.json').write_text(json.dumps(m,indent=2)+'\n',encoding='utf8')
print('Actual encoded old/new comparison movie complete,18s/1080f.')
