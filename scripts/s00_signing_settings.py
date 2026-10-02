"""Inspect effective Release settings without exposing team or profile data."""

import json
import subprocess
import sys


EXPECTED_BUNDLE_IDS = {
    "Elapse": "com.zhangsfish.elapse",
    "ElapseMonitor": "com.zhangsfish.elapse.monitor",
    "ElapseReport": "com.zhangsfish.elapse.report",
}

command = [
    "xcodebuild",
    "-project",
    "Elapse.xcodeproj",
    "-scheme",
    "Elapse",
    "-configuration",
    "Release",
    "-destination",
    "generic/platform=iOS",
    "-showBuildSettings",
    "-json",
]
result = subprocess.run(command, capture_output=True, text=True, check=False)
if result.returncode:
    print(f"S00_TF_SIGNING_SETTINGS_QUERY_FAILED exit={result.returncode}")
    sys.exit(result.returncode)

try:
    targets = {item["target"]: item["buildSettings"] for item in json.loads(result.stdout)}
except (KeyError, ValueError, TypeError):
    print("S00_TF_SIGNING_SETTINGS_PARSE_FAILED")
    sys.exit(1)


def known(value: str, allowed: set[str]) -> str:
    return value if value in allowed else "OTHER_SET"


for target, expected_bundle_id in EXPECTED_BUNDLE_IDS.items():
    settings = targets.get(target)
    if not settings:
        print(f"S00_TF_SIGNING_TARGET_MISSING={target}")
        sys.exit(1)
    prefix = "S00_TF_" + target.upper()
    print(
        prefix
        + "_CODE_SIGN_STYLE="
        + known(settings.get("CODE_SIGN_STYLE", "UNSET"), {"Automatic", "Manual", "UNSET"})
    )
    print(
        prefix
        + "_CODE_SIGN_IDENTITY="
        + known(
            settings.get("CODE_SIGN_IDENTITY", "UNSET"),
            {
                "Apple Development",
                "Apple Distribution",
                "iPhone Developer",
                "iPhone Distribution",
                "UNSET",
            },
        )
    )
    print(prefix + "_DEVELOPMENT_TEAM=" + ("SET_REDACTED" if settings.get("DEVELOPMENT_TEAM") else "UNSET"))
    print(
        prefix
        + "_PROVISIONING_PROFILE_SPECIFIER="
        + ("SET_REDACTED" if settings.get("PROVISIONING_PROFILE_SPECIFIER") else "UNSET")
    )
    print(
        prefix
        + "_PRODUCT_BUNDLE_IDENTIFIER="
        + (expected_bundle_id if settings.get("PRODUCT_BUNDLE_IDENTIFIER") == expected_bundle_id else "UNEXPECTED_REDACTED")
    )
    print(
        prefix
        + "_CODE_SIGNING_ALLOWED="
        + known(settings.get("CODE_SIGNING_ALLOWED", "UNSET"), {"YES", "NO", "UNSET"})
    )
