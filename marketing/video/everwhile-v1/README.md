# Everwhile — time becomes visible

## Current task: R2 visual rebuild

**P01 visuals CHANGES_REQUIRED. Execute `DIRECTOR_R2.md` on PR #26.**

Owner likes the story/music direction but rejects the picture as cheap and slide-deck-like. The director obtained the exact P01 MP4, verified its SHA, inspected decoded frames/sequence and source, and recorded the findings and replacement shot treatment in `DIRECTOR_R2.md`.

Keep18s/60fps, the story, original score/SFX, reminder onsets7.5/9.5/11.5s and complete end card15.5s. Rebuild the picture, not the audio or App: immersive content, clear visual transition, strong typographic time notices, an actually legible Today detail and a unified brand card. No new renderer, no design questionnaire, no stopping with static frames. New complete English output belongs under `review/director-r2/`.

`DIRECTOR_R2.md` supersedes conflicting V1 visual instructions. `DIRECTOR_V1.md` and P01 outputs remain historical. In particular, the setup orbit, generic outline icon heroes, repeated floating-card layout and mandatory whole-tutorial phone do not need preservation. Actual source/capture integrity, demo context, protected App paths and release boundaries still do.

This is an independent marketing film, not an App Store preview or App release prerequisite. Stop at `READY_FOR_DIRECTOR_R2_REVIEW`, no self-approval/merge/public posting.

## Existing toolchain and provenance

Reuse the isolated Lecture runtime via `EVERWHILE_TOOL_ROOT`; default is `E:/myself/lecture_asset/marketing/video/v2`. Tool patterns are adapted from Lecture PR #18 at a5a2e8b / R3 source cc18920. No Lecture campaign audio/creative material is reused. Existing packages/lockfile stay pinned; no environment upgrade needed for this directing correction.

Inter4.1 font is local in ignored `assets/fonts/`, never distributed. Display uses real600/opsz32. Original novel/post copy, current app icon and genuine Release Quick Start sample are project-owned sources. Existing licensed media source/rights/hashes are in `ASSET_MANIFEST.json`; update the ledger for the revised asset selection. An asset being licensed does not make its visual quality adequate.

HyperFrames owns frame rendering/footage decode; FFmpeg encodes/muxes. One paused GSAP timeline, frame/60 seeking, locally frozen media, no autoplay/render-time downloads. Set `EVERWHILE_FFMPEG`, `EVERWHILE_FFPROBE`, `EVERWHILE_CHROME` as already documented for the host.

## R2 reproduction (existing pinned environment, no installation)

```powershell
& 'C:/conda_envs/myenv/python.exe' scripts/prepare-r2.py
node scripts/build.mjs
node --test scripts/contract.test.mjs
node scripts/snapshot-r2.mjs
& 'C:/conda_envs/myenv/python.exe' scripts/style-proof-r2.py
node scripts/render-r2.mjs --transition
node scripts/render-r2.mjs
& 'C:/conda_envs/myenv/python.exe' scripts/export-r2.py
& 'C:/conda_envs/myenv/python.exe' scripts/check-assets.py
```

prepare-r2 requires the rights-cleared originals in ignored tmp/ (source URLs and
hashes in ASSET_MANIFEST_R2.json). Frozen derivatives already in Git suffice for
build/render. Font hash remains pinned in ASSET_MANIFEST.json; font must be
supplied locally, not redistributed. Build native1080 first; preview is a Lanczos
downsample of that new encoded film, with the AAC stream copied unchanged.
The short transition composition covers 0–8.6s at native1080, including the first
notice. Style proofs are internal gates; OLD_VS_NEW_EN uses actual final encodes.

R2 removes repeated cards/orbits and uses full-frame content, accelerating
single-image revisits, one selection-to-interval action, three identical numeral
beats, one genuine report-detail reframe and a complete brand lockup. The final
thought bridges 12.55–13.35s after the third numeral, avoiding competing headings.
Today example remains independent of the preceding advertising time compression.

## P01 historical reproduction

The following commands describe the delivered P01 pipeline at source eeae9b1c15f8976dd276d01414596597d056bf86. Reproduce ONLY in a separate checkout at that source SHA. Historical scripts are now guarded against overwriting P01 under the active R2 source. Never run sound.py against the frozen approved stems.

```powershell
& 'C:/conda_envs/myenv/python.exe' scripts/sound.py
node scripts/build.mjs
node --test scripts/contract.test.mjs
node scripts/snapshot-qa.mjs
node scripts/render.mjs
& 'C:/conda_envs/myenv/python.exe' scripts/export-review.py
```

## P01 historical review

- `review/EVERWHILE_P01_EN_720.mp4`: actual English P01 rough cut.
- `review/CONTACT_SHEET_EN.jpg`, `TRANSITIONS_0_10_EN.jpg`, `ONSET_PROOF_EN.jpg`: encoded P01 samples.
- `review/music.wav`, `sfx.wav`, `mix.wav`: preserved original audio.
- `review/*QA.json`, `review/DELIVERY.md`: historical technical checks/provenance, not art approval.
- `.github/workflows/promo-director-review-bundle.yml`: fixed-source P01 media transfer for independent review; it is not an R2 render or evidence of new visuals.

## Next delivery

Complete English18s native1080 movie +720 preview, retained audio, actual encoded keyframes/old-new comparisons and exact source/output/asset/crop evidence. Use `review/director-r2/`; provide accessible GitHub/Actions media rather than only E:/ links. Do not overwrite P01 media, modify App/store assets, generate TestFlight, submit to Apple or post publicly. Chinese and public-download variants remain gated.
