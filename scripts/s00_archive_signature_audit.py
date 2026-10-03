#!/usr/bin/env python3
"""Safe signing check before Xcode's distribution re-signing step."""

import sys
from pathlib import Path

from s00_signed_ipa_audit import BUNDLES, check_bundle


def main(archive):
    root = archive / "Products" / "Applications"
    valid = True
    for label, relative, expected_id in BUNDLES:
        bundle = root / Path(relative).relative_to("Payload")
        try:
            result = check_bundle(label, bundle, expected_id, prefix="S00A_ARCHIVE")
        except (OSError, ValueError, KeyError):
            print(f"S00A_ARCHIVE_{label}_INSPECTION=READ_ERROR")
            result = False
        valid = result and valid
    print(f"S00A_SIGNED_ARCHIVE_AUDIT={'PASS' if valid else 'FAIL'}")
    return 0 if valid else 1


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("S00A_SIGNED_ARCHIVE_AUDIT=READ_ERROR")
        sys.exit(1)
    sys.exit(main(Path(sys.argv[1])))
