#!/usr/bin/env python3
"""Fail-closed, safe summary of the exact distribution IPA before upload.

Never prints entitlements, provisioning profiles, certificate data or tool output.
See Apple TN3125: a profile allowance does not imply a signature claim.
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


def decoded_plist(command):
    result = subprocess.run(command, capture_output=True, check=True)
    return plistlib.loads(result.stdout)


def check_bundle(label, bundle, expected_id, prefix="S00A_SIGNED"):
    info = plistlib.loads((bundle / "Info.plist").read_bytes())
    identifier = info.get("CFBundleIdentifier")
    id_status = "EXPECTED" if identifier == expected_id else "MISMATCH"
    try:
        subprocess.run(["codesign", "--verify", "--strict", str(bundle)], capture_output=True, check=True)
        signature_status = "VALID"
    except (OSError, subprocess.CalledProcessError):
        signature_status = "INVALID"
    try:
        claimed = decoded_plist(["codesign", "--display", "--entitlements", "-", "--xml", str(bundle)])
        claim_status = family_controls_status(plistlib.dumps(claimed))
        group_claim_status = app_group_status(plistlib.dumps(claimed)) if label in {"APP", "MONITOR"} else "NOT_REQUIRED"
    except (OSError, ValueError, subprocess.CalledProcessError):
        claim_status = "READ_ERROR"
        group_claim_status = "READ_ERROR" if label in {"APP", "MONITOR"} else "NOT_REQUIRED"
    try:
        profile = decoded_plist(["security", "cms", "-D", "-i", str(bundle / "embedded.mobileprovision")])
        allowance_status = family_controls_status(plistlib.dumps(profile), profile=True)
        group_allowance_status = app_group_status(plistlib.dumps(profile), profile=True) if label in {"APP", "MONITOR"} else "NOT_REQUIRED"
    except (OSError, ValueError, subprocess.CalledProcessError):
        allowance_status = "READ_ERROR"
        group_allowance_status = "READ_ERROR" if label in {"APP", "MONITOR"} else "NOT_REQUIRED"
    print(f"{prefix}_{label}_BUNDLE_ID={id_status}")
    print(f"{prefix}_{label}_CODESIGN={signature_status}")
    print(f"{prefix}_{label}_FAMILY_CONTROLS_CLAIM={claim_status}")
    print(f"{prefix}_{label}_PROFILE_ALLOWANCE={allowance_status}")
    print(f"S00B_SIGNED_{label}_APP_GROUP_CLAIM={group_claim_status}")
    print(f"S00B_SIGNED_{label}_APP_GROUP_PROFILE_ALLOWANCE={group_allowance_status}")
    return all(status == required for status, required in (
        (id_status, "EXPECTED"), (signature_status, "VALID"),
        (claim_status, "TRUE"), (allowance_status, "TRUE"),
        (group_claim_status, "EXPECTED" if label in {"APP", "MONITOR"} else "NOT_REQUIRED"),
        (group_allowance_status, "EXPECTED" if label in {"APP", "MONITOR"} else "NOT_REQUIRED"),
    ))


def main(path):
    digest = hashlib.sha256(path.read_bytes()).hexdigest()
    print(f"S00A_SIGNED_IPA_SHA256={digest}")
    with tempfile.TemporaryDirectory(prefix="s00a-signed-ipa-") as temporary:
        with zipfile.ZipFile(path) as archive:
            safe_extract(archive, temporary)
        valid = True
        for label, relative, expected_id in BUNDLES:
            try:
                result = check_bundle(label, Path(temporary) / relative, expected_id)
            except (OSError, ValueError, KeyError):
                print(f"S00A_SIGNED_{label}_INSPECTION=READ_ERROR")
                result = False
            valid = result and valid
    print(f"S00A_SIGNED_IPA_AUDIT={'PASS' if valid else 'FAIL'}")
    return 0 if valid else 1


if __name__ == "__main__":
    try:
        sys.exit(main(Path(sys.argv[1])))
    except (IndexError, OSError, ValueError, zipfile.BadZipFile):
        print("S00A_SIGNED_IPA_AUDIT=READ_ERROR")
        sys.exit(1)
