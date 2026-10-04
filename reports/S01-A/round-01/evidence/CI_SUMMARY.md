# Safe CI/TestFlight evidence

No logs, signing secrets, profiles, selected tokens or screenshots are mirrored here. Linked GitHub runs are the evidence source.

- Implementation `bac88e961e0a1dcfbf12c4bc5285c182a72a47a8`: [ordinary CI 37179340332](https://github.com/Zhangsfish/Elapse/actions/runs/37179340332) PASS (XcodeGen, App/Monitor/Report Simulator build, helper validation, Swift logic tests).
- Prepare-only marker `ca68109b2ae96dbcd142f68810c98c1cad6790d6`: [run 37179460432](https://github.com/Zhangsfish/Elapse/actions/runs/37179460432) PASS (unsigned iPhone Release build/archive; upload skipped).
- Upload marker `514ae6958d018bf1d5861f834cbea2efab4a4a97`: [ordinary CI 37179600062](https://github.com/Zhangsfish/Elapse/actions/runs/37179600062) PASS; [TestFlight run 37179597166](https://github.com/Zhangsfish/Elapse/actions/runs/37179597166) PASS.
- Safe status lines from upload run: distribution export succeeded; exact signed IPA audit passed; upload accepted; `PROCESSING_STATUS_VALID build=44.1`; `BUILD_AUDIENCE=INTERNAL_ONLY`; `INTERNAL_BETA_STATE=IN_BETA_TESTING`; internal group exists and build assigned. These facts do **not** establish the 299-event device registration result.
- One-time markers were deleted after completion. No ordinary branch commit is configured to upload by default.
