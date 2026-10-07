import {root,cli,live,run,ffmpeg} from './tools.mjs';
import path from 'node:path';
throw Error('Historical P01 renderer is frozen. Use scripts/render-r2.mjs, or reproduce P01 from eeae9b1 in a separate checkout.');
// HyperFrames owns frame capture/video extraction. FFmpeg only muxes the original
// sample-accurate premix after frame rendering (no homemade recording engine).
await live(process.execPath,[cli,'render',path.join(root,'build/en'),'--output',path.join(root,'tmp/picture.mp4'),'--fps','60','--workers','2','--quality','standard','--crf','19','--sdr','--browser-gpu','--experimental-fast-capture=false']);
run(ffmpeg,['-hide_banner','-loglevel','error','-y','-i',path.join(root,'tmp/picture.mp4'),'-i',path.join(root,'review/mix.wav'),'-map','0:v:0','-map','1:a:0','-c:v','copy','-c:a','aac','-b:a','256k','-ar','48000','-t','18','-movflags','+faststart',path.join(root,'review/EVERWHILE_P01_EN_720.mp4')]);
console.log('English full-length picture + original 48k music/SFX premix exported.');
