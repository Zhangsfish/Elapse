#!/usr/bin/env python3
"""Fail-closed audit of the exact App Store review-candidate IPA.

Print only safe booleans/statuses and the IPA SHA256. Never print profile names,
certificate subjects, team IDs, entitlements, or provisioning payloads.
"""

import hashlib
import plistlib
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path

from s00_entitlement_checks import app_group_status, family_controls_status

BUNDLES = (
    ("APP", "Payload/Elapse.app", "com.zhangsfish.elapse"),
    ("MONITOR", "Payload/Elapse.app/PlugIns/ElapseMonitor.appex", "com.zhangsfish.elapse.monitor"),
    ("REPORT", "Payload/Elapse.app/Extensions/ElapseReport.appex", "com.zhangsfish.elapse.report"),
)

def safe_extract(archive, destination):
    for member in archive.infolist():
        path = Path(member.filename)
        if path.is_absolute() or ".." in path.parts:
            raise ValueError("unsafe IPA member")
    archive.extractall(destination)

def plist_from(command):
    result = subprocess.run(command, capture_output=True, check=True)
    return plistlib.loads(result.stdout)

def check_bundle(label, bundle, expected_id, expected_version, expected_build):
    info = plistlib.loads((bundle / "Info.plist").read_bytes())
    bundle_id = info.get("CFBundleIdentifier") == expected_id
    version = info.get("CFBundleShortVersionString") == expected_version
    build = info.get("CFBundleVersion") == expected_build

    try:
        subprocess.run(["codesign", "--verify", "--strict", str(bundle)], capture_output=True, check=True)
        codesign_ok = True
    except (OSError, subprocess.CalledProcessError):
        codesign_ok = False

    try:
        detail = subprocess.run(
            ["codesign", "-dv", "--verbose=4", str(bundle)],
            capture_output=True, text=True, check=False
        )
        authority = "Authority=Apple Distribution" in (detail.stderr or "")
    except OSError:
        authority = False

    try:
        claimed = plist_from(["codesign", "--display", "--entitlements", "-", "--xml", str(bundle)])
        fc_claim = family_controls_status(plistlib.dumps(claimed)) == "TRUE"
        group_claim = (
            app_group_status(plistlib.dumps(claimed)) == "EXPECTED"
            if label in {"APP", "MONITOR"} else True
        )
        debug_claim = claimed.get("get-task-allow") is True
    except (OSError, ValueError, subprocess.CalledProcessError, plistlib.InvalidFileException):
        fc_claim = False
        group_claim = False
        debug_claim = True

    try:
        profile = plist_from(["security", "cms", "-D", "-i", str(bundle / "embedded.mobileprovision")])
        fc_profile = family_controls_status(plistlib.dumps(profile), profile=True) == "TRUE"
        group_profile = (
            app_group_status(plistlib.dumps(profile), profile=True) == "EXPECTED"
            if label in {"APP", "MONITOR"} else True
        )
        entitlements = profile.get("Entitlements") if isinstance(profile.get("Entitlements"), dict) else {}
        debug_profile = entitlements.get("get-task-allow") is True
        has_devices = bool(profile.get("ProvisionedDevices"))
        all_devices = profile.get("ProvisionsAllDevices") is True
        app_store_like = not has_devices and not all_devices
    except (OSError, ValueError, subprocess.CalledProcessError, plistlib.InvalidFileException):
        fc_profile = False
        group_profile = False
        debug_profile = True
        app_store_like = False

    checks = {
        "BUNDLE_ID": bundle_id,
        "VERSION": version,
        "BUILD": build,
        "CODESIGN": codesign_ok,
        "APPLE_DISTRIBUTION": authority,
        "FAMILY_CONTROLS_CLAIM": fc_claim,
        "FAMILY_CONTROLS_PROFILE": fc_profile,
        "APP_GROUP_CLAIM": group_claim,
        "APP_GROUP_PROFILE": group_profile,
        "GET_TASK_ALLOW_DISABLED": not debug_claim and not debug_profile,
        "PROFILE_APP_STORE_LIKE": app_store_like,
    }
    for name, passed in checks.items():
        print(f"S03_RC_{label}_{name}={'PASS' if passed else 'FAIL'}")
    return all(checks.values())

def main(path, expected_version, expected_build):
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    print("S03_RC_IPA_SHA256=" + digest)
    valid = True
    with tempfile.TemporaryDirectory(prefix="s03-rc-ipa-") as temporary:
        with zipfile.ZipFile(path) as archive:
            safe_extract(archive, temporary)
        for label, relative, expected_id in BUNDLES:
            bundle = Path(temporary) / relative
            try:
                result = check_bundle(label, bundle, expected_id, expected_version, expected_build)
            except (OSError, ValueError, KeyError, plistlib.InvalidFileException):
                print(f"S03_RC_{label}_INSPECTION=FAIL")
                result = False
            valid = result and valid
    print("S03_RC_IPA_AUDIT=" + ("PASS" if valid else "FAIL"))
    return 0 if valid else 1

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("S03_RC_IPA_AUDIT=USAGE_ERROR")
        sys.exit(1)
    try:
        sys.exit(main(Path(sys.argv[1]), sys.argv[2], sys.argv[3]))
    except (OSError, ValueError, zipfile.BadZipFile):
        print("S03_RC_IPA_AUDIT=READ_ERROR")
        sys.exit(1)
