# S01-B CI and TestFlight safe summary

- Code SHA `2479f48efa62d26ca0d2972aaa56af7b96540766`: [ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37220713643) PASS — XcodeGen, simulator build, Swift unit tests and release helper checks.
- Marker-only upload SHA `34f95996c1c89667a40612edf41620ef5604d57e`: [ordinary CI](https://github.com/Zhangsfish/Elapse/actions/runs/37221128832) PASS with identical runtime code.
- Prepare marker SHA `73483187917768535cfd25bd702ae9deaaf77828`: [prepare-only](https://github.com/Zhangsfish/Elapse/actions/runs/37220897989) PASS — unsigned iPhone Release build/archive and archive metadata; upload step SKIPPED.
- Upload SHA `34f95996c1c89667a40612edf41620ef5604d57e`: [explicit upload](https://github.com/Zhangsfish/Elapse/actions/runs/37221126361) PASS — Everwhile `0.1.0 (47.1)`, unsigned archive, automatic distribution export, exact signed IPA audit, upload accepted, processing `VALID`, `INTERNAL_ONLY`, `IN_BETA_TESTING`, internal group assigned.
- Signed main App, Monitor and Report extension code signatures validated; Family Controls signature claims and profile allowances TRUE. Main App and Monitor App Group claims/profile allowances EXPECTED. No credential, token, profile or selected-App identity is copied here.
- Runtime lifecycle/device gate remains NOT RUN until target-iPhone observation. TestFlight delivery is a separate PASS.
