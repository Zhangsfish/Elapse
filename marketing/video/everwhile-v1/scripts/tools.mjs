// Narrow tooling patterns adapted from Lecture Asset PR #18 / director-tools.mjs.
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {spawnSync, spawn} from 'node:child_process';
export const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)),'..');
export const toolRoot=process.env.EVERWHILE_TOOL_ROOT || 'E:/myself/lecture_asset/marketing/video/v2';
export const ffmpeg=process.env.EVERWHILE_FFMPEG || 'E:/video_to_md/readable-transcript/resource/bin/ffmpeg.exe';
export const ffprobe=process.env.EVERWHILE_FFPROBE || path.join(path.dirname(ffmpeg),'ffprobe.exe');
export const chrome=process.env.EVERWHILE_CHROME || 'C:/Program Files/Google/Chrome/Application/chrome.exe';
export const cli=path.join(toolRoot,'node_modules/hyperframes/bin/hyperframes.mjs');
export const env={...process.env,HYPERFRAMES_BROWSER_PATH:chrome,HYPERFRAMES_FFMPEG_PATH:ffmpeg,HYPERFRAMES_FFPROBE_PATH:ffprobe,HYPERFRAMES_SKIP_SKILLS:'1',HYPERFRAMES_NO_UPDATE_CHECK:'1',HYPERFRAMES_NO_TELEMETRY:'1',DO_NOT_TRACK:'1',HYPERFRAMES_RUN_ID:'everwhile-r2'};
export function run(exe,args){const r=spawnSync(exe,args,{cwd:root,env,windowsHide:true,encoding:'utf8',maxBuffer:32*1024*1024});if(r.status!==0)throw Error(`${path.basename(exe)} exited ${r.status}\n${r.stderr}\n${r.stdout}`);return r;}
export async function live(exe,args){await new Promise((resolve,reject)=>{const p=spawn(exe,args,{cwd:root,env,windowsHide:true,stdio:'inherit'});p.on('error',reject);p.on('exit',c=>c===0?resolve():reject(Error(`exit ${c}`)));});}
