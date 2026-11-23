"""Decode actual movies; scan actual encoded QR, verify unmodified prefix/audio."""
from pathlib import Path
import subprocess, json, hashlib, io
import cv2
import numpy as np
from PIL import Image, ImageDraw, ImageFont

here=Path(__file__).resolve().parent; root=here.parent
out=here/'outputs'; tmp=here/'tmp'
ff='E:/video_to_md/readable-transcript/resource/bin/ffmpeg.exe'
fp=str(Path(ff).with_name('ffprobe.exe'))
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def cmd(args): return subprocess.check_output(args)
def frame(p,n):
    b=cmd([ff,'-v','error','-ss',f'{n/60:.9f}','-i',str(p),'-frames:v','1','-f','image2pipe','-vcodec','png','-'])
    return Image.open(io.BytesIO(b)).convert('RGB')
def audio(p): return cmd([ff,'-v','error','-i',str(p),'-map','0:a:0','-c','copy','-f','hash','-hash','sha256','-']).decode().strip()
def prefix(p):
    result=cmd([ff,'-v','error','-i',str(p),'-frames:v','930','-an','-f','framemd5','-']).decode()
    return [s.split(',')[-1].strip() for s in result.splitlines() if s and not s.startswith('#')]
approved=root/'review/director-r2/EVERWHILE_R2_EN_1080.mp4'
reference_audio=audio(approved); provenance=json.loads((here/'PUBLIC_PROVENANCE.json').read_text(encoding='utf8'))
report={'status':'PASS_TECHNICAL_ONLY','checkedDate':'2026-11-23','movies':[],
    'realTimePlayback':'NOT_RUN','subjectiveListening':'NOT_RUN','publicStorefronts':'PUBLIC_PROVENANCE.json'}
gallery=[]
for lang,key in [('en','EN'),('zh-Hans','ZH_HANS')]:
    target=provenance['storefronts'][lang]['url']
    for size in [1080,720]:
        p=out/f'EVERWHILE_{key}_{size}.mp4'
        probe=json.loads(cmd([fp,'-v','error','-count_frames','-show_streams','-show_format','-of','json',str(p)]))
        v=next(s for s in probe['streams'] if s['codec_type']=='video')
        assert (v['width'],v['height'],v['r_frame_rate'],v['nb_read_frames'])==(size,int(size*16/9),'60/1','1080')
        assert float(v['duration'])==18 and v['pix_fmt']=='yuv420p'
        subprocess.run([ff,'-v','error','-i',str(p),'-f','null','-'],check=True)
        audio_equal=audio(p)==reference_audio
        assert audio_equal
        audio_bytes=cmd([ff,'-v','error','-i',str(p),'-map','0:a:0','-f','f32le','-'])
        samples=np.frombuffer(audio_bytes,dtype='<f4'); assert np.isfinite(samples).all() and np.max(abs(samples))<1
        qrs=[]
        for n in [930,960,1079]:
            im=frame(p,n)
            payload,points,_=cv2.QRCodeDetector().detectAndDecode(cv2.cvtColor(np.asarray(im),cv2.COLOR_RGB2BGR))
            assert payload==target,(p,n,payload)
            qrs.append({'frame':n,'decoded':payload})
            if n==960 and size==1080:
                im.save(out/f'ENCODED_END_CARD_{key}.png'); gallery.append((key,im))
        # Low-resolution/recompression stress test, not a phone-camera guarantee.
        if size==720:
            compressed=tmp/f'{key}-540-crf28.mp4'
            subprocess.run([ff,'-v','error','-y','-ss','15.5','-i',str(p),'-t','1','-vf','scale=540:960:flags=lanczos','-c:v','libx264','-crf','28','-an',str(compressed)],check=True)
            im=frame(compressed,30)
            payload,_,_=cv2.QRCodeDetector().detectAndDecode(np.asarray(im))
            method='full-frame RGB'
            raw_ok=payload==target
            if not raw_ok:
                # Standard decoder preprocessing only; does not alter the film.
                gray=cv2.cvtColor(np.asarray(im),cv2.COLOR_RGB2GRAY)
                binary=cv2.threshold(gray,0,255,cv2.THRESH_BINARY+cv2.THRESH_OTSU)[1]
                payload,_,_=cv2.QRCodeDetector().detectAndDecode(binary)
                method='full-frame grayscale + Otsu threshold'
            assert payload==target
            qrs.append({'stress':'540x960 CRF28','decoded':payload,'method':method,'rawRGBSucceeded':raw_ok})
        report['movies'].append({'file':p.name,'sha256':sha(p),'bytes':p.stat().st_size,
            'width':v['width'],'height':v['height'],'fps':60,'frames':1080,'seconds':18,
            'fullDecode':'PASS','approvedAACPacketDataEqual':audio_equal,
            'decodedPeak':float(np.max(abs(samples))),'qrFromEncodedFrames':qrs})
    # Report comes from actual browser source frame, never repainted UI.
    p=out/f'EVERWHILE_{key}_1080.mp4'
    im=frame(p,840); im.save(out/f'TODAY_{key}.png')
    expected=Image.open(here/f'tmp/{lang}-840.png').convert('RGB')
    mae=float(np.mean(abs(np.asarray(im,dtype=float)-np.asarray(expected,dtype=float))))
    assert mae<8,mae
    report.setdefault('todayBrowserToEncodeMAE',{})[lang]=mae
en_prefix=prefix(out/'EVERWHILE_EN_1080.mp4'); source_prefix=prefix(approved)
assert len(en_prefix)==930 and en_prefix==source_prefix
report['englishFirst930DecodedFramesByteEqual']=True
report['audioPacketHash']=reference_audio
report['renderedCompositionSHA']='e32e85664cecbb406d0a584d32995c81369f12cc'
report['testedSHA']=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
crop=Image.open(here/'assets/today-zh-Hans.png').convert('RGB')
raw=Image.open(root.parents[2]/provenance['chineseToday']['source']).crop((200,650,1120,1735)).convert('RGB')
assert np.array_equal(np.asarray(crop),np.asarray(raw))
report['genuineChineseCropPixelEqual']=True
sheet=Image.new('RGB',(720,1320),'#e9edf4'); d=ImageDraw.Draw(sheet)
font=ImageFont.truetype(str(root/'assets/fonts/InterVariable.ttf'),22)
for i,(lang,im) in enumerate(gallery):
    d.text((i*360+16,18),lang,font=font,fill='#172128');sheet.paste(im.resize((360,640),Image.Resampling.LANCZOS),(i*360,60))
    # Two real product frames beneath the corresponding final card.
    p=out/f'EVERWHILE_{lang}_1080.mp4'
    for j,n in enumerate([480,840]):sheet.paste(frame(p,n).resize((180,320),Image.Resampling.LANCZOS),(i*360+j*180,730))
sheet=sheet.crop((0,0,720,1050));sheet.save(out/'BILINGUAL_REVIEW.jpg',quality=94)
(out/'TEST_RESULTS.json').write_text(json.dumps(report,ensure_ascii=False,indent=2)+'\n',encoding='utf8')
manifest={'files':[{'file':p.name,'sha256':sha(p),'bytes':p.stat().st_size} for p in sorted(out.iterdir()) if p.suffix in ['.mp4','.png','.jpg']]}
(out/'ARTIFACTS.json').write_text(json.dumps(manifest,indent=2)+'\n',encoding='utf8')
print('PASS: four18s films; actual encoded QR at1080/720/540; original930 EN frames/audio retained.')
