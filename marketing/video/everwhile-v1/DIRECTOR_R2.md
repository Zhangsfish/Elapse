# Everwhile — R2 visual rebuild, not a polish pass

Date: 2026-10-07
Decision: **P01 VISUAL CHANGES_REQUIRED / R2 AUTHORIZED**
Continue PR #26, branch `codex/promo-p01-time-becomes-visible`.
Director: cloud ChatGPT. Implementation: Codex. Owner judges the delivered film, not fonts, tools or individual transitions.

## 0. Start and authority

Fetch current main/branch and preserve unrelated local work. Read root AGENTS/STATUS/WORKFLOW, then this file and the current workspace AGENTS/README. This is a revision inside the independent marketing lane; it does not change release dispatch.

This file supersedes DIRECTOR_V1.md **where visual execution conflicts**. Keep V1's product truth, story, duration, audio timing and privacy boundaries. In particular, V1's giant setup orbit, mandatory whole-phone tutorial presentation, repeated card compositions and literal arc throughout are no longer requirements. Do not retain them just because an old visual test asserts them.

Do not start another renderer comparison or return a new design questionnaire. Complete the visual rebuild and deliver the whole English film on this PR. Do not merge, publish, produce a new App build or change ASC.

## 1. Evidence reviewed and verdict

Reviewed media commit: `d0aec01a5efcdb7639b7901be5a1ee9b230ba103`.
Rendered implementation: `eeae9b1c15f8976dd276d01414596597d056bf86`.
Film: `review/EVERWHILE_P01_EN_720.mp4`.
SHA256: `de859034fccd0a884de18c1da4df6a2343405abae9178e472015e13581a86dd6`.

The director obtained the actual MP4 through a secret-free, fixed-source review artifact, independently verified its SHA, ffprobed 720x1280 / 60fps / 18.000s, decoded all 1080 frames, inspected the encoded six-frame contact, dense 0–10s transition sheet and additional half-second samples through frame1079, and read film.css/timeline.ts/page.ts. This is decoded-frame/sequence/source inspection, **not a claim of uninterrupted audiovisual playback or subjective listening**. The owner's full playback feedback supplies the aesthetic rejection and the positive story/music direction.

Original-head CI: promo contract run37620067292 PASS; ordinary macOS run37620067308 CANCELLED when rechecked. Neither result changes the visual verdict. The later review-bundle workflow packages existing bytes only and is not a new rendered film.

Owner feedback: story and background sound have promise; picture looks cheap, like an old slide-deck guide-line animation. **Do not characterize this as a 5% polish request.**

Findings:
- The first shot is a beige rounded text card on pale grey, rather than an immersive reading image. Doorway footage, coffee footage and social artwork inherit the same web-card treatment.
- Around3.3s the promised rapid montage resolves into a static symmetric2x2 grid. The social photo is the same coffee image already shown as video, making four behaviors look like repeated assets.
- At4.5–6.5s two thin book/play icons inside small white tiles and a large rotating outline read as onboarding/loading. The title, orbit and dropdown occupy separate islands of empty space.
- At7.5/9.5/11.5s the important reminder is merely a small heading next to another outline circle above a content card. The premise is narrated by a diagram rather than expressed by a strong shot.
- At12.5–15.5s a whole Quick Start capture is shrunk inside a CSS phone, with another small Today card inside it. The actual value is three containers deep and too small.
- The end card adds a decorative semicircle beneath an otherwise viable brand lockup. It does not communicate new meaning or convincingly resolve into the icon.
- Source motion is dominated by scene visibility switches and repeated short y→0/power2.out entrances. Many hard cuts are fine, but repeating the same complete page layout between them is the slide-deck problem.
- Inter Display600/opsz32 is already actually loaded. Merely changing the font or rendering1080 instead of720 is not the remedy.

The previous directing brief over-prescribed icons/orbits without establishing a sufficient shot-quality threshold. This revision fixes that directing problem as well as the implementation.

## 2. Creative direction — immersive content, precise time punctuation

**内容继续流动，时间成为清楚的落点。**

Make an editorial product commercial, not a page explaining a utility. The primary objects are the content being consumed, the three time notices and one legible product proof. Cards, hardware and circles are optional compositing devices, never the default subject.

Keep a restrained Everwhile identity: natural footage colors, clean neutral light backgrounds when needed, dark ink and a controlled blue accent. Do not make everything black/gold, add neon/glass/particles, or smear blur/grain over weak compositions and call it premium.

Concrete rules:
1. Opening media may extend beyond every canvas edge. The safety area applies to text, not to photography or content surfaces.
2. No default pale-grey outer page + rounded card + drop shadow for each scene. Use a coherent screen/viewport, not floating web widgets. Shadows are only for a spatially justified surface.
3. Alternate close-up, full-frame media, typographic emphasis and product detail. Do not force identical headline origin, hero size or complete-phone framing across the movie. Maintain typography family, optical hierarchy and a sensible alignment system instead.
4. Remove the giant setup orbit, book/play outline hero tiles, spinning loading-circle beside every number and free-standing tail semicircle. Keep the official app icon unchanged. A tiny brand-colored accent is enough; not every scene needs a logo-derived illustration.
5. Every shot must have an intentional focal point when paused. If deleting its caption leaves an empty template or a generic icon, redesign it before animating.
6. Use match cuts, changes of crop and actual movement within media. Do not hide each old slide with a fade and bring in the next slide from28px below. No constant floating/bouncing or elaborate transitions unrelated to the content.

## 3. Preserve what already works

- 18.000s,1080frames,60fps,9:16,SDR.
- Four anonymous behaviors at the opening: novel, short drama, video, social browsing. No named platform.
- Before/after rhythm: dense first section, short sound air pocket4.25–4.5s, orderly time reminders while content continues.
- First reminders at frames450/570/690, i.e.7.5/9.5/11.5s.
- First complete brand end card at frame930/15.5s; hold until1080.
- The existing original music/SFX are the approved direction for this visual iteration. Preserve the existing music.wav and sfx.wav bytes as reference, and retain their score and cue timings. No new composer/TTS task, no narration, no music replacement disguised as polish. Necessary final mux/loudness adjustments must be documented.
- English copy meaning and story do not need rewriting. Minor visual segmentation may change; App Store copy must not change.
- HyperFrames/GSAP/TypeScript/FFmpeg and the existing isolated pinned environment. No second renderer or environment migration.

Audio reference hashes:
- music.wav: `b653a8207501e8b9c577273fa42c5dbbf34ddc8f6e568a128d70969fadffccc9`
- sfx.wav: `2eaa832645f1a7ef8d4c859e54ba50280cd778fdb530f754407f21877ec054fc`

## 4. Shot treatment

### S01 / 0–4.5s — get inside the content

0–0.9s: Fill the view with an elegant reading surface, not a beige card floating on grey. Treat the original novel as readable typesetting: a short compelling line, real text rhythm, content continuing past the crop. Avoid the existing oversized webpage heading plus many small paragraphs. Reading motion should feel like a page being traversed, not an entire card entering a slide.

0.9–1.7s: Full-height, carefully cropped short-drama moment. A meaningful expression or action is the hero. Review whether the existing doorway take actually supports the image quality. Do not keep it solely because it is licensed; replace it with a rights-cleared, non-branded, coherent shot if it reads like generic stock B-roll. No fake endorsement or claim that the person is an Everwhile user.

1.7–2.5s: A contrasting full-frame movement shot, such as the existing coffee macro if its native detail holds up. Avoid filling the film with that one pour.

2.5–3.3s: Distinct photographic social content with minimal, original anonymous feed cues. **Do not reuse the same coffee still as the social post.** Use a different high-quality, rights-cleared image/clip. No real account data or recognizable platform chrome.

3.3–4.25s: A short accelerating revisit of these same four behaviors: several purposeful cuts or edge-to-edge moving splits, not a static four-card dashboard. Keep one primary image at a time. Match scroll/movement direction where possible. The established question `How long / has it been` belongs in deliberate negative space or a broad integrated matte; it must remain readable across the shot change, not be pinned in an empty outer page.

4.25–4.5s: Use the existing sound subtraction. The last image contracts/reframes enough to create a clear negative-space landing for the next beat; do not freeze someone mid-action, lock a phone, flash white, or imply Everwhile stops content.

Asset decisions belong to Codex under this direction. Check current project/authorized sources first. New free licensed material may be researched and locally frozen with source/license/attribution/hash; no paid purchase/new account, copied drama/social posts, or owner private library. Do not substitute stick figures, skeleton UI or a blurred low-quality placeholder. If a necessary source truly cannot be obtained, identify that specific missing shot rather than launching another broad tool survey.

### S02 / 4.5–6.5s — selection as a quick product action, not an infographic

The transition should reuse actual content thumbnails/crops just seen. A brief selected state and a clearly set `5 min` value communicate the setup. Avoid the current two generic outlined app symbols orbiting in empty space.

Use either a close editorial selection montage from those same content surfaces or a truthful tight crop of existing shipped teaching artwork, explicitly classified as illustrative in provenance. Never fake a granted FamilyActivityPicker.

One hero at a time: selection resolves, then the interval settles. Do not show three disconnected modules forever. Short display copy `Choose your apps / Set your interval` may divide across the two actions rather than living as a static header above both. The value should look deliberately typeset, not like a web dropdown demo.

A blue accent lands with the sound; no loading spinner. By6.5s the audience understands both what they choose and why the coming time notices recur.

### S03 / 6.5–12.5s — time is the hero

Keep the novel/video/social content alive and large. Do not slow the depicted playback after enabling Everwhile, do not close an app or stop a page scroll. Only the reminder cadence becomes predictable.

At7.5/9.5/11.5s, make `5 / 10 / 15` a strong typographic event with a quiet `minutes` unit, positioned consistently within this sequence. On a1080-wide design, start around240–300px for the numeral and55–70px for the unit, then judge the actual glyph bounds and phone-sized output. These are composition starting points, not permission to cram a number into another pill.

Reserve one stable editorial area for the notice. Use the same soft reveal, clear hold of at least0.8s and exit on all three. A single restrained blue accent may punctuate the onset. No spinning/loading indicator, progress-bar arithmetic, fake notification history or red alarm.

The time notice is explicitly advertising/editorial imagery, **not a claimed persistent live overlay that Everwhile draws on top of other apps**. Do not build a fake OS status bar or show a continuously visible in-app floating timer. Content may keep moving in the neighboring/full-frame image field while the notice briefly appears and recedes.

Keep a discreet but legible `Time compressed` context cue for this demonstration, integrated into its typography rather than as a stray developer disclaimer at the bottom of every card. Provenance alone cannot explain the two-second time compression to viewers.

At the end, resolve `A reminder / Not a restriction` without adding a third competing headline over the numeral. Content continues underneath/alongside the thought; no behavioral before/after redemption.

### S04 / 12.5–15.5s — show the useful part of Today

This is a separate product shot, not the mathematical result of the preceding reminders. Do not turn15minutes into the shipped sample's30m or animate the bars as if computed from callbacks.

**The whole-phone/whole-tutorial rule from V1 is lifted for this commercial.** You may crop and uniformly scale the existing genuine Release sample to feature its Today report card. Preserve the untouched raw capture and record exact crop/source hashes. No repaint, label replacement, altered values, missing app rows presented as a complete report, or altered bar heights.

Aim for the useful report itself to occupy roughlytwo-thirds of the visual width, instead of a small card inside a phone inside the canvas. Use one deliberate move: enough original context to introduce Today, then a close, stable detail in which30m, hourly bars and per-app rows can actually be read. A crop of existing UI is a product-detail shot, not a new production screen. Retain a compact `Today · example` context label where needed so a cropped teaching sample is not falsely presented as someone's live report.

Do not preserve `Quick start / Skip / Back / Get started` in the hero image merely to satisfy an old screenshot composition rule. Cropping outside the report is allowed; painting those buttons out inside a purported full screenshot is not.

`See where the time went` supports the shot; it must not be larger than the entire useful report. No separate redundant chart animation above the chart. Allow the view to rest.

### S05 / 15.5–18s — one complete brand card

Use the actual Everwhile icon, name and `Feel time passing / Nothing else` as one deliberate lockup. Align and space them as a single composition, not separate items in a vertical web page. Remove the ornamental semicircle.

The last shot may settle into a clean neutral backdrop with a very subtle motivated tonal falloff. It must already look complete at15.5s. No late icon, slogan, badge or last-second CTA reveal. Brand-only ending remains appropriate for the current internal review; public download messaging remains a separate verified-release gate.

## 5. Typography, material and motion standards

Keep real Inter Display600/opsz32 for English brand/display. Do not open a new font hunt. Reading content may use a separate purposeful book treatment using an already licensed, available face if necessary; keep the main display system unified. No font binaries in Git or delivery.

Do not equate more whitespace with better composition. Negative space must set off a substantial subject or thought; empty bands above/below a small object are not an art direction.

Neutralize web-component styling: default36px rounded corners, identical box shadows, generic avatars, checkmarks and blue icons must not define the film. A feed can have authentic anonymous UI cues, but it is not an excuse to show a generic SaaS component kit.

Footage should have compatible exposure and contrast, and every crop must preserve a real subject. Color adjustment may unify licensed photography; do not recolor the actual App UI, force teal-orange skin, or use heavy glow to cover inconsistent shots. Grain is optional and should not be visible as an effect.

Use crisp masks/cuts and media motion; reserve a controlled camera reframe for meaning. One global CSS scale-up cannot transform the existing cards into a commercial. Actual source motion may be24/25fps repeated in the60fps composition; report it honestly and do not claim optical-flow smoothness not produced.

## 6. Production order — internal gates, one complete delivery

1. Inspect the current licensed originals and prior Lecture R2/R3 failure/production evidence. Reuse its working render/font/audio approach; do not copy its campaign assets or inherit aesthetic PASS.
2. Build three decisive style proofs in native1080: immersive opening, the first minute notice and the enlarged Today proof. Internally compare against P01 at equal display size. Check focal point, media quality, whitespace and actual UI readability. Fix them before rendering the entire sequence.
3. **Do not stop with those stills or ask the owner for another design vote.** Continue within this same task to the complete visual rebuild once they meet the direction.
4. Preserve audio reference/timings; run a short transition render to verify that the dense opening and stable time beats are visually different, not simply fast/slow slide entrances.
5. Render the full18s English R2 at native1080x1920,60fps and a720x1280 review copy derived from it. Do not enlarge the old720 movie and label it a1080 redesign.
6. Inspect actual encoded stills/transitions and the whole temporal sequence. Distinguish real-time audiovisual viewing/listening from decoded-frame inspection and waveform checks. No invented subjective PASS.
7. Update local scene data, README/AGENTS and obsolete layout assertions coherently. Keep timing/source/protected-path/privacy safeguards. Changing a visual contract must not disable real tests or relabel an old PASS for new media.

## 7. Deliverables and final gate

New output directory: `review/director-r2/`. Preserve P01 review media and its source SHA; do not overwrite historical evidence.

Deliver:
- `EVERWHILE_R2_EN_1080.mp4` and `EVERWHILE_R2_EN_720.mp4`, full18s with the retained score/SFX;
- `CONTACT_SHEET_EN.jpg`, from actual encoded R2 frames;
- old-versus-new comparison for opening, setup/time notice and Today at equal image scale;
- exact transition samples around4.5s,6.5s and12.5s, plus the3 minute onsets and first complete end card;
- source/film/asset/crop/audio hashes, license evidence for any changed media and a concise delivery note;
- a normal GitHub/Actions downloadable video reference, not only an E:/ local path. The fixed-source P01 director bundle remains historical; do not pretend it contains R2.

Minimum technical checks: correct18s/1080frames/60fps, full decode, no clipping/missing media/font fallback, deterministic frame/media time on shuffled seeks, original UI pixels preserved within documented crop/scale tolerance, no private data, cue timing preserved, audio decoded and not clipped, frozen runtime/store-assets unchanged. Record implementation/rendered SHA separately from later reports. Do not turn quantitative checks into an aesthetic score.

Final director acceptance questions:
- Does the opening feel like moving through content rather than looking at four widgets?
- Is there a meaningful visual turn when time becomes perceptible, without implying content is blocked/slowed?
- Are the three minutes clear, memorable and consistent without loading-circle imagery?
- Can the Today proof actually be read on a phone-sized preview?
- Could three stopped frames work as intentional campaign images rather than onboarding slides?
- Does the complete film retain the story/music that the owner liked?

Stop `READY_FOR_DIRECTOR_R2_REVIEW` with the actual complete English films. Chinese/final publication remain gated. No self-approval, merge, App/runtime/store screenshot/signing/TestFlight/ASC changes or public posting. The marketing film must not delay or alter the app release.
