#!/usr/bin/env bash
# Create, audit and upload one App-Store-review-eligible Everwhile RC.
# Runs only in the explicitly gated S03-B GitHub Actions workflow.
set -euo pipefail
set +x
umask 077

for name in APPLE_TEAM_ID APP_STORE_CONNECT_KEY_ID APP_STORE_CONNECT_ISSUER_ID APP_STORE_CONNECT_PRIVATE_KEY S03_RC_BUILD_NUMBER; do
  if [[ -z "${!name:-}" ]]; then
    echo "S03_RC_MISSING_SETTING: $name"
    exit 2
  fi
done

[[ "$APPLE_TEAM_ID" =~ ^[A-Z0-9]{10}$ ]] || { echo 'S03_RC_INVALID_TEAM_ID_FORMAT'; exit 2; }
[[ "$APP_STORE_CONNECT_KEY_ID" =~ ^[A-Z0-9]{10}$ ]] || { echo 'S03_RC_INVALID_API_KEY_ID_FORMAT'; exit 2; }
[[ "$APP_STORE_CONNECT_ISSUER_ID" =~ ^[0-9a-fA-F-]{36}$ ]] || { echo 'S03_RC_INVALID_API_ISSUER_ID_FORMAT'; exit 2; }
[[ "$APP_STORE_CONNECT_PRIVATE_KEY" == *'-----BEGIN PRIVATE KEY-----'* ]] || { echo 'S03_RC_INVALID_API_KEY_FORMAT'; exit 2; }
[[ "$S03_RC_BUILD_NUMBER" =~ ^[0-9]+\.[0-9]+$ ]] || { echo 'S03_RC_INVALID_BUILD_NUMBER'; exit 2; }

version="0.1.0"
build_number="$S03_RC_BUILD_NUMBER"
code_sha=$(git rev-parse HEAD)

secret_dir=$(mktemp -d "$RUNNER_TEMP/s03-everwhile-rc.XXXXXX")
mkdir -m 700 "$secret_dir/private_keys"
key_file="$secret_dir/private_keys/AuthKey_${APP_STORE_CONNECT_KEY_ID}.p8"
archive_log="$secret_dir/archive.log"
export_log="$secret_dir/export.log"
upload_log="$secret_dir/upload.log"
export_options="$secret_dir/export-options.plist"
archive_path="$RUNNER_TEMP/S03-Everwhile-RC.xcarchive"
export_path="$RUNNER_TEMP/S03-Everwhile-RC-export"
trap 'rm -rf "$secret_dir"' EXIT
printf '%s' "$APP_STORE_CONNECT_PRIVATE_KEY" > "$key_file"
chmod 600 "$key_file"

python3 - "$export_options" <<'PY'
import os, plistlib, sys
options = {
    "destination": "export",
    "manageAppVersionAndBuildNumber": False,
    "method": "app-store-connect",
    "signingStyle": "automatic",
    "teamID": os.environ["APPLE_TEAM_ID"],
}
with open(sys.argv[1], "wb") as output:
    plistlib.dump(options, output)
PY

echo "S03_RC_START version=$version build=$build_number code_sha=$code_sha"

if xcodebuild -project Elapse.xcodeproj -scheme Elapse   -configuration Release -destination 'generic/platform=iOS'   -archivePath "$archive_path" -derivedDataPath "$RUNNER_TEMP/S03EverwhileRCDerivedData"   CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO   CURRENT_PROJECT_VERSION="$build_number" archive > "$archive_log" 2>&1; then
  echo 'S03_RC_UNSIGNED_ARCHIVE_SUCCEEDED'
else
  result=$?
  echo "S03_RC_UNSIGNED_ARCHIVE_FAILED exit=$result"
  python3 scripts/s00_testflight_diagnostics.py "$archive_log"
  exit "$result"
fi

app="$archive_path/Products/Applications/Elapse.app"
test -d "$app"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app/Info.plist")" = 'com.zhangsfish.elapse'
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleDisplayName' "$app/Info.plist")" = 'Everwhile'
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app/Info.plist")" = "$version"
test "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleVersion' "$app/Info.plist")" = "$build_number"
test "$(/usr/libexec/PlistBuddy -c 'Print :ITSAppUsesNonExemptEncryption' "$app/Info.plist")" = 'false'

python3 scripts/s00_archive_inspect.py "$archive_path" --require-distribution-metadata
python3 scripts/s00_archive_entitlements.py "$archive_path"
python3 scripts/s00_intermediate_sign.py "$archive_path"
echo 'S03_RC_ARCHIVE_METADATA_VERIFIED'

if xcodebuild -exportArchive -archivePath "$archive_path"   -exportOptionsPlist "$export_options" -exportPath "$export_path"   -allowProvisioningUpdates   -authenticationKeyPath "$key_file"   -authenticationKeyID "$APP_STORE_CONNECT_KEY_ID"   -authenticationKeyIssuerID "$APP_STORE_CONNECT_ISSUER_ID"   > "$export_log" 2>&1; then
  echo "S03_RC_DISTRIBUTION_EXPORT_SUCCEEDED version=$version build=$build_number"
else
  result=$?
  echo "S03_RC_DISTRIBUTION_EXPORT_FAILED exit=$result"
  python3 scripts/s00_testflight_diagnostics.py "$export_log"
  exit "$result"
fi

ipa_count=$(find "$export_path" -maxdepth 1 -type f -name '*.ipa' | wc -l | tr -d ' ')
test "$ipa_count" -eq 1
ipa=$(find "$export_path" -maxdepth 1 -type f -name '*.ipa' -print -quit)

python3 scripts/s03_review_ipa_audit.py "$ipa" "$version" "$build_number"
echo 'S03_RC_EXACT_SIGNED_IPA_AUDIT_PASSED'

if (cd "$secret_dir" && xcrun altool --upload-app -f "$ipa" -t ios   --apiKey "$APP_STORE_CONNECT_KEY_ID" --apiIssuer "$APP_STORE_CONNECT_ISSUER_ID")   > "$upload_log" 2>&1; then
  echo "S03_RC_UPLOAD_ACCEPTED version=$version build=$build_number"
else
  result=$?
  echo "S03_RC_UPLOAD_FAILED exit=$result"
  python3 scripts/s00_testflight_diagnostics.py "$upload_log"
  exit "$result"
fi

swift scripts/s03_review_status.swift "$key_file" "$build_number"
echo "S03_RC_COMPLETE version=$version build=$build_number"
