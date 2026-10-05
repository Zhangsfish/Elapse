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
xcrun simctl boot "$device" || xcrun simctl bootstatus "$device" -b
xcrun simctl bootstatus "$device" -b
xcrun simctl ui "$device" appearance light
xcrun simctl ui "$device" content_size large
xcodebuild test -project Elapse.xcodeproj -scheme Elapse \
  -configuration Debug -destination "platform=iOS Simulator,id=$device" -parallel-testing-enabled NO \
  -derivedDataPath "$RUNNER_TEMP/ElapseBuild" \
  -resultBundlePath "$result_root/en-light.xcresult" \
  -only-testing:ElapseUITests/S02PolishUITests/testEnglishHomeAndOptionalTeaching \
  CODE_SIGNING_ALLOWED=NO
xcrun simctl ui "$device" appearance dark
xcrun simctl ui "$device" content_size accessibility-extra-extra-extra-large
xcodebuild test -project Elapse.xcodeproj -scheme Elapse \
  -configuration Debug -destination "platform=iOS Simulator,id=$device" -parallel-testing-enabled NO \
  -derivedDataPath "$RUNNER_TEMP/ElapseBuild" \
  -resultBundlePath "$result_root/zh-dark-large.xcresult" \
  -only-testing:ElapseUITests/S02PolishUITests/testSimplifiedChineseHomeAtAccessibilitySize \
  CODE_SIGNING_ALLOWED=NO
echo 'S02B_UI_SMOKE_PASS light_en dark_zhHans accessibility_size automated_layout_audit'
