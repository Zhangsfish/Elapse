# PROMO-P01 — English rhythm rough cut

Status: **READY_FOR_DIRECTOR_REVIEW** (not artistic approval).
PR: https://github.com/Zhangsfish/Elapse/pull/26
Branch: `codex/promo-p01-time-becomes-visible`.
Base: `76838c8bd8659c379314decaa30c07ec0cb1e0ef`.
Implementation / locally tested / rendered source:
`6f6b4b12e5ef6b886d73200e5145489902d9e11f`.
Subsequent delivery-report commits do not change that source or the film.
Current exact PR head and its remote checks are authoritative in PR Checks;
this report does not turn pending checks into PASS.

## Delivered

- `EVERWHILE_P01_EN_720.mp4`: full 18.000s English 720×1280 SDR, 60fps CFR,
  1080 frames, AAC 48k stereo; original music and SFX, brand-only ending.
- `music.wav`, `sfx.wav`, `mix.wav`: separate 48k stereo PCM16 stems/premix.
- `CONTACT_SHEET_EN.jpg`: six keyframes from the encoded film.
- `TRANSITIONS_0_10_EN.jpg`, `ONSET_PROOF_EN.jpg`: actual encoded transitions,
  5/10/15-minute onset and full end-card boundary checks.
- `KEYFRAME_01_EN.png`–`KEYFRAME_06_EN.png`: actual encoded keyframes.
- `ARTIFACTS.json`: exact output hashes/sizes. Film SHA256:
  `705a80eabad0e9ff0eaffef1fbbdc1f404cdeb5377cc85fcadd6c6fdf79f5400`.

## Creative/source provenance

Four opening forms: original readable novel; licensed RDNE doorway human
conversation; licensed Michael Burrows coffee motion; original anonymous social
post using a derived licensed photo. Original seeded synthesis, 120BPM; denser
opening subdivision/syncopation, 255–270f drum/bass air pocket, simpler later
pulse. Reminders at 450/570/690f; shared visual time layer continues across
content changes. Visible `Usage demo · time compressed` is film context, not a
claim of live iOS timing. No fake notification history or system picker.

Today uses the complete, byte-unchanged shipped Release Quick Start sample
capture (`30m`, App A/B), not owner usage or callback×interval. Its original
teaching chrome remains visible. The page cut at 750f separates it from the
15-minute demo. Source, permission URLs, transforms and hashes are in
`../ASSET_MANIFEST.json`. Actors are viewing content, not product endorsers.

Lecture PR #18 / R3 source were inspected, including actual encoded reference
frames and previous failure evidence. Only tool/build/frame/audio patterns were
adapted; no Lecture voices, music, branding or creative content were reused.

## Verification and limits

Local PASS: six Node contract tests, TypeScript strict no-emit, 48 existing
Python tests, immutable-source/output hashes, PCM stem shape. Browser QA checks
56 sampled frames, 17 shuffled seeks, required onsets, safe text bounds, font
proof, immutable capture. DOM/media times match exactly on shuffled seeks;
five snapshots have tiny browser raster antialias differences (max mean RGB
error <0.003/255), not byte equality. Do not call the entire renderer
byte-identical. HyperFrames browser runtime/layout/contrast gate passes; one
nonblocking duplicate-image-discovery warning is the same social photo reused
in three explicitly placed illustration scenes.

Actual encoded MP4: all 1080 frames decode; no black/blank frames; sampled
encoded/native differences within tolerance. SFX first nonzero samples
360001/456001/552001 fall in the required frames. Decoded AAC versus original
premix has best lag 0 on a 16-sample search grid (correlation 0.999815), within
one-frame tolerance. PCM mix measured -15.02 LUFS, -4.48 dBTP; these are
technical measurements, not a listening verdict.

Manually inspected actual encoded contact, transition and onset sheets. Novel
title/body overlap and question/social collision were fixed before export.
**Full subjective film viewing and complete listening: NOT_RUN.** Art, pacing,
the six director criteria and final sound remain PENDING director review.

Remote CI checkpoint at report creation (implementation SHA above):
- PROMO contract PASS: https://github.com/Zhangsfish/Elapse/actions/runs/37618885755
- Ordinary macOS CI IN_PROGRESS: https://github.com/Zhangsfish/Elapse/actions/runs/37618885669
- Final-head outcomes: see current PR Checks / PR delivery summary, not these
  earlier run IDs. No skipped/inherited check is asserted as current-head PASS.

## Reproduction

Reuse installed Lecture isolated runtime: HyperFrames 0.8.132, GSAP 3.15.0,
TypeScript 7.0.2, esbuild 0.28.2, Puppeteer-core 25.12.0; lockfile pinned.
Node 24.15.0; Windows + system Chrome; FFmpeg/ffprobe 9.0.1; existing Python
NumPy/Pillow. Inter 4.1 local ignored font, real 600 / opsz32 headlines and
real 400 body; font SHA pinned, no font binary redistributed. No installation,
upgrade, TTS/API, purchase or new account.

Commands and configurable tool paths: `../README.md`.
`sound.py` → `build.mjs` → `contract.test.mjs` / tsc → `snapshot-qa.mjs` →
`render.mjs` → `export-review.py` → `check-assets.py`. HyperFrames owns video
decode/frame capture; FFmpeg muxes the original premix, not a real-time screen
recording engine. Local Studio preview: http://localhost:3049/#project/en
(only while this local process is running).

## Boundaries / remaining work

Protected App/Shared/extensions/localization/resources/project/store-assets and
signing/upload workflows have **no diff**. Main STATUS, App release stage,
92.1 runtime, private-data boundary and open diagnostic PR #23 are untouched.
No TestFlight/upload/review/submission/release/public posting took place.

No implementation blocker remains for this rough cut. Director review is
required before Chinese/final 1080p work. Download-badge output/distribution is
NOT_RUN, gated on verified public availability plus owner authorization; no
download invitation appears in this review. No self-approval or merge.
