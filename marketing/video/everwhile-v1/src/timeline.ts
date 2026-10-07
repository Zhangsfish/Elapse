declare const gsap: any;
declare global {interface Window {__timelines: Record<string, any>; __directorReady: Promise<unknown>; __seekFilm: (frame: number)=>Promise<void>; __filmFrame:number;}}
gsap.defaults({force3D:false});
const tl = gsap.timeline({paused:true});
tl.to({}, {duration:18}, 0);
// Full scenes hard-cut at the specified boundaries. Entrance motion belongs to
// their inner visual objects, so no scene begins blank and the end card is complete.
for(const [id,start,end] of [['s01',0,4.5],['s02',4.5,6.5],['s03',6.5,12.5],['s04',12.5,15.5],['s05',15.5,18]] as const){
  tl.set('#'+id,{visibility:'visible'},start);tl.set('#'+id,{visibility:'hidden'},end);
}
for(const [id,start,end] of [['open-novel',0,.9],['open-drama',.9,1.7],['open-coffee',1.7,2.5],['open-social',2.5,3.3]] as const){
  tl.set('#'+id,{opacity:1},start);tl.set('#'+id,{opacity:0},end);
  tl.fromTo('#'+id,{y:22},{y:0,duration:.22,ease:'power2.out',immediateRender:false},start);
}
tl.to('#novel-a .book-inner',{y:-52,duration:.9,ease:'none'},0);
tl.to('#social-a .social-inner',{y:-75,duration:.8,ease:'none'},2.5);
tl.set('#question',{opacity:1},2.8);
tl.set('#montage',{opacity:1},3.3);
tl.fromTo('.montage-tile',{y:35,scale:.97},{y:0,scale:1,duration:.25,stagger:.03,ease:'power2.out',immediateRender:false},3.3);
tl.to('#novel-m .book-inner',{y:-40,duration:1.2,ease:'none'},3.3);
tl.to('#social-m .social-inner',{y:-55,duration:1.2,ease:'none'},3.3);
tl.to('#montage',{scale:.985,duration:.25,ease:'power1.out'},4.25);
tl.fromTo('#setup-orbit',{scale:.88,opacity:.4},{scale:1,opacity:1,duration:.4,ease:'power2.out',immediateRender:false},4.5);
tl.fromTo('#choice-a',{y:28,opacity:0},{y:0,opacity:1,duration:.25,ease:'power2.out',immediateRender:false},4.65);
tl.fromTo('#choice-b',{y:28,opacity:0},{y:0,opacity:1,duration:.25,ease:'power2.out',immediateRender:false},4.8);
tl.fromTo('#check-a',{scale:0},{scale:1,duration:.25,ease:'power2.out',immediateRender:false},4.92);
tl.fromTo('#check-b',{scale:0},{scale:1,duration:.25,ease:'power2.out',immediateRender:false},5.14);
tl.to('#check-a path',{strokeDashoffset:0,duration:.22,ease:'none'},5.0);
tl.to('#check-b path',{strokeDashoffset:0,duration:.22,ease:'none'},5.22);
tl.fromTo('#interval',{y:35,opacity:0},{y:0,opacity:1,duration:.25,ease:'power2.out',immediateRender:false},5.4);
tl.to('#interval',{scale:.97,duration:.12,ease:'power1.inOut'},5.78);
tl.to('#interval',{scale:1,backgroundColor:'#e5f1ff',duration:.2,ease:'power2.out'},5.9);
tl.to('#orbit-dot',{rotation:40,transformOrigin:'10px 290px',duration:2,ease:'none'},4.5);
for(const [id,start,end] of [['pulse-novel',6.5,8.5],['pulse-coffee',8.5,10.5],['pulse-social',10.5,12.5]] as const){
  tl.set('#'+id,{opacity:1},start);tl.set('#'+id,{opacity:0},end);
}
tl.to('#novel-p .book-inner',{y:-110,duration:2,ease:'none'},6.5);
tl.to('#social-p .social-inner',{y:-100,duration:2,ease:'none'},10.5);
// A single unbroken shared arc; background app changes never reset it.
tl.to('#time-arc',{strokeDashoffset:82,duration:6,ease:'none'},6.5);
tl.to('#time-dot',{rotation:254,transformOrigin:'0px 61px',duration:6,ease:'none'},6.5);
for(const [m,start,end] of [[5,7.5,9.3],[10,9.5,11.3],[15,11.5,12.5]]){
  tl.set('#pulse-'+m,{opacity:1},start);
  tl.fromTo('#pulse-'+m,{y:14},{y:0,duration:.18,ease:'power2.out',immediateRender:false},start);
  if(m!==15) tl.to('#pulse-'+m,{opacity:0,duration:.15},end-.15);
}
tl.set('#usage-demo',{opacity:1},6.5);
tl.set('#reminder-message',{opacity:1},11.5);
tl.fromTo('#phone',{y:28},{y:0,duration:.3,ease:'power2.out',immediateRender:false},12.5);
// No end-card reveal tween: every brand/word pixel is present from frame 930.
window.__timelines={root:tl};tl.pause(0);
window.__directorReady=Promise.all([
  document.fonts.load('600 96px InterFilm'),
  ...Array.from(document.images).map(i=>i.decode()),
  ...Array.from(document.querySelectorAll('video')).map(v=>v.readyState>=1 ? Promise.resolve():new Promise(r=>v.addEventListener('loadedmetadata',r,{once:true})))
]);
// QA only. Production renderer owns video decoding via HyperFrames. This same
// frame mapping is used to prove out-of-order preview seeking is stable.
window.__seekFilm=async(frame:number)=>{
  await window.__directorReady;
  const t=frame/60;tl.seek(t,false);window.__filmFrame=frame;
  await Promise.all(Array.from(document.querySelectorAll('video')).map(async v=>{
    const start=Number(v.dataset.start),d=Number(v.dataset.duration);
    const target=Number(v.dataset.mediaStart)+Math.max(0,Math.min(d-1/60,t-start));
    v.pause();
    if(Math.abs(v.currentTime-target)>1/10000) await new Promise<void>(r=>{v.addEventListener('seeked',()=>r(),{once:true});v.currentTime=target;});
  }));
};
export {};
