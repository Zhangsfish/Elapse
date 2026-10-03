"""Print only public app metadata from an unsigned S00 archive.

This deliberately never reads provisioning profiles, signatures, or entitlements.
"""

import json
from pathlib import Path
import plistlib
import re
import shutil
import subprocess
import sys


archive = Path(sys.argv[1])
require_metadata = "--require-distribution-metadata" in sys.argv[2:]
app = archive / "Products" / "Applications" / "Elapse.app"
info = plistlib.loads((app / "Info.plist").read_bytes())


def icon_summary(key: str) -> dict[str, object]:
    value = info.get(key)
    if not isinstance(value, dict):
        return {"present": False}
    primary = value.get("CFBundlePrimaryIcon")
    if not isinstance(primary, dict):
        return {"present": True, "primary_present": False}
    icon_name = primary.get("CFBundleIconName")
    files = primary.get("CFBundleIconFiles")
    safe_files = [
        item if isinstance(item, str) and re.fullmatch(r"AppIcon[A-Za-z0-9_-]*", item) else "OTHER"
        for item in files
    ] if isinstance(files, list) else []
    return {
        "present": True,
        "primary_present": True,
        "primary_name": "AppIcon" if icon_name == "AppIcon" else "OTHER_OR_MISSING",
        "primary_files": safe_files,
    }


orientations = {
    "UIInterfaceOrientationPortrait",
    "UIInterfaceOrientationLandscapeLeft",
    "UIInterfaceOrientationLandscapeRight",
    "UIInterfaceOrientationPortraitUpsideDown",
}


def orientation_summary(key: str) -> object:
    value = info.get(key)
    if not isinstance(value, list):
        return "MISSING_OR_NOT_ARRAY"
    return [item if item in orientations else "OTHER" for item in value]


summary = {
    "CFBundleIconName": "AppIcon" if info.get("CFBundleIconName") == "AppIcon" else "OTHER_OR_MISSING",
    "CFBundleIcons": icon_summary("CFBundleIcons"),
    "CFBundleIcons~ipad": icon_summary("CFBundleIcons~ipad"),
    "UISupportedInterfaceOrientations": orientation_summary("UISupportedInterfaceOrientations"),
    "UISupportedInterfaceOrientations~iphone": orientation_summary("UISupportedInterfaceOrientations~iphone"),
    "UIDeviceFamily": [value for value in info.get("UIDeviceFamily", []) if value in (1, 2)],
    "Assets.car": (app / "Assets.car").is_file(),
}
print("S00_ARCHIVE_METADATA=" + json.dumps(summary, sort_keys=True))


def extension_summary(bundle_name: str, folder: str) -> dict[str, object]:
    plist_path = app / folder / bundle_name / "Info.plist"
    if not plist_path.is_file():
        return {"Info.plist": False}
    plist = plistlib.loads(plist_path.read_bytes())
    ns_extension = plist.get("NSExtension")
    ex_attributes = plist.get("EXAppExtensionAttributes")
    result: dict[str, object] = {
        "Info.plist": True,
        "folder": folder,
        "NSExtension": isinstance(ns_extension, dict),
        "EXAppExtensionAttributes": isinstance(ex_attributes, dict),
    }
    if folder == "PlugIns":
        ns_extension = ns_extension if isinstance(ns_extension, dict) else {}
        point = ns_extension.get("NSExtensionPointIdentifier")
        principal = ns_extension.get("NSExtensionPrincipalClass")
        result["NSExtensionPointIdentifier"] = (
            "com.apple.deviceactivity.monitor-extension" if point == "com.apple.deviceactivity.monitor-extension"
            else ("MISSING" if point is None else "OTHER")
        )
        result["NSExtensionPrincipalClass"] = (
            "ElapseMonitor.ElapseMonitorExtension" if principal == "ElapseMonitor.ElapseMonitorExtension"
            else ("MISSING" if principal is None else "OTHER")
        )
    else:
        ex_attributes = ex_attributes if isinstance(ex_attributes, dict) else {}
        point = ex_attributes.get("EXExtensionPointIdentifier")
        result["EXExtensionPointIdentifier"] = (
            "com.apple.deviceactivityui.report-extension" if point == "com.apple.deviceactivityui.report-extension"
            else ("MISSING" if point is None else "OTHER")
        )
        result["NSExtensionPrincipalClass"] = (
            "ABSENT" if not isinstance(ns_extension, dict) or ns_extension.get("NSExtensionPrincipalClass") is None
            else "PRESENT_UNEXPECTED"
        )
    return result


extensions = {
    "ElapseMonitor.appex": extension_summary("ElapseMonitor.appex", "PlugIns"),
    "ElapseReport.appex": extension_summary("ElapseReport.appex", "Extensions"),
    "ElapseReport.appex in PlugIns": (app / "PlugIns" / "ElapseReport.appex").exists(),
}
print("S00_ARCHIVE_EXTENSIONS=" + json.dumps(extensions, sort_keys=True))

failures: list[str] = []
if require_metadata:
    if summary["UIDeviceFamily"] != [1]:
        failures.append("UIDeviceFamily")
    if summary["CFBundleIconName"] != "AppIcon":
        failures.append("CFBundleIconName")
    if summary["CFBundleIcons"].get("primary_name") != "AppIcon":
        failures.append("CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconName")
    if summary["UISupportedInterfaceOrientations"] != [
        "UIInterfaceOrientationPortrait",
        "UIInterfaceOrientationLandscapeLeft",
        "UIInterfaceOrientationLandscapeRight",
    ]:
        failures.append("UISupportedInterfaceOrientations")
    if not summary["Assets.car"]:
        failures.append("Assets.car")
    monitor = extensions["ElapseMonitor.appex"]
    report = extensions["ElapseReport.appex"]
    if not (
        monitor.get("NSExtension") is True
        and monitor.get("NSExtensionPointIdentifier") == "com.apple.deviceactivity.monitor-extension"
        and monitor.get("NSExtensionPrincipalClass") == "ElapseMonitor.ElapseMonitorExtension"
    ):
        failures.append("MONITOR_EXTENSION_METADATA")
    if not (
        report.get("EXAppExtensionAttributes") is True
        and report.get("EXExtensionPointIdentifier") == "com.apple.deviceactivityui.report-extension"
        and report.get("NSExtension") is False
        and report.get("NSExtensionPrincipalClass") == "ABSENT"
        and extensions["ElapseReport.appex in PlugIns"] is False
    ):
        failures.append("REPORT_EXTENSIONKIT_METADATA")

assets = app / "Assets.car"
if not assets.is_file():
    print("S00_ASSETUTIL=NO_ASSETS_CAR")
    if require_metadata:
        print("S00_ARCHIVE_ASSERTION_FAILED=" + ",".join(failures))
        sys.exit(1)
    sys.exit(0)

assetutil = shutil.which("xcrun")
if assetutil is None:
    print("S00_ASSETUTIL=UNAVAILABLE")
    if require_metadata:
        print("S00_ARCHIVE_ASSERTION_FAILED=ASSETUTIL_UNAVAILABLE")
        sys.exit(1)
    sys.exit(0)

result = subprocess.run(
    [assetutil, "--sdk", "iphoneos", "assetutil", "--info", str(assets)],
    capture_output=True,
    text=True,
    check=False,
)
if result.returncode:
    print("S00_ASSETUTIL=QUERY_FAILED")
    if require_metadata:
        print("S00_ARCHIVE_ASSERTION_FAILED=ASSETUTIL_QUERY_FAILED")
        sys.exit(1)
    sys.exit(0)

try:
    entries = json.loads(result.stdout)
except json.JSONDecodeError:
    print("S00_ASSETUTIL=UNPARSEABLE")
    if require_metadata:
        print("S00_ARCHIVE_ASSERTION_FAILED=ASSETUTIL_UNPARSEABLE")
        sys.exit(1)
    sys.exit(0)

if not isinstance(entries, list):
    print("S00_ASSETUTIL=UNEXPECTED_FORMAT")
    if require_metadata:
        print("S00_ARCHIVE_ASSERTION_FAILED=ASSETUTIL_UNEXPECTED_FORMAT")
        sys.exit(1)
    sys.exit(0)

matches = [
    entry
    for entry in entries
    if isinstance(entry, dict)
    and any(
        "AppIcon" in str(entry.get(key, ""))
        for key in ("Name", "RenditionName", "AssetName", "IconName")
    )
]
print("S00_ASSETUTIL=OK")
print(f"S00_ASSETUTIL_ENTRY_COUNT={len(entries)}")
print(f"S00_ASSETUTIL_APPICON_MATCH_COUNT={len(matches)}")
pixel_sizes = sorted(
    {
        (entry["PixelWidth"], entry["PixelHeight"])
        for entry in matches
        if isinstance(entry.get("PixelWidth"), int)
        and isinstance(entry.get("PixelHeight"), int)
        and 0 < entry["PixelWidth"] <= 4096
        and 0 < entry["PixelHeight"] <= 4096
    }
)
print("S00_ASSETUTIL_APPICON_PIXEL_SIZES=" + json.dumps(pixel_sizes))
if require_metadata:
    if not matches:
        failures.append("ASSETUTIL_APPICON_RENDITION")
    if failures:
        print("S00_ARCHIVE_ASSERTION_FAILED=" + ",".join(failures))
        sys.exit(1)
    print("S00_ARCHIVE_DISTRIBUTION_METADATA_PASS")
