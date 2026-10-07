"""Internal gate: native style proofs versus actual encoded P01, equal scale."""
from pathlib import Path
import subprocess
from PIL import Image,ImageDraw,ImageFont
root=Path(__file__).resolve().parents[1];out=root/'review/director-r2'
ff='E:/video_to_md/readable-transcript/resource/bin/ffmpeg.exe'
tmp=root/'tmp/style-proof';tmp.mkdir(parents=True,exist_ok=True)
indices=[30,480,840]
subprocess.run([ff,'-v','error','-y','-i',str(root/'review/EVERWHILE_P01_EN_720.mp4'),'-vf','select='+'+'.join('eq(n\\,%d)'%f for f in indices),'-fps_mode','vfr',str(tmp/'%02d.png')],check=True)
canvas=Image.new('RGB',(720,3*680),'#e9edf4');d=ImageDraw.Draw(canvas)
font=ImageFont.truetype(str(root/'assets/fonts/InterVariable.ttf'),20)
for i,f in enumerate(indices):
    y=i*680;d.text((12,y+10),f'P01 encoded / {f/60:.1f}s',font=font,fill='#172128');d.text((372,y+10),f'R2 native style / {f/60:.1f}s',font=font,fill='#172128')
    for x,p in [(0,tmp/('%02d.png'%(i+1))),(360,out/'frames'/('%04d.png'%f))]:
        canvas.paste(Image.open(p).convert('RGB').resize((360,640),Image.Resampling.LANCZOS),(x,y+40))
canvas.save(out/'STYLE_PROOFS_EN.jpg',quality=93,subsampling=0)
print('3 native1080 proofs; P01 actual encode equal360×640 comparison.')
