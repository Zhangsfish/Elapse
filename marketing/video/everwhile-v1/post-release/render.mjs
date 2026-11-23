import {root,cli,live,run,ffmpeg} from '../scripts/tools.mjs';
import {writeFile,mkdir} from 'node:fs/promises';import path from 'node:path';
const here=path.join(root,'post-release'),tmp=path.join(here,'tmp'),out=path.join(here,'outputs');await mkdir(tmp,{recursive:true});
const approved=path.join(root,'review/director-r2/EVERWHILE_R2_EN_1080.mp4');
const mode=process.argv[2]||'all';
if(mode==='all'||mode==='en'){
 // Approved source has an IDR at15.5s. Keep all930 earlier frames by packet copy.
 run(ffmpeg,['-v','error','-y','-i',approved,'-map','0:v:0','-t','15.5','-c:v','copy','-an',path.join(tmp,'head.mp4')]);
 run(ffmpeg,['-v','error','-y','-loop','1','-framerate','60','-i',path.join(out,'END_CARD_en.png'),'-t','2.5','-c:v','libx264','-preset','slow','-crf','17','-bf','0','-refs','3','-profile:v','high','-level:v','4.2','-pix_fmt','yuv420p','-color_primaries','bt709','-color_trc','bt709','-colorspace','bt709','-video_track_timescale','15360',path.join(tmp,'tail.mp4')]);
 await writeFile(path.join(tmp,'concat.txt'),"file 'head.mp4'\nfile 'tail.mp4'\n");
 run(ffmpeg,['-v','error','-y','-f','concat','-safe','0','-i',path.join(tmp,'concat.txt'),'-i',approved,'-map','0:v:0','-map','1:a:0','-c','copy','-t','18','-movflags','+faststart',path.join(out,'EVERWHILE_EN_1080.mp4')]);
}
if(mode==='all'||mode==='zh-Hans'){
 await live(process.execPath,[cli,'render',path.join(root,'build/live-zh-Hans'),'--fps','60','--workers','2','--quality','standard','--crf','17','--sdr','--browser-gpu','--experimental-fast-capture=false','--output',path.join(tmp,'zh-picture.mp4')]);
 run(ffmpeg,['-v','error','-y','-i',path.join(tmp,'zh-picture.mp4'),'-i',approved,'-map','0:v:0','-map','1:a:0','-c','copy','-t','18','-movflags','+faststart',path.join(out,'EVERWHILE_ZH_HANS_1080.mp4')]);
}
for(const lang of (mode==='all'?['EN','ZH_HANS']:mode==='en'?['EN']:['ZH_HANS'])){
 run(ffmpeg,['-v','error','-y','-i',path.join(out,`EVERWHILE_${lang}_1080.mp4`),'-vf','scale=720:1280:flags=lanczos','-c:v','libx264','-crf','18','-preset','slow','-pix_fmt','yuv420p','-c:a','copy','-movflags','+faststart',path.join(out,`EVERWHILE_${lang}_720.mp4`)]);
}console.log('Post-release '+mode+' full film(s) complete.');
