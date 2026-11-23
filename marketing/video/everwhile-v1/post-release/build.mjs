import {mkdir,cp,readFile,writeFile} from 'node:fs/promises';
import {pathToFileURL} from 'node:url';
import path from 'node:path';
import {root,toolRoot} from '../scripts/tools.mjs';
const here=path.join(root,'post-release');
const {build}=await import(pathToFileURL(path.join(toolRoot,'node_modules/esbuild/lib/main.js')));
await mkdir(path.join(root,'build/live'),{recursive:true});
await build({entryPoints:[path.join(root,'src/page.ts')],outfile:path.join(root,'build/live/page.mjs'),bundle:true,platform:'node',format:'esm'});
const {page}=await import(pathToFileURL(path.join(root,'build/live/page.mjs')));
const translations=JSON.parse(await readFile(path.join(here,'translations.json'),'utf8'));
for(const lang of ['en','zh-Hans']){
 const project=path.join(root,'build/live-'+lang);await mkdir(project,{recursive:true});
 await cp(path.join(root,'assets'),path.join(project,'assets'),{recursive:true});
 await cp(path.join(here,'assets'),path.join(project,'download'),{recursive:true});
 await mkdir(path.join(project,'audio'),{recursive:true});
 for(const name of ['music','sfx'])await cp(path.join(root,`review/${name}.wav`),path.join(project,`audio/${name}.wav`));
 await build({entryPoints:[path.join(root,'src/timeline.ts')],outfile:path.join(project,'timeline.js'),bundle:true,platform:'browser',format:'iife'});
 let html=page();
 if(lang==='zh-Hans'){
  for(const [from,to]of Object.entries(translations)){if(!html.includes(from))throw Error('Missing translation source '+from);html=html.replaceAll(from,to);}
  html=html.replace('lang="en"','lang="zh-Hans"').replace('src="assets/r2/today-detail.png"','src="download/today-zh-Hans.png"');
  await mkdir(path.join(project,'local-fonts'),{recursive:true});
  for(const font of ['msyh.ttc','msyhbd.ttc'])await cp('C:/Windows/Fonts/'+font,path.join(project,'local-fonts',font));
 }
 const caption=lang==='en'?'Scan to download':'扫码下载';
 const country=lang==='en'?'us':'cn';
 html=html.replace('</h1></div></section></div>',`</h1><div id="download-entry"><img id="download-qr" src="download/qr-${lang}.png" alt="https://apps.apple.com/${country}/app/everwhile/id6818551574"><div id="download-label">${caption}</div><div id="download-store">App Store · iPhone</div><div id="download-url">apps.apple.com/app/id6818551574</div></div></div></section></div>`);
 if(!html.includes('id="download-qr"'))throw Error('Missing download entry');
 const gsap=await readFile(path.join(toolRoot,'node_modules/gsap/dist/gsap.min.js'),'utf8');
 const timeline=await readFile(path.join(project,'timeline.js'),'utf8');
 await writeFile(path.join(project,'gsap.min.js'),gsap);
 const extra=lang==='zh-Hans'?`;window.__directorReady=Promise.all([window.__directorReady,document.fonts.load('400 57px CJKFilm'),document.fonts.load('600 96px CJKFilm')]);`:'';
 await writeFile(path.join(project,'index.html'),html.replace('<script src="timeline.js"></script>',`<script>${timeline}${extra}</script>`).replaceAll(/(<section[^>]*?) class="clip scene" data-start="[^"]+" data-duration="[^"]+" data-track-index="0"/g,'$1 class="scene"'));
 let css=await readFile(path.join(root,'src/film.css'),'utf8');
 css+=`\n/* Post-release: final scene only; R2 source remains frozen. */
#s05 #brand-lockup{top:350px}#s05 #end-title{margin-top:80px}
#download-entry{position:absolute;top:650px;left:0;width:864px;text-align:center}
#download-qr{display:block;width:492px;height:492px;margin:0 auto;image-rendering:pixelated}
#download-label{font-size:42px;font-weight:600;margin-top:34px;line-height:1.4}
#download-store{font-size:32px;color:#64717a;margin-top:12px}
#download-url{font-size:29px;color:#64717a;margin-top:22px;letter-spacing:0}
`;
 if(lang==='zh-Hans')css+=`
@font-face{font-family:CJKFilm;src:url('local-fonts/msyh.ttc');font-weight:400;font-display:block}
@font-face{font-family:CJKFilm;src:url('local-fonts/msyhbd.ttc');font-weight:600;font-display:block}
body{font-family:InterFilm,CJKFilm,sans-serif}h1{letter-spacing:0;line-height:1.3}
.chapter{letter-spacing:2px}.novel p{letter-spacing:0;line-height:1.75}
#question{letter-spacing:0;line-height:1.25;font-size:132px}
#selection-action h1,#interval-action h1{font-size:94px}
.reading-thumb{line-height:1.7}#interval span{font-size:90px;letter-spacing:0}
.minute span{letter-spacing:0}#reminder-message{letter-spacing:0}
#today-copy h1{font-size:92px}#end-title{font-size:86px;letter-spacing:0;line-height:1.45}
`;
 await writeFile(path.join(project,'film.css'),css);
}
console.log('Built bilingual native compositions, frozen R2 motion, verified download QRs.');
