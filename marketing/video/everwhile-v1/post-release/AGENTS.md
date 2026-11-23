# Post-release bilingual download films

Owner request 2026-11-23: Everwhile is live; add verified App Store QR download
entry to the accepted film's ending, deliver English and Simplified Chinese.
This supersedes only R2's old brand-only/Chinese-locked marketing gates.
No App/ASC/store-assets changes, no self-merge or public posting.

Base main: 35ff10a58be815f7c67744cb5d2c70b3bbb2d583. Approved English R2 is
../review/director-r2/EVERWHILE_R2_EN_1080.mp4. Preserve that and frozen audio.
No prior Chinese Everwhile film exists in the repository; translate the accepted
composition, reuse its timing/footage and genuine Chinese Release sample capture.
Downloads/director-cut-zh-workbuddy.mp4 was inspected and is Lecture Asset, not
Everwhile. Do not use it.

prepare.py records public Apple lookup evidence, creates QR PNGs and exact raw
Chinese Today crop. build.mjs creates local-only language compositions with the
existing HyperFrames/GSAP runtime. snapshot.mjs renders frame/bounds/font evidence.
render.mjs keeps EN frames0–929 by stream copy, adds only a new final card; renders
the localized Chinese film. Both use copied approved AAC. verify.py checks full
decode, QR from encoded pixels, immutable EN prefix/audio and genuine UI crop.
contract.test.mjs is secret-free ordinary CI. outputs/ are canonical review media;
tmp/ and build/ scratch and fonts are ignored. Never commit font binaries.

Status: READY_FOR_AUDIT / OWNER_VISUAL_REVIEW_PENDING. Four full films completed;
14 source/asset tests pass. Native/preview encoded QR decode passes,540px CRF28
stress decode uses recorded grayscale/Otsu preprocessing. All930 English prefix
decoded frame hashes and all four AAC packet hashes equal the approved source.
Rendered composition e32e856; verification tool/tested source aa04753. Film hashes
and limits: outputs/TEST_RESULTS.json and ARTIFACTS.json. Exact PR head / CI URLs
are recorded on the PR. Screenshot/sample review is not real-time playback or
physical-iPhone camera validation; those remain NOT_RUN. No self-merge/posting.
