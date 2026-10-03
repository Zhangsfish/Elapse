#!/usr/bin/env bash
# Explicit, read-only App Store Connect check. Never print key or raw responses.
set -euo pipefail
set +x
umask 077

[[ "${BUILD_NUMBER:-}" =~ ^[0-9]+\.[0-9]+$ ]] || { echo 'S00A_VERIFY_BUILD_NUMBER_INVALID'; exit 2; }
for name in APP_STORE_CONNECT_KEY_ID APP_STORE_CONNECT_ISSUER_ID APP_STORE_CONNECT_PRIVATE_KEY; do
  [[ -n "${!name:-}" ]] || { echo "S00A_VERIFY_SETTING_MISSING=$name"; exit 2; }
done

secret_dir=$(mktemp -d "$RUNNER_TEMP/s00a-verify.XXXXXX")
trap 'rm -rf "$secret_dir"' EXIT
key_file="$secret_dir/AuthKey.p8"
printf '%s' "$APP_STORE_CONNECT_PRIVATE_KEY" > "$key_file"
chmod 600 "$key_file"
swift scripts/s00_testflight_status.swift "$key_file" "$BUILD_NUMBER"
