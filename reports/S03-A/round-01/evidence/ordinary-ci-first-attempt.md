# Ordinary CI first attempt — do not hide the failure

Source: 6e5a82fc60236c5bc9a408207fcd6ad102cacffa.
Run: https://github.com/Zhangsfish/Elapse/actions/runs/37501399700
Job: 112399036934. Final conclusion **FAILURE**.

Safe log summary:

- XcodeGen effective entitlement and three-bundle localization packaging PASS.
- Python 19 tests PASS; Swift 60 tests, zero failures PASS.
- English Release test progressed through all four tutorial scenes.
- After replay completion, about-close was found; immediate tutorial-skip.exists
  negative assertion failed at UITests/S02PolishUITests.swift:89.
- English: one test / one failure. Hans dark largest text: one test / zero failures.
- Script returned nonzero and preserved both result bundles. No suppression.

Diagnosis: underlying Done existence does not prove the overlaid tutorial's
dismissal animation has completed. Suspected timing race, not independently
proved product correctness. Added only a bounded actual-disappearance wait to
the test helper, retaining the final assertion. Runtime remains frozen.

[Apple waitForNonExistence documentation](https://developer.apple.com/documentation/xcuiautomation/xcuielement/waitfornonexistence(timeout:))
checked 2026-10-07. Rerun required; pending is not PASS. No owner device test added.
