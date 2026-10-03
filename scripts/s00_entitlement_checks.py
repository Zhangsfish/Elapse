"""Small, fail-closed Family Controls plist checks shared by CI audits.

Callers print only fixed status words, never raw entitlement or profile data.
"""

from pathlib import Path
import plistlib


FAMILY_CONTROLS = "com.apple.developer.family-controls"
EXPECTED_FILES = {
    "Elapse": "App/Elapse.entitlements",
    "ElapseMonitor": "MonitorExtension/ElapseMonitor.entitlements",
    "ElapseReport": "ReportExtension/ElapseReport.entitlements",
}


def family_controls_status(blob: bytes, *, profile: bool = False) -> str:
    """Return TRUE, MISSING, NOT_TRUE, or READ_ERROR without leaking data."""
    if not blob:
        return "READ_ERROR"
    try:
        value = plistlib.loads(blob)
    except (plistlib.InvalidFileException, ValueError, TypeError, OverflowError):
        return "READ_ERROR"
    if not isinstance(value, dict):
        return "READ_ERROR"
    if profile:
        value = value.get("Entitlements")
        if not isinstance(value, dict):
            return "READ_ERROR"
    if FAMILY_CONTROLS not in value:
        return "MISSING"
    return "TRUE" if value[FAMILY_CONTROLS] is True else "NOT_TRUE"


def file_status(path: Path, *, profile: bool = False) -> str:
    try:
        return family_controls_status(path.read_bytes(), profile=profile)
    except OSError:
        return "READ_ERROR"


def expected_path_status(value: str | None, expected: str, project_root: Path) -> str:
    if not value:
        return "MISSING"
    path = Path(value)
    if not path.is_absolute():
        path = project_root / path
    return "EXPECTED" if path.resolve() == (project_root / expected).resolve() else "UNEXPECTED"
