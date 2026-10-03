# S00-C safe build evidence

- Runtime code SHA: `484041dbd6e5c6753d8640cf5565c4d92b0b07c5`; the later tested/upload SHA `132d3bd3d583a2530e974b02c8cb013a0100a0b5` adds only one-time marker commits, not runtime source changes.
- [Ordinary CI 37134142806](https://github.com/Zhangsfish/Elapse/actions/runs/37134142806): PASS, including Simulator build and Swift/Python tests.
- [Prepare-only 37134004631](https://github.com/Zhangsfish/Elapse/actions/runs/37134004631): PASS, unsigned iPhone Release build/archive; signing/upload step SKIPPED.
- [Upload 37134139991](https://github.com/Zhangsfish/Elapse/actions/runs/37134139991): `0.1.0 (38.1)`, unsigned archive PASS, automatic distribution export PASS, exact signed IPA audit PASS, upload accepted, Apple processing VALID, INTERNAL_ONLY, IN_BETA_TESTING, assigned to internal group.
- Final signed IPA SHA-256: `ca79444bb3884d4a6d8de34729d6b067763c9dd3b67ba58bde9208d52a87cba0`.
- Final signed App, Monitor, Report Family Controls claims/profile allowances: TRUE. App and Monitor App Group claims/profile allowances: EXPECTED; Report: NOT_REQUIRED.
- Prior build `0.1.0 (35.1)` uploaded successfully but is superseded by the strict-decoding code change; do not use it for S00-C device evidence.

No private key, profile, opaque app token, app identity or raw export log is reproduced here. Device observations remain NOT_RUN; Apple processing is not a Screen Time behavior test.
