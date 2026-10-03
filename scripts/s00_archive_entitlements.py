#!/usr/bin/env python3
"""Preserve generated entitlement metadata in a signing-disabled archive.

Xcode normally writes archived-expanded-entitlements.xcent during archive
signing. Our archive is unsigned; its absence made cloud distribution signing
claim none of the restricted entitlements. The exported IPA remains the gate.
"""

import plistlib
import sys
from pathlib import Path

from s00_entitlement_checks import EXPECTED_FILES, GROUP_TARGETS, file_app_group_status, file_status


BUNDLES = {
    "Elapse": "Elapse.app",
    "ElapseMonitor": "Elapse.app/PlugIns/ElapseMonitor.appex",
    "ElapseReport": "Elapse.app/Extensions/ElapseReport.appex",
}


def preserve(archive: Path) -> bool:
    root = archive / "Products" / "Applications"
    passed = True
    for target, relative in BUNDLES.items():
        source = Path(EXPECTED_FILES[target])
        destination = root / relative / "archived-expanded-entitlements.xcent"
        if (file_status(source) != "TRUE"
                or (target in GROUP_TARGETS and file_app_group_status(source) != "EXPECTED")
                or not destination.parent.is_dir()):
            print(f"S00A_ARCHIVE_{target.upper()}_ENTITLEMENTS=READ_ERROR")
            passed = False
            continue
        source_data = plistlib.loads(source.read_bytes())
        destination.write_bytes(plistlib.dumps(source_data))
        result = file_status(destination)
        group_result = file_app_group_status(destination) if target in GROUP_TARGETS else "NOT_REQUIRED"
        print(f"S00A_ARCHIVE_{target.upper()}_ENTITLEMENTS={result}")
        print(f"S00B_ARCHIVE_{target.upper()}_APP_GROUP={group_result}")
        passed = result == "TRUE" and (group_result in {"EXPECTED", "NOT_REQUIRED"}) and passed
    return passed


if __name__ == "__main__":
    if len(sys.argv) != 2 or not preserve(Path(sys.argv[1])):
        sys.exit(1)
