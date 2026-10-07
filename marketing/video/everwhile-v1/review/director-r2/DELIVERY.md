# R2 — English visual rebuild

Gate: **READY_FOR_DIRECTOR_R2_REVIEW** (director/owner visual verdict pending;
not self-approved). Same PR [#26](https://github.com/Zhangsfish/Elapse/pull/26),
branch `codex/promo-p01-time-becomes-visible`. Revision base:
`f8842e76f4f6e087c62e45a006118181d8253252`; current main inspected:
`76838c8bd8659c379314decaa30c07ec0cb1e0ef`.

Final visual implementation/rendered source:
`51cd610b63b120de09c36a7dfca2bb43c5f5b7a9`. Later commits contain evidence,
comparison tooling and delivery notes, not a different film. Exact output SHA256
and dimensions are in ARTIFACTS.json / ENCODE_QA.json. Review the actual films:

- EVERWHILE_R2_EN_1080.mp4 — native1080×1920 / SDR / 60fps / 18.000s /1080frames.
- EVERWHILE_R2_EN_720.mp4 — Lanczos downsample of this new encode; copied AAC.
- OLD_VS_NEW_EN.mp4 — synchronized actual P01/R2 encodes, equal360×640 columns,
  with R2 soundtrack. OLD_VS_NEW_EN.jpg samples opening/setup/notice/Today.
- CONTACT_SHEET_EN.jpg / TRANSITIONS_EN.jpg / ONSET_PROOF_EN.jpg and three
  SEQUENCE sheets — actual decoded final frames, not source-only illustrations.

## Picture changes

Edge-to-edge reading/drama/coffee/city feed replace floating web cards. Rapid
single-image revisits replace the2×2 grid. Story thumbnails resolve selection,
then a single deliberate5min value; no orbit or outline-icon hero. Three notices
use300px numerals/65px units, identical.10s reveal/.80s clear hold/.10s exit.
Reading/feed motion preserves the opening scroll rate; native footage continues
at1× with repeated24/25fps source frames, not claimed optical-flow motion.

Today is a separate report-detail shot: exact raw crop `(200,650,1120,1735)`,
800px display width, uniform scale800/920. Both App A20m/App B10m,30m and all
bars are untouched. “Today · example” distinguishes shipped teaching sample from
live private usage. Final thought resolves after the last numeral across the
Today introduction12.55–13.35s. Complete brand lockup at930f; no tail arc/CTA.

## Frozen story/audio/privacy

Original score, air pocket255–269f and reminder cues450/570/690f are retained.
music.wav / sfx.wav / mix.wav are byte-identical. Final mux uses the approved
PCM premix → AAC256k/48k; no gain, composition or cue changes. Audio reference
hashes, encoded alignment and decoded peak checks are recorded, not substitutes
for subjective listening.

New social photograph: kaya Yu, Pexels16249816. Source/license/download/hash and
all crop/derivative hashes: ASSET_MANIFEST_R2.json. Original licensed doorway and
UHD coffee sources were inspected; doorway crop retains the expression/action.
No private media, owner account/token, fake picker, fake OS notification or
live-data repaint. App/store-assets/capabilities/ASC/release workflows unchanged.
P01 movie/stems/evidence and fixed-source P01 bundle remain historical/frozen.

## Verification and limits

10 source tests; TypeScript noEmit; actual font/bounds/17 shuffled-seek checks;
HyperFrames check; native/preview full decode and audio; exact crop pixel equality
and browser/encoded interpolation tolerance. See TEST_RESULTS.json and QA JSON
for measured results. Internal native style proofs were checked at equal display
scale before the full sequence. A native0–8.6s/516f short transition trial was
decoded/inspected at source3b62bf3 before the final scroll-rate correction; the
final affected motion is rechecked in full51cd610 encode and final snapshots.

Framework warnings are disclosed, not silently promoted to an aesthetic PASS:
the same photo intentionally appears in four independently timed compositions;
scrolling text passes behind the opaque question matte/time field. Critical
campaign text has its own checked bounds. Oversize-photo inline warning does not
require external downloads at render time: local media server serves the frozen
file; actual encoded photo pixels are checked against browser samples.

Decoded temporal sequence inspection and quantitative audio checks performed.
Uninterrupted real-time audiovisual viewing/subjective listening: **NOT_RUN**.
Visual acceptance belongs to director/owner. No merge/public posting/Chinese/App
or ASC changes. Downloadable current-head R2 bundle is produced automatically by
`promo-r2-review-bundle.yml`; exact run/head evidence is posted on the PR.
