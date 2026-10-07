import {root,cli,live,run,ffmpeg} from './tools.mjs';
import path from 'node:path';
import {readFile,writeFile,cp} from 'node:fs/promises';
const out=path.join(root,'review/director-r2');
const transition=process.argv.includes('--transition');
const project=path.join(root,transition?'build/transition':'build/en');
const args=[cli,'render',project,'--fps','60','--workers','2','--quality','standard','--crf','17','--sdr','--browser-gpu','--experimental-fast-capture=false'];
if(transition){
  const html=await readFile(path.join(root,'build/en/index.html'),'utf8');
  await cp(path.join(root,'build/en'),project,{recursive:true});
  await writeFile(path.join(project,'index.html'),html.replaceAll('data-duration="18"','data-duration="8.6"'));
  await live(process.execPath,[...args,'--output',path.join(root,'tmp/r2-transition.mp4')]);
  console.log('Native1080 0–8.6s transition proof rendered.');
}else{
  await live(process.execPath,[...args,'--output',path.join(root,'tmp/r2-picture.mp4')]);
  // Approved premix remains byte-identical. Mux only; no new audio processing.
  run(ffmpeg,['-v','error','-y','-i',path.join(root,'tmp/r2-picture.mp4'),'-i',path.join(root,'review/mix.wav'),'-map','0:v:0','-map','1:a:0','-c:v','copy','-c:a','aac','-b:a','256k','-ar','48000','-t','18','-movflags','+faststart',path.join(out,'EVERWHILE_R2_EN_1080.mp4')]);
  // Preview is downsampled from the NEW encoded native movie, never upscaled P01.
  run(ffmpeg,['-v','error','-y','-i',path.join(out,'EVERWHILE_R2_EN_1080.mp4'),'-vf','scale=720:1280:flags=lanczos','-c:v','libx264','-crf','18','-preset','slow','-pix_fmt','yuv420p','-c:a','copy','-movflags','+faststart',path.join(out,'EVERWHILE_R2_EN_720.mp4')]);
  console.log('Complete18s native1080 and derived720 with approved score/SFX.');
}
