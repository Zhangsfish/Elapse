import {root,toolRoot,chrome} from '../scripts/tools.mjs';
import {mkdir,readFile,writeFile} from 'node:fs/promises';
import {createServer} from 'node:http';import path from 'node:path';import {pathToFileURL} from 'node:url';
const {default:puppeteer}=await import(pathToFileURL(path.join(toolRoot,'node_modules/puppeteer-core/lib/puppeteer/puppeteer-core.js')));
const here=path.join(root,'post-release'),out=path.join(here,'outputs');await mkdir(path.join(here,'tmp'),{recursive:true});
const browser=await puppeteer.launch({executablePath:chrome,headless:true,args:['--no-sandbox']});const evidence=[];
try{for(const lang of ['en','zh-Hans']){
 const project=path.join(root,'build/live-'+lang);
 const types={'.html':'text/html','.js':'text/javascript','.css':'text/css','.png':'image/png','.jpg':'image/jpeg','.mp4':'video/mp4','.ttf':'font/ttf','.ttc':'font/collection','.wav':'audio/wav'};
 const server=createServer(async(req,res)=>{try{
  const file=path.resolve(project,'.'+(req.url==='/'?'/index.html':decodeURIComponent(req.url.split('?')[0])));
  if(!file.startsWith(project+path.sep))throw Error('outside');const b=await readFile(file);
  res.setHeader('Content-Type',types[path.extname(file)]||'application/octet-stream');res.setHeader('Accept-Ranges','bytes');
  const range=req.headers.range?.match(/bytes=(\d+)-(\d*)/);
  if(range){const start=Number(range[1]),end=range[2]?Math.min(Number(range[2]),b.length-1):b.length-1;res.statusCode=206;res.setHeader('Content-Range',`bytes ${start}-${end}/${b.length}`);res.end(b.subarray(start,end+1));}else res.end(b);
 }catch{res.statusCode=404;res.end();}});await new Promise(r=>server.listen(0,'127.0.0.1',r));
 const page=await browser.newPage(),errors=[];page.on('pageerror',e=>errors.push(e.message));
 try{
 await page.setViewport({width:1080,height:1920,deviceScaleFactor:1});await page.goto(`http://127.0.0.1:${server.address().port}/`,{waitUntil:'networkidle0'});await page.evaluate(()=>window.__directorReady);
 const frames=[0,180,300,360,449,450,480,569,570,600,689,690,720,840,929,930,960,1079];const boxes=[];
 for(const f of frames){await page.evaluate(f=>window.__seekFilm(f),f);await page.screenshot({path:path.join(here,`tmp/${lang}-${f}.png`)});
 const b=await page.evaluate(()=>Array.from(document.querySelectorAll('h1,#usage-demo,#reminder-message,.minute,#download-entry,#download-qr,#download-label,#download-url')).map(el=>{
  let visible=true;for(let p=el;p;p=p.parentElement){const s=getComputedStyle(p);if(s.visibility==='hidden'||Number(s.opacity)<.01)visible=false;}
  const r=el.getBoundingClientRect();return{id:el.id||el.textContent,visible,x:r.x,y:r.y,w:r.width,h:r.height};
 }));if(b.some(x=>x.visible&&(x.x<0||x.y<0||x.x+x.w>1080.5||x.y+x.h>1920.5)))throw Error('Bounds '+lang+' '+f);boxes.push({frame:f,elements:b});
 }
 await page.evaluate(()=>window.__seekFilm(960));await page.screenshot({path:path.join(out,`END_CARD_${lang}.png`)});
 const cdp=await page.createCDPSession();await cdp.send('DOM.enable');await cdp.send('CSS.enable');const doc=await cdp.send('DOM.getDocument');const fonts=[];
 for(const selector of ['#brand-name','#end-title','#download-label']){const {nodeId}=await cdp.send('DOM.querySelector',{nodeId:doc.root.nodeId,selector});fonts.push({selector,...await cdp.send('CSS.getPlatformFontsForNode',{nodeId})});}
 if(errors.length)throw Error(errors.join('\n'));evidence.push({lang,errors,boxes,fonts});
 }finally{await page.close();await new Promise(r=>server.close(r));}
}}finally{await browser.close();}
await writeFile(path.join(out,'BROWSER_QA.json'),JSON.stringify(evidence,null,2)+'\n');console.log('Bilingual frame/bounds/font snapshots PASS.');
