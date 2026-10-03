#!/usr/bin/env bash
# Runs only inside the explicitly triggered macOS GitHub Actions upload step.
# Keep every Apple secret in Actions Secrets; never print raw signing logs.
set -euo pipefail
set +x
umask 077

for name in APPLE_TEAM_ID APP_STORE_CONNECT_KEY_ID APP_STORE_CONNECT_ISSUER_ID APP_STORE_CONNECT_PRIVATE_KEY; do
  if [[ -z "${!name:-}" ]]; then
    echo "MISSING_GITHUB_ACTIONS_SETTING: $name"
    exit 2
  fi
done

[[ "$APPLE_TEAM_ID" =~ ^[A-Z0-9]{10}$ ]] || { echo 'INVALID_TEAM_ID_FORMAT'; exit 2; }
[[ "$APP_STORE_CONNECT_KEY_ID" =~ ^[A-Z0-9]{10}$ ]] || { echo 'INVALID_API_KEY_ID_FORMAT'; exit 2; }
[[ "$APP_STORE_CONNECT_ISSUER_ID" =~ ^[0-9a-fA-F-]{36}$ ]] || { echo 'INVALID_API_ISSUER_ID_FORMAT'; exit 2; }
[[ "$APP_STORE_CONNECT_PRIVATE_KEY" == *'-----BEGIN PRIVATE KEY-----'* ]] || { echo 'INVALID_API_KEY_FILE_FORMAT'; exit 2; }

# XcodeGen owns these generated entitlement files. Guard the managed capability
# after project generation so a future spec change cannot silently erase it.
python3 - <<'PY'
import plistlib
for path in (
    "App/Elapse.entitlements",
    "MonitorExtension/ElapseMonitor.entitlements",
    "ReportExtension/ElapseReport.entitlements",
):
    with open(path, "rb") as f:
        data = plistlib.load(f)
    assert data.get("com.apple.developer.family-controls") is True, path
print("S00_TF_XCODEGEN_FAMILY_CONTROLS_ENTITLEMENTS_PASS")
PY

secret_dir=$(mktemp -d "$RUNNER_TEMP/s00-everwhile-apple.XXXXXX")
key_file="$secret_dir/AuthKey.p8"
archive_log="$secret_dir/archive.log"
export_log="$secret_dir/export.log"
export_options="$secret_dir/export-options.plist"
trap 'rm -rf "$secret_dir"' EXIT
printf '%s' "$APP_STORE_CONNECT_PRIVATE_KEY" > "$key_file"
chmod 600 "$key_file"

version="0.1.0"
build_number="${GITHUB_RUN_NUMBER}.${GITHUB_RUN_ATTEMPT}"
archive_path="$RUNNER_TEMP/S00-Everwhile-TestFlight.xcarchive"
export_path="$RUNNER_TEMP/S00-Everwhile-TestFlight-export"
code_sha=$(git rev-parse HEAD)

python3 - "$export_options" <<'PY'
import os
import plistlib
import sys

options = {
    "destination": "upload",
    "manageAppVersionAndBuildNumber": False,
    "method": "app-store-connect",
    "signingStyle": "automatic",
    "teamID": os.environ["APPLE_TEAM_ID"],
    "testFlightInternalTestingOnly": True,
}
with open(sys.argv[1], "wb") as output:
    plistlib.dump(options, output)
PY

echo "S00_TF_RELEASE_START version=$version build=$build_number code_sha=$code_sha"
if xcodebuild -project Elapse.xcodeproj -scheme Elapse \
  -configuration Release -destination 'generic/platform=iOS' \
  -archivePath "$archive_path" -derivedDataPath "$RUNNER_TEMP/S00EverwhileReleaseDerivedData" \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO \
  CURRENT_PROJECT_VERSION="$build_number" archive > "$archive_log" 2>&1; then
  echo 'S00_TF_UNSIGNED_ARCHIVE_SUCCEEDED'
else
  result=$?
  echo "S00_TF_UNSIGNED_ARCHIVE_FAILED exit=$result"
  python3 scripts/s00_testflight_diagnostics.py "$archive_log"
  exit "$result"
fi

app="$archive_path/Products/Applications/Elapse.app"
test -d "$app"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist")" = 'com.zhangsfish.elapse'
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$app/Info.plist")" = 'Everwhile'
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIconName' "$app/Info.plist")" = 'AppIcon'
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Info.plist")" = "$version"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app/Info.plist")" = "$build_number"

for extension in \
  'PlugIns/ElapseMonitor.appex|com.zhangsfish.elapse.monitor|Everwhile Monitor' \
  'Extensions/ElapseReport.appex|com.zhangsfish.elapse.report|Everwhile Report'; do
  bundle_name=${extension%%|*}
  remainder=${extension#*|}
  expected_id=${remainder%%|*}
  expected_display=${remainder#*|}
  info="$app/$bundle_name/Info.plist"
  test -f "$info"
  test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$info")" = "$expected_id"
  test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$info")" = "$expected_display"
  test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$info")" = "$build_number"
done
python3 scripts/s00_archive_inspect.py "$archive_path" --require-distribution-metadata
echo 'S00_TF_UNSIGNED_ARCHIVE_METADATA_VERIFIED'

if xcodebuild -exportArchive -archivePath "$archive_path" \
  -exportOptionsPlist "$export_options" -exportPath "$export_path" \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$key_file" \
  -authenticationKeyID "$APP_STORE_CONNECT_KEY_ID" \
  -authenticationKeyIssuerID "$APP_STORE_CONNECT_ISSUER_ID" \
  > "$export_log" 2>&1; then
  echo "S00_TF_EXPORT_UPLOAD_ACCEPTED version=$version build=$build_number code_sha=$code_sha"
  if find "$export_path" -type f -name '*.ipa' -print -quit | grep -q .; then
    echo 'S00_TF_IPA_EXPORT_PRESENT'
  else
    echo 'S00_TF_IPA_EXPORT_NOT_RETAINED_BY_XCODE'
  fi
  if ! swift scripts/s00_testflight_status.swift "$key_file" "$build_number"; then
    echo 'S00_TF_UPLOAD_ACCEPTED_PROCESSING_UNCONFIRMED'
  fi
else
  result=$?
  echo "S00_TF_EXPORT_UPLOAD_FAILED exit=$result"
  python3 scripts/s00_testflight_diagnostics.py "$export_log"
  exit "$result"
fi
