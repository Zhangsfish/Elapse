# S00 audit workspace

This folder preserves the human acceptance procedure and evidence state for the Screen Time feasibility gate.

- `REAL_DEVICE_CHECKLIST.md` is the canonical short procedure for the owner to run on a physical iPhone.
- `RESULTS.md` records only executed evidence. Keep device-only claims `NOT RUN` until the owner supplies observations.
- `TESTFLIGHT.md` records the prepare-only pipeline, secret-name readiness, and explicit upload evidence. TestFlight delivery never upgrades a Screen Time behavior gate by itself.
- `s00-testflight-upload-once-20261003-extensions.json` is the unique reviewable retry marker; only its first addition on `main` may trigger the matching push upload workflow. Earlier markers were consumed and removed.
- CI/build success is compile and pure-logic evidence only; it never upgrades a Screen Time runtime gate.
- Do not store opaque app tokens, notification contents from private apps, Apple credentials, UDIDs, or signing material here.
