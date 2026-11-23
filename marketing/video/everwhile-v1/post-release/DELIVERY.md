# Everwhile — 上架后双语下载版

Owner request: 2026-11-23. Base main:
`35ff10a58be815f7c67744cb5d2c70b3bbb2d583`. Implementation:
`e32e85664cecbb406d0a584d32995c81369f12cc`.
Later commits contain packaging/evidence, not changed film composition.
Branch: `codex/promo-live-download-bilingual`. No self-merge/public posting.

## 成片

`outputs/EVERWHILE_EN_1080.mp4` / `EVERWHILE_ZH_HANS_1080.mp4`:
1080×1920, 18.000s,60fps,1080frames,SDR. Corresponding `_720.mp4` files are
720×1280 previews. `ENCODED_END_CARD_EN.png` / `ENCODED_END_CARD_ZH_HANS.png`
are extracted from the actual final MP4, useful for saving/scanning the QR.
`BILINGUAL_REVIEW.jpg` shows encoded end cards and sample product frames.

English: retain frames0–929 from the owner-approved R2 via video packet copy;
replace only the2.5s ending from15.5s. Chinese: faithful localization of the same
R2 composition/footage/timeline with genuine shipped Chinese Quick Start Today
capture. No previous Chinese Everwhile film exists in the repo; local WorkBuddy
video inspected belongs to Lecture Asset and was not used. Original R2/P01 files
remain immutable. Both films copy the approved AAC data, not a new mix.

## 真实下载入口

- English QR: https://apps.apple.com/us/app/everwhile/id6818551574
- 中文 QR: https://apps.apple.com/cn/app/everwhile/id6818551574

Both publicly verified2026-11-23 against Apple lookup: Everwhile,
`com.zhangsfish.elapse`,ID6818551574; actual app HTML and final URL checked, not
HTTP200 alone. Evidence: `PUBLIC_PROVENANCE.json`. Existing host proxy was used
for cross-region checks; direct mainland egress can redirect a US URL to Apple's
generic Today page. Storefront/account restrictions are controlled by Apple;
the QR does not bypass them. No third-party shortener, tracking or TestFlight.

High-contrast QR:33modules +4module quiet zone,12px/module at native size492px.
Static/full from930f; retained18s duration means viewers may pause/save the final
card. Text also identifies Everwhile / App Store and displays its Apple ID URL.

## 检查与边界

Commands (existing environment, no installs):

```text
python post-release/prepare.py
node post-release/build.mjs
node post-release/snapshot.mjs
node post-release/render.mjs all
python post-release/verify.py
node --test scripts/contract.test.mjs post-release/contract.test.mjs
python scripts/check-assets.py
```

Actual measurements: `outputs/TEST_RESULTS.json`; media hashes:
`outputs/ARTIFACTS.json`; frame/text/font bounds: `outputs/BROWSER_QA.json`.
QR gates scan actual encoded frames930/960/1079 in both native and preview films,
plus a540×960 CRF28 recompression. Verify all930 earlier English decoded frame
hashes and approved AAC packet data, full decode/frame count, finite unclipped
audio and exact Chinese raw crop pixels. Software decoder checks are not a
claim of observed iPhone camera scanning.

Existing Node24.15.0,HyperFrames0.8.132,GSAP3.15.0,esbuild0.28.2,FFmpeg9.0.1,
Chrome,Python3.11/Pillow/NumPy/qrcode/OpenCV reused. No dependencies installed.
Inter Display real600 retained; local Microsoft YaHei regular/bold CJK faces
are pinned by SHA and captured by CDP, never redistributed. R2's known repeated
photo lint warning remains; no artwork or media missing in frame checks.

Real-time complete playback / subjective listening / physical-iPhone QR scan:
NOT_RUN. Encoded frame inspection and programmatic tests are separate evidence.
No App/runtime/Today aggregation/ASC/signing/store-screenshot/region mutations.
Repository's old China-availability note is not a new distribution authorization;
this marketing task records only the independently read public pages.

Delivery state and exact-head CI URLs are posted on the PR. Public release of
the film and merge remain owner/reviewer actions. No aesthetic self-approval.
