# PROMO-P01 — time becomes visible

Independent marketing work on `codex/promo-p01-time-becomes-visible`, based on
Elapse main `76838c8bd8659c379314decaa30c07ec0cb1e0ef`.

## Authority and boundaries

`DIRECTOR_V1.md` is the owner-supplied directing contract. This work does not
restart an App stage, unlock S03-C, authorize a release, or approve its own art.
Stop at READY_FOR_DIRECTOR_REVIEW after the English 18-second rough cut.
App/Shared/extensions/localization/project/store-assets/signing workflows are
read-only. No private owner media or Screen Time data. No third-party logos.

## File map

- `DIRECTOR_V1.md`: canonical director input, verbatim copy.
- `src/`: deterministic HTML/CSS/SVG/TypeScript and scene specification.
- `scripts/`: build, render, original sound synthesis, snapshots and checks.
- `assets/`: locally frozen licensed motion footage, source capture and icon.
- `ASSET_MANIFEST.json`: source/license/SHA and transformation provenance.
- `assets/fonts/`: ignored local fonts; never redistribute font binaries in Git.
- `review/`: canonical English rough cut, stems, contact sheets, checks/delivery.
- `tmp/`, `build/`, `node_modules/`: ignored reproducible working outputs/runtime.

## Reference

Lecture Asset PR #18 head a5a2e8bdab27c04bd0feb5636f0a649f29eebfe8;
R3 render source cc189202dc99ba58605cdca80e9ddbee3d0834b3. Borrow tooling
patterns only, not its content/music/voices or subjective acceptance.

## Verification

Record exact source SHA, tools and commands. Distinguish technical tests from
visual inspection and complete listening. The latter cannot be inferred from
LUFS, file decoding or a contact sheet. Future zh-Hans is NOT_RUN until review.
