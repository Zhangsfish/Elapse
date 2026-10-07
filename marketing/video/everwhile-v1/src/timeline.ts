declare const gsap:any;
declare global{interface Window{__timelines:Record<string,any>;__directorReady:Promise<unknown>;__seekFilm:(frame:number)=>Promise<void>;__filmFrame:number;}}
gsap.defaults({force3D:false});
const tl=gsap.timeline({paused:true});tl.to('#root',{duration:18},0);
for(const[id,start,end]of[['s01',0,4.5],['s02',4.5,6.5],['s03',6.5,12.5],['s04',12.5,15.5],['s05',15.5,18]] as const){
tl.set('#'+id,{visibility:'visible'},start);tl.set('#'+id,{visibility:'hidden'},end);
}
// Edge-to-edge cuts; no whole-page slide entrances.
for(const[id,start,end]of[['open-novel',0,.9],['open-drama',.9,1.7],['open-coffee',1.7,2.5],['open-social',2.5,3.3],
['revisit-novel',3.3,3.65],['revisit-drama',3.65,3.9],['revisit-coffee',3.9,4.1],['revisit-social',4.1,4.5]] as const){
tl.set('#'+id,{opacity:1},start);tl.set('#'+id,{opacity:0},end);
}
tl.to('#novel-a .book-inner',{y:-120,duration:.9,ease:'none'},0);
tl.fromTo('#novel-m .book-inner',{y:-220},{y:-278,duration:.35,ease:'none',immediateRender:false},3.3);
tl.to('#social-a .social-inner',{y:-120,duration:.8,ease:'none'},2.5);
tl.fromTo('#social-m .social-inner',{y:-165},{y:-232,duration:.4,ease:'none',immediateRender:false},4.1);
tl.set('#question-matte',{opacity:1},2.8);
// Sound air pocket creates a negative-space landing, photograph keeps moving.
tl.to('#opening-field',{scale:.90,y:-95,duration:.25,ease:'sine.inOut'},4.25);
for(const[id,start]of[['a',4.66],['b',4.82],['c',4.98]] as const){
tl.to('#choice-'+id,{borderBottomColor:'#087cea',duration:.16,ease:'sine.out'},start);
tl.to('#check-'+id,{opacity:1,scale:1,duration:.22,ease:'back.out(1.4)'},start);
tl.to('#check-'+id+' path',{strokeDashoffset:0,duration:.18,ease:'none'},start+.04);
}
tl.to('#selection-action',{x:-140,opacity:0,duration:.25,ease:'sine.inOut'},5.30);
tl.fromTo('#interval-action',{x:140,opacity:0},{x:0,opacity:1,duration:.30,ease:'sine.inOut',immediateRender:false},5.35);
tl.fromTo('#interval',{scale:.94},{scale:1,duration:.38,ease:'back.out(1.1)',immediateRender:false},5.55);
for(const[id,start,end]of[['pulse-novel',6.5,8.5],['pulse-coffee',8.5,10.5],['pulse-social',10.5,12.5]] as const){
tl.set('#'+id,{opacity:1},start);tl.set('#'+id,{opacity:0},end);
}
tl.to('#novel-p .book-inner',{y:-260,duration:2,ease:'none'},6.5);
tl.to('#social-p .social-inner',{y:-185,duration:2,ease:'none'},10.5);
// Identical reveal + .8s clear hold + exit, no arithmetic/live-overlay timer.
for(const[m,start]of[[5,7.5],[10,9.5],[15,11.5]]){
tl.set('#pulse-'+m,{opacity:.12},start);
tl.to('#pulse-'+m,{opacity:1,y:0,duration:.10,ease:'sine.out'},start);
tl.to('#pulse-'+m,{opacity:0,y:-8,duration:.10,ease:'sine.in'},start+.90);
}
// Resolves after numeral; continues across independent product-detail cut.
tl.set('#reminder-message',{visibility:'visible'},12.55);
tl.to('#reminder-message',{opacity:1,duration:.10,ease:'sine.out'},12.55);
tl.to('#reminder-message',{opacity:0,duration:.15,ease:'sine.in'},13.2);
tl.set('#reminder-message',{visibility:'hidden'},13.35);
tl.to('#today-copy',{opacity:1,duration:.2,ease:'sine.out'},13.28);
// Only uniform reframe of exact raw UI crop; both rows remain intact.
tl.fromTo('#report-detail',{scale:.88,y:40},{scale:1,y:0,duration:.65,ease:'sine.inOut',immediateRender:false},12.5);
// No end reveal: complete lockup at930.
window.__timelines={root:tl};tl.pause(0);
window.__directorReady=Promise.all([
document.fonts.load('600 96px InterFilm'),document.fonts.load('400 57px InterFilm'),
...Array.from(document.images).map(i=>i.decode()),
...Array.from(document.querySelectorAll('video')).map(v=>v.readyState>=1?Promise.resolve():new Promise(r=>v.addEventListener('loadedmetadata',r,{once:true})))
]);
window.__seekFilm=async(frame:number)=>{
await window.__directorReady;const t=frame/60;tl.seek(t,false);window.__filmFrame=frame;
await Promise.all(Array.from(document.querySelectorAll('video')).map(async v=>{
const start=Number(v.dataset.start),d=Number(v.dataset.duration);
const target=Number(v.dataset.mediaStart)+Math.max(0,Math.min(d-1/60,t-start));v.pause();
if(Math.abs(v.currentTime-target)>1/10000)await new Promise<void>(r=>{v.addEventListener('seeked',()=>r(),{once:true});v.currentTime=target;});
}));
};
export {};
