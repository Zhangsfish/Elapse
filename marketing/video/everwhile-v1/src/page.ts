const novel = (id: string) => `<div class="novel" id="${id}" data-layout-allow-overflow><div class="book-inner" data-layout-allow-overflow>
  <div class="novel-kicker">THE OTHER SIDE OF THE DOOR</div>
  <div class="book-rule"></div>
  <h3>The footsteps stopped</h3>
  <div class="novel-text"><p>She waited for the second knock. It never came.</p>
  <p>Beyond the door, someone was holding their breath. The hallway light slipped beneath the frame, thin as a folded letter.</p>
  <p>“You came back,” she said.</p>
  <p>A key turned slowly on the other side.</p>
  <p>She had left it there ten years ago. Nobody else was supposed to know.</p>
  <p>For a moment, neither of them moved. Then she reached for the handle.</p>
  <p>The voice outside was softer than she remembered.</p>
  <p>“There is something you need to see.”</p></div></div></div>`;
const video = (id: string, file: string, start: number, duration: number, offset: number) =>
  `<video id="${id}" class="clip footage" data-start="${start}" data-duration="${duration}" data-media-start="${offset}" src="assets/footage/${file}" muted playsinline preload="auto"></video>`;
const social = (id: string) => `<div class="social" id="${id}"><div class="social-inner">
  <div class="post-head"><span class="avatar"></span><span>A little moment<span class="post-sub">A morning worth keeping</span></span><span class="post-dots">···</span></div>
  <img src="assets/footage/social-photo.jpg" class="post-photo" alt="Coffee pouring into a cup">
  <div class="post-icons"><svg viewBox="0 0 64 64"><path d="M32 53 9 30C-5 9 20 1 32 18 44 1 69 9 55 30Z"/></svg><svg viewBox="0 0 64 64"><path d="M10 12h44v32H25L10 56Z"/></svg></div>
  <p>One slow pour. One good beginning.</p><div class="post-comments">The light was too good to miss.<br>A small thing, kept.</div>
  <div class="next-post"><span class="avatar second"></span><span>A different kind of morning</span></div>
  </div></div>`;
export function page() {return `<!doctype html><html lang="en"><head><meta charset="utf-8"><title>Everwhile · PROMO-P01</title><link rel="stylesheet" href="film.css"></head><body>
<main id="root" data-composition-id="root" data-width="720" data-height="1280" data-duration="18">
<div id="design">
<section id="s01" class="clip scene" data-start="0" data-duration="4.5" data-track-index="0">
  <div class="opening-content content-pane" id="open-novel">${novel('novel-a')}</div>
  <div class="opening-content content-pane drama" id="open-drama">${video('drama-a','door-conversation.mp4',.9,.8,0)}<div class="drama-frame"></div></div>
  <div class="opening-content content-pane" id="open-coffee">${video('coffee-a','coffee-pour.mp4',1.7,.8,.3)}</div>
  <div class="opening-content content-pane" id="open-social">${social('social-a')}</div>
  <div id="montage"><div class="montage-tile tile-book">${novel('novel-m')}</div><div class="montage-tile tile-drama">${video('drama-m','door-conversation.mp4',3.3,1.2,1.2)}</div><div class="montage-tile tile-coffee">${video('coffee-m','coffee-pour.mp4',3.3,1.2,1.5)}</div><div class="montage-tile tile-social">${social('social-m')}</div></div>
  <h1 id="question" class="headline">How long<br>has it been</h1>
</section>
<section id="s02" class="clip scene" data-start="4.5" data-duration="2" data-track-index="0">
  <h1 class="headline setup-title">Choose your apps<br><span class="blue">Set your interval</span></h1>
  <div id="setup-orbit"><svg viewBox="0 0 640 640"><circle cx="320" cy="320" r="280" class="orbit-track"/><circle cx="320" cy="320" r="280" class="orbit-arc"/></svg><div id="orbit-dot"></div></div>
  <div class="app-choice" id="choice-a"><svg class="app-symbol" viewBox="0 0 90 90"><path d="M17 18h24c6 0 8 4 8 8v47c-4-5-8-7-16-7H17Zm56 0H49v55c4-5 8-7 16-7h8Z"/></svg><svg class="check" id="check-a" viewBox="0 0 60 60"><path d="m12 30 12 12 26-28"/></svg></div>
  <div class="app-choice" id="choice-b"><svg class="app-symbol" viewBox="0 0 90 90"><rect x="12" y="18" width="66" height="54" rx="13"/><path d="m37 30 20 15-20 15Z"/></svg><svg class="check" id="check-b" viewBox="0 0 60 60"><path d="m12 30 12 12 26-28"/></svg></div>
  <div id="interval"><span>Reminder interval</span><strong>5 min</strong><svg viewBox="0 0 32 32"><path d="m6 12 10 10 10-10"/></svg></div>
</section>
<section id="s03" class="clip scene" data-start="6.5" data-duration="6" data-track-index="0">
  <div class="pulse-content content-pane" id="pulse-novel">${novel('novel-p')}</div>
  <div class="pulse-content content-pane" id="pulse-coffee">${video('coffee-p','coffee-pour.mp4',8.5,2,2.5)}</div>
  <div class="pulse-content content-pane" id="pulse-social">${social('social-p')}</div>
  <div id="time-layer"><svg id="time-ring" viewBox="0 0 150 150"><circle cx="75" cy="75" r="61" class="time-track"/><circle cx="75" cy="75" r="61" id="time-arc" transform="rotate(-90 75 75)"/><g id="time-rotor" transform="rotate(0 75 75)"><circle id="time-dot" cx="75" cy="14" r="9"/></g></svg>
    <div id="pulse-5" class="minute">5 minutes</div><div id="pulse-10" class="minute">10 minutes</div><div id="pulse-15" class="minute">15 minutes</div></div>
  <h1 id="reminder-message">A reminder<br><span class="blue">Not a restriction</span></h1>
  <div id="usage-demo">Usage demo · time compressed</div>
</section>
<section id="s04" class="clip scene" data-start="12.5" data-duration="3" data-track-index="0">
  <h1 class="headline today-title">See where<br>the time went</h1><div class="today-sub">Total · by hour · by app</div>
  <div id="phone"><img src="assets/reference/today-quick-start.png" id="today-capture" alt="Shipped Quick Start Today sample, 30m"></div>
</section>
<section id="s05" class="clip scene" data-start="15.5" data-duration="2.5" data-track-index="0">
  <div class="brand"><img id="brand-icon" src="assets/reference/everwhile-icon.png" alt="Everwhile"><div id="brand-name">Everwhile</div></div>
  <h1 class="headline end-title" id="end-title">Feel time passing<br><span class="blue">Nothing else</span></h1>
  <svg id="end-arc" viewBox="0 0 700 360"><path d="M90 255C90 55 610 55 610 255"/><circle cx="610" cy="255" r="14"/></svg>
</section>
</div>
<audio id="music" class="clip" data-start="0" data-duration="18" data-track-index="1" src="audio/music.wav" data-volume="1"></audio>
<audio id="sfx" class="clip" data-start="0" data-duration="18" data-track-index="2" src="audio/sfx.wav" data-volume="1"></audio>
</main><script src="gsap.min.js"></script><script src="timeline.js"></script></body></html>`;}
