#!/usr/bin/env bash
# Runs only inside the explicitly triggered macOS GitHub Actions upload step.
# Keep every Apple secret in Actions Secrets; never print raw signing/provisioning contents.
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

secret_dir=$(mktemp -d "$RUNNER_TEMP/s00-everwhile-apple.XXXXXX")
key_file="$secret_dir/AuthKey.p8"
archive_log="$secret_dir/archive.log"
signed_export_log="$secret_dir/signed-export.log"
upload_log="$secret_dir/upload.log"
signed_options="$secret_dir/signed-export-options.plist"
upload_options="$secret_dir/upload-options.plist"
signed_unpack="$secret_dir/signed-ipa"
trap 'rm -rf "$secret_dir"' EXIT
printf '%s' "$APP_STORE_CONNECT_PRIVATE_KEY" > "$key_file"
chmod 600 "$key_file"

version="0.1.0"
build_number="${GITHUB_RUN_NUMBER}.${GITHUB_RUN_ATTEMPT}"
archive_path="$RUNNER_TEMP/S00-Everwhile-TestFlight.xcarchive"
signed_export_path="$RUNNER_TEMP/S00-Everwhile-Signed-export"
upload_export_path="$RUNNER_TEMP/S00-Everwhile-TestFlight-export"
code_sha=$(git rev-parse HEAD)

write_export_options() {
  local destination="$1"
  local output="$2"
  DESTINATION="$destination" python3 - "$output" <<'PY'
import os
import plistlib
import sys

options = {
    "destination": os.environ["DESTINATION"],
    "manageAppVersionAndBuildNumber": False,
    "method": "app-store-connect",
    "signingStyle": "automatic",
    "teamID": os.environ["APPLE_TEAM_ID"],
}
if os.environ["DESTINATION"] == "upload":
    options["testFlightInternalTestingOnly"] = True
with open(sys.argv[1], "wb") as output:
    plistlib.dump(options, output)
PY
}

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
app_info="$app/Info.plist"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app_info")" = 'com.zhangsfish.elapse'
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$app_info")" = 'Everwhile'
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIconName' "$app_info")" = 'AppIcon'
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app_info")" = "$version"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app_info")" = "$build_number"

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
echo 'S00_TF_UNSIGNED_ARCHIVE_METADATA_VERIFIED'
python3 scripts/s00_archive_inspect.py "$archive_path" --require-distribution-metadata

# First export a distribution-signed IPA without uploading it. This lets CI inspect
# the actual code signature and the actual distribution provisioning profiles.
rm -rf "$signed_export_path"
write_export_options export "$signed_options"
if xcodebuild -exportArchive -archivePath "$archive_path" \
  -exportOptionsPlist "$signed_options" -exportPath "$signed_export_path" \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$key_file" \
  -authenticationKeyID "$APP_STORE_CONNECT_KEY_ID" \
  -authenticationKeyIssuerID "$APP_STORE_CONNECT_ISSUER_ID" \
  > "$signed_export_log" 2>&1; then
  echo 'S00_TF_SIGNED_EXPORT_SUCCEEDED'
else
  result=$?
  echo "S00_TF_SIGNED_EXPORT_FAILED exit=$result"
  python3 scripts/s00_testflight_diagnostics.py "$signed_export_log"
  exit "$result"
fi

signed_ipa=$(find "$signed_export_path" -type f -name '*.ipa' -print -quit)
if [[ -z "$signed_ipa" ]]; then
  echo 'S00_TF_SIGNED_IPA_MISSING'
  exit 3
fi
mkdir -p "$signed_unpack"
unzip -q "$signed_ipa" -d "$signed_unpack"
signed_app=$(find "$signed_unpack/Payload" -maxdepth 1 -type d -name '*.app' -print -quit)
if [[ -z "$signed_app" ]]; then
  echo 'S00_TF_SIGNED_APP_MISSING'
  exit 3
fi

check_signed_bundle() {
  local bundle="$1"
  local expected_id="$2"
  local expected_display="$3"
  local tag="$4"
  local info="$bundle/Info.plist"
  local code_entitlements="$secret_dir/$tag-code-entitlements.plist"
  local profile_plist="$secret_dir/$tag-profile.plist"

  test -f "$info"
  test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$info")" = "$expected_id"
  test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$info")" = "$expected_display"

  if ! codesign -d --entitlements :- "$bundle" > "$code_entitlements" 2>/dev/null; then
    echo "S00_TF_SIGNED_ENTITLEMENTS_UNREADABLE bundle=$expected_id"
    return 1
  fi
  if [[ ! -f "$bundle/embedded.mobileprovision" ]]; then
    echo "S00_TF_SIGNED_PROFILE_MISSING bundle=$expected_id"
    return 1
  fi
  if ! security cms -D -i "$bundle/embedded.mobileprovision" > "$profile_plist" 2>/dev/null; then
    echo "S00_TF_SIGNED_PROFILE_UNREADABLE bundle=$expected_id"
    return 1
  fi

  python3 - "$code_entitlements" "$profile_plist" "$expected_id" <<'PY'
import plistlib
import sys

code_path, profile_path, bundle_id = sys.argv[1:]
try:
    code = plistlib.loads(open(code_path, "rb").read())
except Exception:
    code = {}
try:
    profile = plistlib.loads(open(profile_path, "rb").read())
except Exception:
    profile = {}

key = "com.apple.developer.family-controls"
code_ok = code.get(key) is True
profile_entitlements = profile.get("Entitlements")
profile_ok = isinstance(profile_entitlements, dict) and profile_entitlements.get(key) is True
print(
    "S00_TF_SIGNED_FAMILY_CONTROLS "
    f"bundle={bundle_id} code_signature={str(code_ok).lower()} "
    f"profile={str(profile_ok).lower()}"
)
raise SystemExit(0 if code_ok and profile_ok else 1)
PY
}

signed_failure=0
check_signed_bundle "$signed_app" 'com.zhangsfish.elapse' 'Everwhile' main || signed_failure=1
check_signed_bundle "$signed_app/PlugIns/ElapseMonitor.appex" 'com.zhangsfish.elapse.monitor' 'Everwhile Monitor' monitor || signed_failure=1
check_signed_bundle "$signed_app/Extensions/ElapseReport.appex" 'com.zhangsfish.elapse.report' 'Everwhile Report' report || signed_failure=1
if [[ "$signed_failure" -ne 0 ]]; then
  echo 'S00_TF_SIGNED_FAMILY_CONTROLS_PRECHECK_FAILED'
  exit 3
fi
echo 'S00_TF_SIGNED_FAMILY_CONTROLS_PRECHECK_PASS'

# Only after the locally inspectable distribution-signed package passes do we
# ask Xcode to upload the archive to App Store Connect.
rm -rf "$upload_export_path"
write_export_options upload "$upload_options"
if xcodebuild -exportArchive -archivePath "$archive_path" \
  -exportOptionsPlist "$upload_options" -exportPath "$upload_export_path" \
  -allowProvisioningUpdates \
  -authenticationKeyPath "$key_file" \
  -authenticationKeyID "$APP_STORE_CONNECT_KEY_ID" \
  -authenticationKeyIssuerID "$APP_STORE_CONNECT_ISSUER_ID" \
  > "$upload_log" 2>&1; then
  echo "S00_TF_EXPORT_UPLOAD_ACCEPTED version=$version build=$build_number code_sha=$code_sha"
  if ! swift scripts/s00_testflight_status.swift "$key_file" "$build_number"; then
    echo 'S00_TF_UPLOAD_ACCEPTED_PROCESSING_UNCONFIRMED'
  fi
else
  result=$?
  echo "S00_TF_EXPORT_UPLOAD_FAILED exit=$result"
  python3 scripts/s00_testflight_diagnostics.py "$upload_log"
  exit "$result"
fi
