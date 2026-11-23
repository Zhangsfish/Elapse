import test from 'node:test';import assert from 'node:assert/strict';import {readFile} from 'node:fs/promises';import {createHash} from 'node:crypto';
const read=p=>readFile(new URL(p,import.meta.url));
const provenance=JSON.parse(await read('./PUBLIC_PROVENANCE.json'));
test('verified public download URLs identify real Everwhile, no redirects/shorteners',()=>{
 for(const [lang,country]of [['en','us'],['zh-Hans','cn']]){const s=provenance.storefronts[lang];assert.equal(s.url,`https://apps.apple.com/${country}/app/everwhile/id6818551574`);assert.equal(s.resolvedURL,s.url);assert.equal(s.HTTPStatus,200);assert.equal(s.bundleID,'com.zhangsfish.elapse');assert.equal(s.quietZoneModules,4);}
});
test('frozen R2 source, audio and original English movie retained',async()=>{
 const b=await read('../review/director-r2/EVERWHILE_R2_EN_1080.mp4');assert.equal(createHash('sha256').update(b).digest('hex'),'f938e6e9f4efb17d5cbefc8e353db29de131f4b750e9b99859614632302a451c');
 for(const [f,hash]of [['music','b653a8207501e8b9c577273fa42c5dbbf34ddc8f6e568a128d70969fadffccc9'],['sfx','2eaa832645f1a7ef8d4c859e54ba50280cd778fdb530f754407f21877ec054fc']])assert.equal(createHash('sha256').update(await read(`../review/${f}.wav`)).digest('hex'),hash);
});
test('Chinese is faithful localized composition with genuine untouched sample',async()=>{
 const t=JSON.parse(await read('./translations.json'));assert.equal(t['<span>minutes</span>'],'<span>分钟</span>');assert.equal(t['Feel time passing<br><span>Nothing else</span>'],'感受时间流逝。<br><span>仅此而已。</span>');assert.equal(t['Time compressed'],'时间压缩演示');assert.equal(provenance.chineseToday.repaint,false);
 for(const lang of ['en','zh-Hans'])assert.equal(createHash('sha256').update(await read(`./assets/qr-${lang}.png`)).digest('hex'),provenance.storefronts[lang].qrSHA256);
});
test('all delivered media hashes and measured gates pass',async()=>{
 const results=JSON.parse(await read('./outputs/TEST_RESULTS.json'));assert.equal(results.englishFirst930DecodedFramesByteEqual,true);assert.equal(results.genuineChineseCropPixelEqual,true);assert.equal(results.movies.length,4);
 for(const m of results.movies){assert.equal(m.frames,1080);assert.equal(m.seconds,18);assert.equal(m.approvedAACPacketDataEqual,true);assert.equal(m.fullDecode,'PASS');assert.ok(m.qrFromEncodedFrames.length>=3);}
 const manifest=JSON.parse(await read('./outputs/ARTIFACTS.json'));for(const m of manifest.files)assert.equal(createHash('sha256').update(await read('./outputs/'+m.file)).digest('hex'),m.sha256);
});
