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

Status: IN_PROGRESS. Final output hashes, tested source and limits go in DELIVERY
and TEST_RESULTS. Screenshot/sample review is not real-time playback/listening.
