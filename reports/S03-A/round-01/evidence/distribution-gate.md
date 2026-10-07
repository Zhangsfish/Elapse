# Distribution preflight — existing signed 91.1 evidence

2026-10-07 · evidence reuse, not a new signing/upload run.

Primary evidence: reports/S02-B/round-01/evidence/support-menu-refinement-release.txt;
independent cloud acceptance: audits/S02/S02_B_AUDIT_2026-10-06.md.

Upload source d633b5b627933d71aac221a3bb2f6aae29fd82a2;
[run 37480245045](https://github.com/Zhangsfish/Elapse/actions/runs/37480245045).
IPA sha256 8ebd4450b98dea08fe9fa6a9ddf0c419ef54a6a903359c627988a6413703e261.
Apple accepted exact audited bytes; processing VALID, INTERNAL_ONLY,
IN_BETA_TESTING and assigned internal group at 2026-10-06T14:48:06Z.

| Final signed subject | Family Controls claim / profile allowance | Required App Group |
|---|---|---|
| com.zhangsfish.elapse | PASS / TRUE | group.com.zhangsfish.elapse PASS |
| com.zhangsfish.elapse.monitor | PASS / TRUE | group.com.zhangsfish.elapse PASS |
| com.zhangsfish.elapse.report | PASS / TRUE | None — deliberately no Report App Group entitlement |

This proves the specific distributed IPA was signed with allowed capabilities.
It does not independently read the portal's Capability Requests Assigned state,
prove future profiles, or turn TestFlight acceptance into public review approval.
Portal state: **BLOCKED_OWNER_CONFIRMATION**; exact minimal action is in
docs/APP_STORE_OWNER_CHECKLIST.md. No account credentials/profiles requested.

Important new preflight distinction: scripts/s00_testflight_release.sh explicitly
sets testFlightInternalTestingOnly=true. Apple's current guidance says these builds
cannot be submitted to customers. 91.1 stays the frozen functional baseline;
eligible App Store packaging is deferred to S03-B, not silently performed now.
