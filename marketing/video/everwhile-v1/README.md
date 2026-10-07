# Everwhile — time becomes visible (PROMO-P01)

English 18-second, 60fps **director-review rough cut**, not an App Store preview.
Independent marketing production; App release dispatch is unchanged.

`DIRECTOR_V1.md` defines the film. `src/scenes.json` is the frame contract.
Original novel/post copy, project icon and genuine Release Quick Start sample;
two licensed Pexels motion clips. Credits, permissions and hashes are in
`ASSET_MANIFEST.json`. Actors are fictional viewing content, not endorsers.

## Reproduce without an installation

Reuse the existing isolated Lecture runtime via `EVERWHILE_TOOL_ROOT`; default
is `E:/myself/lecture_asset/marketing/video/v2`. Tool patterns are adapted from
Lecture PR #18 at a5a2e8b / R3 source cc18920. No Lecture creative/audio is reused.
The four authoring packages remain pinned at the versions in that reference.
`package-lock.json` freezes that transitive tree. No upgrade/install was run.

Place the Inter 4.1 variable font (manifest SHA) in ignored `assets/fonts/`.
Do not commit font binaries. Main headlines use real 600 / opsz32; the novel
uses the same local font at real 400 as book-content typography.

```powershell
& 'C:/conda_envs/myenv/python.exe' scripts/sound.py
node scripts/build.mjs
node --test scripts/contract.test.mjs
node scripts/snapshot-qa.mjs
node scripts/render.mjs
& 'C:/conda_envs/myenv/python.exe' scripts/export-review.py
```

Set `EVERWHILE_FFMPEG`, `EVERWHILE_FFPROBE`, `EVERWHILE_CHROME` for other hosts.
Sound needs existing NumPy; review sheets need existing Pillow. No TTS/AI API.
HyperFrames owns frame rendering and footage decode. One paused GSAP timeline,
frame/60 seeking, locally frozen media; no autoplay or render-time downloads.

## Review

- `review/EVERWHILE_P01_EN_720.mp4`: full 720×1280/60fps film with sound.
- `review/CONTACT_SHEET_EN.jpg`: six key frames from the encoded film.
- `review/TRANSITIONS_0_10_EN.jpg`: encoded opening/turn/pulse checks.
- `review/ONSET_PROOF_EN.jpg`: frames bracketing pulses and the complete end card.
- `review/music.wav`, `sfx.wav`, `mix.wav`: 48k stereo stems and common-gain mix.
- `review/*QA.json`: measured checks, not aesthetic approval.
- `review/DELIVERY.md`: exact source/test provenance and review limits.

No public posting, App Store badge/invitation, Chinese final, self-approval or
merge. The optional download-badge end card is gated on verified public listing
and separate owner distribution authorization; NOT_RUN in this first review.
