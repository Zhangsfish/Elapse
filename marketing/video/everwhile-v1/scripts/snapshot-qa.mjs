import {root,toolRoot,chrome,run,cli} from './tools.mjs';
import {readFile,writeFile,mkdir} from 'node:fs/promises';
import {createServer} from 'node:http';
import {createHash} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import path from 'node:path';
throw Error('Historical P01 QA is frozen. Use scripts/snapshot-r2.mjs.');
const {default:puppeteer}=await import(pathToFileURL(path.join(toolRoot,'node_modules/puppeteer-core/lib/puppeteer/puppeteer-core.js')));
const project=path.join(root,'build/en');const out=path.join(root,'review');await mkdir(path.join(out,'frames'),{recursive:true});
const types={'.html':'text/html','.js':'text/javascript','.css':'text/css','.png':'image/png','.jpg':'image/jpeg','.mp4':'video/mp4','.ttf':'font/ttf','.wav':'audio/wav'};
const server=createServer(async(req,res)=>{try{const name=decodeURIComponent(req.url.split('?')[0]);const file=path.resolve(project,'.'+(name==='/'?'/index.html':name));if(!file.startsWith(project+path.sep))throw Error('outside project');const b=await readFile(file);res.setHeader('Content-Type',types[path.extname(file)]||'application/octet-stream');res.setHeader('Accept-Ranges','bytes');const range=req.headers.range?.match(/bytes=(\d+)-(\d*)/);if(range){const start=Number(range[1]),end=range[2]?Math.min(Number(range[2]),b.length-1):b.length-1;res.statusCode=206;res.setHeader('Content-Range',`bytes ${start}-${end}/${b.length}`);res.setHeader('Content-Length',end-start+1);res.end(b.subarray(start,end+1));}else{res.setHeader('Content-Length',b.length);res.end(b);}}catch{res.statusCode=404;res.end();}});
await new Promise(r=>server.listen(0,'127.0.0.1',r));
const browser=await puppeteer.launch({executablePath:chrome,headless:true,args:['--no-sandbox','--disable-background-timer-throttling']});
const errors=[];const page=await browser.newPage();page.on('pageerror',e=>errors.push(e.message));page.on('requestfailed',r=>{if(!r.failure()?.errorText.includes('ABORTED'))errors.push(r.url());});
try{
  await page.setViewport({width:720,height:1280,deviceScaleFactor:1});
  await page.goto(`http://127.0.0.1:${server.address().port}/`,{waitUntil:'networkidle0'});
  console.log('Page loaded',await page.evaluate(()=>Array.from(document.querySelectorAll('video')).map(v=>[v.id,v.readyState,v.duration,v.currentTime,v.networkState,v.error?.message])));
  await Promise.race([page.evaluate(()=>window.__directorReady),new Promise((_,reject)=>setTimeout(()=>reject(Error('asset readiness timeout')),30000))]);
  console.log('Assets ready');
  const frames=[0,30,54,72,102,120,150,168,180,198,220,240,254,255,262,269,270,271,285,300,330,360,389,390,420,449,450,451,462,480,509,510,540,569,570,571,582,600,629,630,660,689,690,691,702,720,749,750,751,780,840,929,930,931,960,1020,1079];
const signatures={};const boxes={};const domSignatures={};
  const fingerprint=()=>Array.from(document.querySelectorAll('#design *')).filter(el=>{for(let p=el;p&&p.id!=='root';p=p.parentElement){const c=getComputedStyle(p);if(c.visibility==='hidden'||Number(c.opacity)<.01)return false;}return true;}).map(el=>{const c=getComputedStyle(el),r=el.getBoundingClientRect();return [el.id,el.tagName,[r.x,r.y,r.width,r.height].map(x=>Math.round(x*1000)/1000),c.opacity,c.backgroundColor,el instanceof HTMLVideoElement?el.currentTime.toFixed(4):null];});
  for(const f of frames){console.log('snapshot',f);await Promise.race([page.evaluate(f=>window.__seekFilm(f),f),new Promise((_,reject)=>setTimeout(()=>reject(Error('seek timeout '+f)),10000))]);await page.evaluate(()=>new Promise(r=>requestAnimationFrame(()=>requestAnimationFrame(r))));const b=await page.screenshot({type:'png'});await writeFile(path.join(out,'frames',String(f).padStart(4,'0')+'.png'),b);signatures[f]=createHash('sha256').update(b).digest('hex');
    domSignatures[f]=JSON.stringify(await page.evaluate(fingerprint));
    boxes[f]=await page.evaluate(()=>{
      const ids=['question','time-layer','pulse-5','pulse-10','pulse-15','usage-demo','reminder-message','brand-icon','brand-name','end-title'];
      return ids.map(id=>{const el=document.getElementById(id);let visible=true;for(let p=el;p;p=p.parentElement){const c=getComputedStyle(p);if(c.visibility==='hidden'||c.display==='none'||Number(c.opacity)<.01)visible=false;}const r=el.getBoundingClientRect();return{id,visible,x:r.x,y:r.y,width:r.width,height:r.height,fontWeight:getComputedStyle(el).fontWeight,fontSize:getComputedStyle(el).fontSize};});
    });
  }
  const shuffled=[930,270,54,702,30,749,198,570,1079,450,102,750,0,690,262,390,168];const seek=[];
  for(const f of shuffled){await page.evaluate(f=>window.__seekFilm(f),f);await page.evaluate(()=>new Promise(r=>requestAnimationFrame(()=>requestAnimationFrame(r))));const b=await page.screenshot({type:'png'});const hash=createHash('sha256').update(b).digest('hex');const domEqual=JSON.stringify(await page.evaluate(fingerprint))===domSignatures[f];let pixelMeanAbsoluteError=0;if(hash!==signatures[f]){const other=path.join(out,'frames','reseek-'+String(f).padStart(4,'0')+'.png');await writeFile(other,b);pixelMeanAbsoluteError=Number(run(process.env.EVERWHILE_PYTHON||'C:/conda_envs/myenv/python.exe',[path.join(root,'scripts/pixel-compare.py'),path.join(out,'frames',String(f).padStart(4,'0')+'.png'),other]).stdout.trim());}seek.push({frame:f,byteEqual:hash===signatures[f],domEqual,pixelMeanAbsoluteError,equal:domEqual&&pixelMeanAbsoluteError<.06});}
  await page.evaluate(()=>window.__seekFilm(960));const cdp=await page.createCDPSession();await cdp.send('DOM.enable');await cdp.send('CSS.enable');const doc=await cdp.send('DOM.getDocument');const fonts=[];
  for(const selector of ['#brand-name','#end-title']){const {nodeId}=await cdp.send('DOM.querySelector',{nodeId:doc.root.nodeId,selector});fonts.push({selector,...await cdp.send('CSS.getPlatformFontsForNode',{nodeId})});}
  const mandatoryOnset=[450,570,690].map((f,i)=>({frame:f,visible:boxes[f].find(x=>x.id==='pulse-'+[5,10,15][i]).visible,previousVisible:boxes[f-1].find(x=>x.id==='pulse-'+[5,10,15][i]).visible}));
  const endOnset={frame:930,full:boxes[930].filter(x=>['brand-icon','brand-name','end-title'].includes(x.id)).every(x=>x.visible),previousHidden:boxes[929].filter(x=>['brand-icon','brand-name','end-title'].includes(x.id)).every(x=>!x.visible)};
  const safe=Object.values(boxes).flat().filter(x=>x.visible).every(x=>x.x>=0 && x.y>=0 && x.x+x.width<=720.5 && x.y+x.height<=1280.5);
  const qa={status:'TECHNICAL_CHECK_ONLY',browserErrors:errors,sequentialShuffledSeek:seek,fontProof:fonts,boxes,mandatoryOnset,endOnset,criticalTextInCanvas:safe,captureZeroRepaint:{method:'entire immutable PNG rendered only as img with proportional scale; no internal masking/overlays',sha256:createHash('sha256').update(await readFile(path.join(root,'assets/reference/today-quick-start.png'))).digest('hex')},subjectiveFullViewing:'NOT_RUN',completeListening:'NOT_RUN'};
  await writeFile(path.join(out,'BROWSER_QA.json'),JSON.stringify(qa,null,2)+'\n');
  if(errors.length||seek.some(x=>!x.equal)||mandatoryOnset.some(x=>!x.visible||x.previousVisible)||!endOnset.full||!endOnset.previousHidden||!safe)throw Error('Browser QA failed, see BROWSER_QA.json');
  console.log('Frames, shuffled seek, onset, safe bounds and real font proof recorded.');
}finally{await browser.close();server.close();}
// Framework gate retained separately, so it cannot be confused with custom QA.
const r=run(process.execPath,[cli,'check',project,'--json','--at','0.5,1.2,2,3.5,5.8,8,10,12,14,16','--timeout','30000']);
await writeFile(path.join(out,'HYPERFRAMES_CHECK.json'),r.stdout);
