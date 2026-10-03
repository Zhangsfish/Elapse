# Safe signing and TestFlight evidence — Everwhile 0.1.0 (27.1)

Source: [upload run 37120646140](https://github.com/Zhangsfish/Elapse/actions/runs/37120646140), upload commit `88697237e5d87cfe54f858053cf1e7251bcea713`, Xcode 26 on GitHub-hosted `macos-26`.

Exact audited and uploaded IPA SHA-256: `b25278ad76f32be1a120aa578630dcb417c85d084fd1d9b5cd9868f66cf3f501`.

| Bundle | Distribution code signature | Family Controls claimed | Embedded profile allows |
|---|---|---|---|
| `com.zhangsfish.elapse` | VALID | TRUE | TRUE |
| `com.zhangsfish.elapse.monitor` | VALID | TRUE | TRUE |
| `com.zhangsfish.elapse.report` | VALID | TRUE | TRUE |

The script stopped all earlier exports with missing claims **before** upload. For 27.1, the audited exact IPA was uploaded once and App Store Connect reported processing `VALID`, audience `INTERNAL_ONLY`.

Source: [read-only availability run 37121122810](https://github.com/Zhangsfish/Elapse/actions/runs/37121122810): `IN_BETA_TESTING`; an internal group exists and this build is assigned to one. No raw certificate, provisioning profile, private key, JWT, tester identity, or tokenized app selection is in this evidence file.

This is signing and delivery evidence only. Device authorization, persistence, and visible notification remain `NOT_RUN`.
