"""Validate/decode delivered R2 movies and derive evidence from actual encodes."""
from pathlib import Path
import hashlib,json,subprocess,os,wave
import numpy as np
from PIL import Image,ImageDraw,ImageFont
root=Path(__file__).resolve().parents[1];out=root/'review/director-r2';tmp=root/'tmp/encoded-r2';tmp.mkdir(parents=True,exist_ok=True)
ff='E:/video_to_md/readable-transcript/resource/bin/ffmpeg.exe';fp='E:/video_to_md/readable-transcript/resource/bin/ffprobe.exe'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
native=out/'EVERWHILE_R2_EN_1080.mp4';preview=out/'EVERWHILE_R2_EN_720.mp4'
report={'status':'PASS_TECHNICAL_ONLY','movies':[],'directorVerdict':'PENDING','realTimeAudiovisualViewing':'NOT_RUN','subjectiveListening':'NOT_RUN'}
for p,size in [(native,(1080,1920)),(preview,(720,1280))]:
    probe=json.loads(subprocess.check_output([fp,'-v','error','-count_frames','-show_streams','-show_format','-of','json',str(p)]))
    v=next(s for s in probe['streams'] if s['codec_type']=='video');a=next(s for s in probe['streams'] if s['codec_type']=='audio')
    assert (v['width'],v['height'])==size
    assert v['r_frame_rate']==v['avg_frame_rate']=='60/1' and int(v['nb_read_frames'])==1080 and float(v['duration'])==18
    assert a['sample_rate']=='48000' and v['pix_fmt']=='yuv420p'
    subprocess.run([ff,'-v','error','-i',str(p),'-f','null','-'],check=True)
    raw=subprocess.check_output([ff,'-v','error','-i',str(p),'-map','0:v:0','-vf','scale=36:64','-fps_mode','passthrough','-pix_fmt','rgb24','-f','rawvideo','pipe:1'])
    f=np.frombuffer(raw,np.uint8).reshape(-1,64,36,3);assert len(f)==1080
    assert np.all(f.mean((1,2,3))>5) and np.all(f.std((1,2,3))>3)
    audio=np.frombuffer(subprocess.check_output([ff,'-v','error','-i',str(p),'-map','0:a:0','-ar','48000','-ac','2','-f','f32le','pipe:1']),'<f4').reshape(-1,2)
    peak=float(np.abs(audio).max());assert np.isfinite(audio).all() and peak<1
    report['movies'].append({'file':p.name,'sha256':sha(p),'probe':probe,'decodedFrames':len(f),'allFramesNonblank':True,'decodedAudioPeak':peak,'decodedAudioSamplesPerChannel':len(audio)})
    if p==native:decoded=audio.mean(axis=1)
with wave.open(str(root/'review/mix.wav')) as w:
    ref=np.frombuffer(w.readframes(w.getnframes()),'<i2').reshape(-1,2).mean(axis=1)/32768
idx=np.arange(216000,600000,16)
lag,corr=max([(lag,float(np.corrcoef(ref[idx],decoded[idx+lag])[0,1])) for lag in range(-800,801,16)],key=lambda x:x[1])
assert abs(lag)<800 and corr>.98
report['encodedAudioAlignment']={'lagSamples':lag,'gridSamples':16,'correlation':corr,'toleranceSamples':800,'method':'AAC against frozen PCM,4.5–12.5s'}
with wave.open(str(root/'review/sfx.wav')) as w:
    sfx=np.frombuffer(w.readframes(w.getnframes()),'<i2').reshape(-1,2)
audible=np.any(sfx!=0,axis=1);cues=[]
for frame in [450,570,690]:
    at=frame*800;assert not audible[at-24000:at].any()
    first=at+int(np.where(audible[at:at+24000])[0][0]);assert first//800==frame
    cues.append({'frame':frame,'firstSample':first})
report['sfxOnsets']=cues
contact=[30,72,120,180,300,360,480,600,720,780,840,960]
onsets=[449,450,451,462,569,570,571,582,689,690,691,702,929,930,931]
transitions=[254,255,262,269,270,271,300,330,360,389,390,391,449,450,480,749,750,751,753,780,801,810,840,929,930]
temporal=list(range(0,1080,15))+[1079]
indices=sorted(set(contact+onsets+transitions+temporal+[54,102,150,168,198,219,234,246]))
subprocess.run([ff,'-v','error','-y','-i',str(native),'-vf','select='+'+'.join('eq(n\\,%d)'%f for f in indices),'-fps_mode','vfr',str(tmp/'%04d.png')],check=True)
mapping={f:tmp/('%04d.png'%(i+1)) for i,f in enumerate(indices)}
font=ImageFont.truetype(str(root/'assets/fonts/InterVariable.ttf'),20)
def sheet(name,frames,cols,width):
    h=round(width*16/9);label=36;can=Image.new('RGB',(cols*width,((len(frames)+cols-1)//cols)*(h+label)),'#e9edf4');d=ImageDraw.Draw(can)
    for i,f in enumerate(frames):
        x=i%cols*width;y=i//cols*(h+label);d.text((x+9,y+8),f'{f}f / {f/60:.3f}s',font=font,fill='#172128');can.paste(Image.open(mapping[f]).convert('RGB').resize((width,h),Image.Resampling.LANCZOS),(x,y+label))
    can.save(out/name,quality=93,subsampling=0)
sheet('CONTACT_SHEET_EN.jpg',contact,4,270)
sheet('ONSET_PROOF_EN.jpg',onsets,3,270)
sheet('TRANSITIONS_EN.jpg',transitions,5,240)
sheet('TEMPORAL_SEQUENCE_EN.jpg',temporal,10,192)
for n,frames in enumerate([temporal[:24],temporal[24:48],temporal[48:]],1):sheet(f'SEQUENCE_{n:02d}_EN.jpg',frames,6,240)
for i,f in enumerate(contact,1):Image.open(mapping[f]).save(out/f'KEYFRAME_{i:02d}_EN.png')
# Both columns are actual encoded movies at identical360×640 display size.
compare=[30,300,480,840];old=root/'tmp/encoded-p01-r2-compare';old.mkdir(exist_ok=True)
subprocess.run([ff,'-v','error','-y','-i',str(root/'review/EVERWHILE_P01_EN_720.mp4'),'-vf','select='+'+'.join('eq(n\\,%d)'%f for f in compare),'-fps_mode','vfr',str(old/'%02d.png')],check=True)
can=Image.new('RGB',(720,4*680),'#e9edf4');d=ImageDraw.Draw(can)
for i,f in enumerate(compare):
    y=i*680;d.text((12,y+10),f'P01 encoded / {f/60:.1f}s',font=font,fill='#172128');d.text((372,y+10),f'R2 encoded / {f/60:.1f}s',font=font,fill='#172128')
    for x,p in [(0,old/('%02d.png'%(i+1))),(360,mapping[f])]:can.paste(Image.open(p).convert('RGB').resize((360,640),Image.Resampling.LANCZOS),(x,y+40))
can.save(out/'OLD_VS_NEW_EN.jpg',quality=93,subsampling=0)
# Verify source crop exactly equals original rectangle, before interpolation/codec.
m=json.loads((root/'ASSET_MANIFEST_R2.json').read_text())
raw=Image.open(root/m['today']['source']).convert('RGB').crop(m['today']['cropLTRB'])
crop=Image.open(root/m['today']['output']).convert('RGB');assert np.array_equal(np.asarray(raw),np.asarray(crop))
browser=Image.open(out/'frames/0840.png').convert('RGB');detail=browser.crop((140,695,940,1638))
expected=crop.resize((800,943),Image.Resampling.BICUBIC)
ui_mae=float(np.abs(np.asarray(detail,float)-np.asarray(expected,float)).mean());assert ui_mae<1.5,ui_mae
encoded=Image.open(mapping[840]).convert('RGB').crop((140,695,940,1638))
encode_ui_mae=float(np.abs(np.asarray(detail,float)-np.asarray(encoded,float)).mean());assert encode_ui_mae<4,encode_ui_mae
report['uiIntegrity']={'exactRawCropPixels':True,'cropLTRB':m['today']['cropLTRB'],'uniformScale':800/920,'browserInterpolationMAE':ui_mae,'encodedDetailMAE':encode_ui_mae,'bothAppRowsPreserved':True}
comparison=[]
for f in indices:
    p=out/'frames'/('%04d.png'%f)
    if p.exists():
        mae=float(np.abs(np.asarray(Image.open(p).convert('RGB'),float)-np.asarray(Image.open(mapping[f]).convert('RGB'),float)).mean());comparison.append({'frame':f,'meanRGBError':mae});assert mae<8,(f,mae)
report['encodedVsBrowser']=comparison
report['renderedSourceSHA']=subprocess.check_output(['git','rev-parse','HEAD'],cwd=root,text=True).strip()
report['audioFrozen']=m['audioFrozen']
(out/'ENCODE_QA.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
files=[p for p in sorted(out.iterdir()) if p.is_file() and p.name!='ARTIFACTS.json' and p.suffix in ['.mp4','.jpg','.png']]
(out/'ARTIFACTS.json').write_text(json.dumps({'files':[{'file':p.relative_to(root).as_posix(),'sha256':sha(p),'bytes':p.stat().st_size} for p in files]},indent=2)+'\n',encoding='utf8')
print(json.dumps({k:report[k] for k in ['status','renderedSourceSHA','sfxOnsets','uiIntegrity','encodedAudioAlignment']},indent=2))
