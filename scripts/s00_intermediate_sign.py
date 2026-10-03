#!/usr/bin/env python3
"""Give an unsigned archive entitlement-bearing placeholder signatures.

These local signatures use no identity, certificate, profile, device list, or
Apple secret. They are never delivered. Xcode replaces them with its existing
automatic cloud-managed App Store distribution signing during export; the
exported IPA is independently verified before upload.
"""

import plistlib
import subprocess
import sys
from pathlib import Path

from s00_archive_entitlements import BUNDLES
from s00_entitlement_checks import EXPECTED_FILES, family_controls_status


ORDER = ("ElapseReport", "ElapseMonitor", "Elapse")


def sign(archive: Path) -> bool:
    root = archive / "Products" / "Applications"
    valid = True
    for target in ORDER:
        bundle = root / BUNDLES[target]
        source = Path(EXPECTED_FILES[target])
        try:
            subprocess.run(
                ["codesign", "--force", "--sign", "-", "--entitlements", str(source),
                 "--generate-entitlement-der", str(bundle)],
                capture_output=True,
                check=True,
            )
            subprocess.run(["codesign", "--verify", "--strict", str(bundle)], capture_output=True, check=True)
            output = subprocess.run(
                ["codesign", "--display", "--entitlements", "-", "--xml", str(bundle)],
                capture_output=True,
                check=True,
            ).stdout
            status = family_controls_status(output)
        except (OSError, subprocess.CalledProcessError, plistlib.InvalidFileException):
            status = "READ_ERROR"
        print(f"S00A_INTERMEDIATE_{target.upper()}_FAMILY_CONTROLS_CLAIM={status}")
        valid = status == "TRUE" and valid
    print(f"S00A_INTERMEDIATE_ARCHIVE_SIGNATURE={'PASS' if valid else 'FAIL'}")
    return valid


if __name__ == "__main__":
    if len(sys.argv) != 2 or not sign(Path(sys.argv[1])):
        sys.exit(1)
