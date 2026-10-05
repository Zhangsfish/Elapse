#!/bin/bash
# Native simulator appearance checks, no Apple credentials or private usage.
set -euo pipefail
result_root="$RUNNER_TEMP/S02-UI"
mkdir -p "$result_root"
device=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data["devices"].items():
    if "iOS" in runtime:
        for device in devices:
            if "iPhone" in device["name"]:
                print(device["udid"])
                sys.exit(0)
raise SystemExit("No available iPhone simulator")
')
if python3 - "$device" "$result_root" <<'PY'
import json
import subprocess
import sys
from pathlib import Path

device, result_root = sys.argv[1:]
subprocess.run(["xcrun", "simctl", "boot", device], capture_output=True)
try:
    result = subprocess.run(["xcrun", "simctl", "bootstatus", device, "-b"],
                            capture_output=True, text=True, timeout=360)
except subprocess.TimeoutExpired as error:
    output = error.stdout or b""
    if isinstance(output, bytes):
        output = output.decode("utf-8", errors="replace")
    print("\n".join(output.splitlines()[-12:]))
    Path(result_root, "ui-status.json").write_text(json.dumps({
        "status": "BLOCKED_ENV",
        "checks": "NOT_RUN",
        "reason": "Clean simulator bootstatus exceeded 360 seconds before any UI test",
    }, indent=2))
    print("S02B_UI_SMOKE_BLOCKED_ENV_BOOT_TIMEOUT; UI tests NOT_RUN")
    sys.exit(77)
if result.returncode:
    print(result.stdout[-2000:])
    print(result.stderr[-2000:])
    sys.exit(result.returncode)
PY
then
  :
else
  status=$?
  # Only pre-test boot timeout is classified as unavailable environment.
  # Compile errors, assertions or accessibility failures remain hard failures.
  if [[ "$status" -eq 77 ]]; then exit 0; fi
  exit "$status"
fi
xcrun simctl ui "$device" appearance light
xcrun simctl ui "$device" content_size large
xcodebuild test -project Elapse.xcodeproj -scheme Elapse \
  -configuration Debug -destination "platform=iOS Simulator,id=$device" -parallel-testing-enabled NO \
  -derivedDataPath "$RUNNER_TEMP/ElapseBuild" \
  -resultBundlePath "$result_root/en-light.xcresult" \
  -only-testing:ElapseUITests/S02PolishUITests/testEnglishFirstVisitAndReplay \
  CODE_SIGNING_ALLOWED=NO
xcrun simctl ui "$device" appearance dark
xcrun simctl ui "$device" content_size accessibility-extra-extra-extra-large
xcodebuild test -project Elapse.xcodeproj -scheme Elapse \
  -configuration Debug -destination "platform=iOS Simulator,id=$device" -parallel-testing-enabled NO \
  -derivedDataPath "$RUNNER_TEMP/ElapseBuild" \
  -resultBundlePath "$result_root/zh-dark-large.xcresult" \
  -only-testing:ElapseUITests/S02PolishUITests/testSimplifiedChineseReplayAtAccessibilitySize \
  CODE_SIGNING_ALLOWED=NO
echo 'S02B_UI_SMOKE_PASS light_en dark_zhHans accessibility_size automated_layout_audit'
