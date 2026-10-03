# S00-D safe CI / TestFlight evidence

- Code SHA `0e4bec3ffefdfaf92fd8060fdec7934e9a839827`; tested/upload SHA `bf902e93c6e87a4a675456fc2bed6679ed6a7241`.
- [Ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37141048035): PASS, XcodeGen, Simulator app + both extensions, Swift/Python tests.
- [Prepare-only](https://github.com/Zhangsfish/Elapse/actions/runs/37140907283): PASS, unsigned iPhone Release build and archive metadata; upload skipped, no Apple secrets.
- [Explicit upload](https://github.com/Zhangsfish/Elapse/actions/runs/37141044938): one-time marker valid; unsigned archive PASS; automatic distribution export PASS; exact IPA signature/profile audit PASS for main, Monitor and Report Family Controls claims; main/Monitor App Group claim PASS; report has no App Group requirement.
- Exact signed IPA SHA-256 `3f6d2f81588cfdd51239ee4fd859e6fc8c6160edbca720872d1f95da871105ec`; version/build `0.1.0 (41.1)`; upload accepted; App Store Connect processing `VALID`; `INTERNAL_ONLY`, `IN_BETA_TESTING`, internal group assigned.
- No report rendering or usage values are proven by signing, upload or processing. Device Today observation remains NOT_RUN.
