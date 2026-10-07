"""Inspect the actual encoded film, not just browser snapshots."""
from pathlib import Path
import subprocess, json, hashlib, os, wave
from PIL import Image, ImageDraw, ImageFont
import numpy as np

root=Path(__file__).resolve().parents[1];out=root/'review';tmp=root/'tmp/encoded-frames';tmp.mkdir(parents=True,exist_ok=True)
ffmpeg=os.environ.get('EVERWHILE_FFMPEG','E:/video_to_md/readable-transcript/resource/bin/ffmpeg.exe')
ffprobe=os.environ.get('EVERWHILE_FFPROBE','E:/video_to_md/readable-transcript/resource/bin/ffprobe.exe')
film=out/'EVERWHILE_P01_EN_720.mp4'
probe=json.loads(subprocess.check_output([ffprobe,'-v','error','-count_frames','-show_streams','-show_format','-of','json',str(film)]))
v=next(s for s in probe['streams'] if s['codec_type']=='video');a=next(s for s in probe['streams'] if s['codec_type']=='audio')
assert (v['width'],v['height'])==(720,1280)
assert v['r_frame_rate']==v['avg_frame_rate']=='60/1'
assert int(v['nb_read_frames'])==1080
assert float(v['duration'])==18
assert a['sample_rate']=='48000'
raw=subprocess.check_output([ffmpeg,'-v','error','-i',str(film),'-map','0:v:0','-vf','scale=36:64','-fps_mode','passthrough','-pix_fmt','rgb24','-f','rawvideo','pipe:1'])
frames=np.frombuffer(raw,np.uint8).reshape(-1,64,36,3)
assert len(frames)==1080
brightness=frames.mean((1,2,3));std=frames.std((1,2,3))
assert np.all(brightness>5)
assert np.all(std>3),str(np.where(std<=3)[0].tolist())

selected=[220,360,480,720,840,960]
transitions=[0,30,54,72,102,120,150,168,180,198,240,254,255,262,269,270,271,300,360,390,449,450,462,510,569,570,582,600]
onsets=[449,450,462,569,570,582,689,690,702,929,930,931]
allframes=sorted(set(selected+transitions+onsets))
subprocess.run([ffmpeg,'-v','error','-y','-i',str(film),'-vf','select='+ '+'.join('eq(n\\,%d)'%f for f in allframes),'-fps_mode','vfr',str(tmp/'%04d.png')],check=True)
mapping={f:tmp/('%04d.png'%(i+1)) for i,f in enumerate(allframes)}
font=ImageFont.truetype(str(root/'assets/fonts/InterVariable.ttf'),22)
def sheet(name,indices,columns,width):
    h=round(width*1280/720);label=38
    canvas=Image.new('RGB',(columns*width,((len(indices)+columns-1)//columns)*(h+label)), '#e9edf4');draw=ImageDraw.Draw(canvas)
    for i,f in enumerate(indices):
        x=(i%columns)*width;y=(i//columns)*(h+label)
        draw.text((x+12,y+8),f'{f}f  /  {f/60:.3f}s',font=font,fill='#162033')
        canvas.paste(Image.open(mapping[f]).convert('RGB').resize((width,h),Image.Resampling.LANCZOS),(x,y+label))
    canvas.save(out/name,quality=93,subsampling=0)
sheet('CONTACT_SHEET_EN.jpg',selected,3,360)
sheet('TRANSITIONS_0_10_EN.jpg',transitions,7,240)
sheet('ONSET_PROOF_EN.jpg',onsets,3,360)
for i,f in enumerate(selected,1):Image.open(mapping[f]).save(out/f'KEYFRAME_{i:02d}_EN.png')

# Encoded-vs-native selected-frame comparison, including the real untouched capture.
comparison=[]
for f in allframes:
    native=out/'frames'/('%04d.png'%f)
    if native.exists():
        n=np.asarray(Image.open(native).convert('RGB'),float);e=np.asarray(Image.open(mapping[f]).convert('RGB'),float)
        mae=float(np.abs(n-e).mean());comparison.append({'frame':f,'meanRGBError':mae})
        assert mae<8,(f,mae)

with wave.open(str(out/'sfx.wav')) as w:
    data=np.frombuffer(w.readframes(w.getnframes()),'<i2').reshape(-1,2)
audible=np.any(data!=0,axis=1)
starts=np.where(audible & ~np.r_[False,audible[:-1]])[0]
# Cue envelopes may cross zero: check first nonzero sample of each isolated window.
cue=[]
for f in [450,570,690]:
    at=round(f/60*48000);assert not audible[at-24000:at].any()
    first=at+int(np.where(audible[at:at+24000])[0][0]);assert first//800==f
    cue.append({'frame':f,'sample':first,'withinFrameOnset':first-at})

report={'status':'PASS_TECHNICAL','probe':probe,'fullDecodeFrames':len(frames),'nonBlackFrames':int((brightness>5).sum()),'nonBlankFrames':int((std>3).sum()),'minMeanRGB':float(brightness.min()),'minSpatialStd':float(std.min()),'encodedNativeComparison':comparison,'sfxOnsets':cue,'filmSHA256':hashlib.sha256(film.read_bytes()).hexdigest(),'fullSubjectiveViewing':'NOT_RUN','completeListening':'NOT_RUN','directorVerdict':'PENDING'}
decoded_audio=np.frombuffer(subprocess.check_output([ffmpeg,'-v','error','-i',str(film),'-map','0:a:0','-ar','48000','-ac','2','-f','f32le','pipe:1']),'<f4').reshape(-1,2).mean(axis=1)
with wave.open(str(out/'mix.wav')) as w:
    reference=np.frombuffer(w.readframes(w.getnframes()),'<i2').reshape(-1,2).mean(axis=1)/32768
# AAC can change individual samples. Measure actual mux alignment, not only stem markers.
indices=np.arange(216000,600000,16)
correlations=[(lag,float(np.corrcoef(reference[indices],decoded_audio[indices+lag])[0,1])) for lag in range(-800,801,16)]
lag,correlation=max(correlations,key=lambda p:p[1])
assert abs(lag)<800 and correlation>.98,(lag,correlation)
report['encodedAudioAlignment']={'bestLagSamples':lag,'lagGridSamples':16,'correlation':correlation,'toleranceSamples':800,'method':'AAC decoded mix versus PCM premix, 4.5–12.5 second window'}
(out/'ENCODE_QA.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
artifact_files=['EVERWHILE_P01_EN_720.mp4','CONTACT_SHEET_EN.jpg','TRANSITIONS_0_10_EN.jpg','ONSET_PROOF_EN.jpg','music.wav','sfx.wav','mix.wav']+[f'KEYFRAME_{i:02d}_EN.png' for i in range(1,7)]
(out/'ARTIFACTS.json').write_text(json.dumps({'files':[{'file':'review/'+n,'sha256':hashlib.sha256((out/n).read_bytes()).hexdigest(),'bytes':(out/n).stat().st_size} for n in artifact_files]},indent=2)+'\n',encoding='utf8')
print(json.dumps({k:report[k] for k in ['status','fullDecodeFrames','nonBlackFrames','nonBlankFrames','sfxOnsets','filmSHA256']},indent=2))
