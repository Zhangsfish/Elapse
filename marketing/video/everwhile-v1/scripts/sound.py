"""Original 120 BPM score and soft brand cue; no samples, TTS or Lecture audio.
48 kHz PCM, fixed seed. Front subdivisions/syncopation; sparse regular back.
"""
from pathlib import Path
import json, subprocess, wave, os
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'review'
FFMPEG=os.environ.get('EVERWHILE_FFMPEG','E:/video_to_md/readable-transcript/resource/bin/ffmpeg.exe')
SR=48000; N=18*SR; rng=np.random.default_rng(10707)
music=np.zeros((N,2)); sfx=np.zeros((N,2)); drums=np.zeros((N,2)); tonal=np.zeros((N,2))

def add(track, sound, start, gain=1, pan=0):
    i=round(start*SR); n=min(len(sound),N-i)
    if n<=0: return
    track[i:i+n,0]+=sound[:n]*gain*np.sqrt((1-pan)/2)
    track[i:i+n,1]+=sound[:n]*gain*np.sqrt((1+pan)/2)

def pluck(f,d=.35):
    t=np.arange(round(d*SR))/SR
    return (np.sin(2*np.pi*f*t)+.3*np.sin(2*np.pi*2*f*t)+.12*np.sin(2*np.pi*3*f*t))*np.exp(-t*10)*np.minimum(t/.004,1)

def kick():
    t=np.arange(round(.19*SR))/SR
    return np.sin(2*np.pi*(48*t+20*.035*(1-np.exp(-t/.035))))*np.exp(-t*22)*np.minimum(t/.002,1)

def hat(d=.055):
    t=np.arange(round(d*SR))/SR; noise=rng.normal(0,1,len(t)); noise=np.diff(noise,prepend=0)
    return noise*.2*np.exp(-t*70)*np.minimum(t/.002,1)

def rim():
    t=np.arange(round(.09*SR))/SR
    return (np.sin(2*np.pi*850*t)*.35+rng.normal(0,.2,len(t)))*np.exp(-t*55)*np.minimum(t/.002,1)

# 36 beats, one half-second beat grid. No notes initiated inside the air pocket.
notes=[293.6648,369.9944,440,554.3653,493.8833,440,369.9944,329.6276]
for beat in range(36):
    at=beat*.5
    if 4.25<=at<4.5: continue
    front=at<4.25
    if at<15.5:
        add(drums,kick(),at,.48 if front else .3)
        if beat%2: add(drums,rim(),at,.27 if front else .14, .18)
        add(tonal,pluck(notes[(beat//4)%8]/4,.45),at,.2 if front else .12,-.08)
        if front:
            for sub in [0,.125,.25,.375]:
                if at+sub<4.25: add(drums,hat(),at+sub,.3 if sub==.25 else .17,(-1 if int(sub*8)%2 else 1)*.25)
            for sub in [.125,.375]:
                if at+sub<4.25: add(tonal,pluck(notes[(beat*2+int(sub*4))%8],.3),at+sub,.17, .18 if beat%2 else -.18)
        elif beat%2==0:
            add(drums,hat(.07),at+.25,.13,.25)
            add(tonal,pluck(notes[(beat//2)%8],.6),at+.25,.11,-.12)
    else:
        # Resolved D major voicing at the full end card, brief pitched tail.
        if beat in [31,33]:
            for f in [293.6648,369.9944,440]:add(tonal,pluck(f,1.1),at,.10,-.1+(f-293)/730)

# Editorial air pocket, remove percussion/low frequencies; preserve tonal tail.
drums[round(4.25*SR):round(4.5*SR)]=0
for lane in range(2):
    a=round(4.25*SR);b=round(4.5*SR)
    tonal[a:b,lane]*=np.linspace(.55,.22,b-a)
# Score ends cleanly without an empty visual tail.
music=drums+tonal; music[-round(.25*SR):]*=np.linspace(1,0,round(.25*SR))[:,None]
for at in [7.5,9.5,11.5]:
    t=np.arange(round(.58*SR))/SR
    cue=(np.sin(2*np.pi*784*t)+.32*np.sin(2*np.pi*1176*t)+.12*np.sin(2*np.pi*1568*t))*np.exp(-t*8)*np.minimum(t/.008,1)
    add(sfx,cue,at,.23)

def wav(name,data):
    pcm=np.round(np.clip(data,-1,1)*32767).astype('<i2')
    with wave.open(str(OUT/name),'wb') as w:w.setnchannels(2);w.setsampwidth(2);w.setframerate(SR);w.writeframes(pcm.tobytes())

OUT.mkdir(exist_ok=True)
# Linked stereo, common soft-knee peak compression before common loudness gain.
# The stems still sum exactly (within PCM quantization); no temporal shift.
peak=np.max(np.abs(music+sfx),axis=1)
compressed=np.where(peak>.035,.035*(np.maximum(peak,.035)/.035)**.32,peak)
ratio=compressed/np.maximum(peak,1e-12)
music*=ratio[:,None];sfx*=ratio[:,None]
wav('mix-unmastered.wav',music+sfx)
def measure(name):
    p=subprocess.run([FFMPEG,'-hide_banner','-i',str(OUT/name),'-af','loudnorm=I=-15:TP=-1:LRA=11:print_format=json','-f','null','-'],capture_output=True,text=True,check=True)
    return json.loads(p.stderr[p.stderr.rfind('{'):p.stderr.rfind('}')+1])
measured=measure('mix-unmastered.wav')
# A common linear gain preserves exact stems/mix reconstruction and sample onsets.
gain_db=min(-15-float(measured['input_i']),-1.4-float(measured['input_tp']))
gain=10**(gain_db/20);wav('music.wav',music*gain);wav('sfx.wav',sfx*gain);wav('mix.wav',(music+sfx)*gain)
final=measure('mix.wav')
report={'status':'TECHNICAL_CHECK_ONLY','sample_rate':SR,'samples':N,'bpm':120,'cue_frames':[450,570,690],'cue_samples':[360000,456000,552000],'air_pocket_frames':[255,270],'gain_db':gain_db,'measurement':final,'complete_subjective_listening':'NOT_RUN','composition':'original deterministic synthesis, no third-party sound samples'}
assert float(final['input_tp'])<=-1
assert abs(float(final['input_i'])+15)<1.5
(OUT/'AUDIO_QA.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf8')
print(json.dumps(report,indent=2))
