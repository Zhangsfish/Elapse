"""Secret-free static preflight. Does not approve legal answers or Apple gates."""
import argparse
import hashlib
from html.parser import HTMLParser
import json
from pathlib import Path
import plistlib
import re
import subprocess
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "store-assets/scripts"))
import bilingual_asset_checks

ROOT = Path(__file__).resolve().parents[1]
PROTECTED = ["App", "Shared", "MonitorExtension", "ReportExtension", "Localization",
             "AppResources", "project.yml"]


def metadata_counts(text):
    counts = {}
    for locale, section, labels in (
        ("en", "English", ("Name: ", "Subtitle: ", "Promotional text: ", "Description:", "Keywords: ")),
        ("zh-Hans", "简体中文", ("名称：", "副标题：", "推广文本：", "描述：", "关键词：")),
    ):
        body = text.split("## " + section + "\n", 1)[1].split("\n## ", 1)[0]
        values = [body.split(label, 1)[1].split("\n", 1)[0].strip() for label in labels[:3]]
        description = body.split(labels[3], 1)[1].split(labels[4], 1)[0].strip()
        keywords = body.split(labels[4], 1)[1].split("\n", 1)[0].strip()
        sizes = dict(zip(("name", "subtitle", "promotional_text"), map(len, values)))
        sizes.update(description=len(description), keywords_utf8_bytes=len(keywords.encode("utf-8")))
        for key, limit in (("name", 30), ("subtitle", 30), ("promotional_text", 170),
                           ("description", 4000), ("keywords_utf8_bytes", 100)):
            assert 0 < sizes[key] <= limit, (locale, key, sizes[key], limit)
        counts[locale] = sizes
    return counts


class PageParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.tags = []
        self.languages = set()
        self.links = []
        self.ids = set()
        self.references = []
        self.headings = []
        self.viewport = False

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        self.tags.append(tag)
        assert not any(key.startswith("on") for key in attrs), "Inline handler"
        if "lang" in attrs:
            self.languages.add(attrs["lang"])
        if "id" in attrs:
            assert attrs["id"] not in self.ids, "Duplicate HTML id"
            self.ids.add(attrs["id"])
        self.references.extend(attrs.get("aria-labelledby", "").split())
        if tag == "a":
            self.links.append(attrs["href"])
        if tag == "link":
            assert attrs.get("href") == "style.css", "Remote stylesheet/resource"
        if tag in ("h1", "h2"):
            self.headings.append(tag)
        if tag == "meta" and attrs.get("name") == "viewport":
            self.viewport = "width=device-width" in attrs.get("content", "")


def check_pages(root):
    for name in ("index.html", "privacy.html"):
        page = PageParser()
        page.feed((root / name).read_text(encoding="utf-8"))
        assert page.languages == {"en", "zh-Hans"}
        assert not set(page.tags) & {"script", "iframe", "form", "input", "img"}
        assert page.viewport and page.headings.count("h1") == 1
        assert set(page.references) <= page.ids
        assert "mailto:zhangs.taq@gmail.com" in page.links
        for link in page.links:
            assert link in {"index.html", "privacy.html", "mailto:zhangs.taq@gmail.com",
                            "https://zhang-shuo-portfolio.vercel.app/"}, link
    css = (root / "style.css").read_text(encoding="utf-8")
    assert not re.search(r"url\s*\(|@import", css, re.I)
    assert "prefers-color-scheme: dark" in css and ":focus-visible" in css
    return "PASS_STATIC_SOURCE_NOT_ANONYMOUS_HTTPS"


def check_privacy(root):
    with (root / "AppResources/PrivacyInfo.xcprivacy").open("rb") as file:
        manifest = plistlib.load(file)
    assert manifest["NSPrivacyTracking"] is False
    assert manifest["NSPrivacyTrackingDomains"] == []
    assert manifest["NSPrivacyCollectedDataTypes"] == []
    assert manifest["NSPrivacyAccessedAPITypes"] == [{
        "NSPrivacyAccessedAPIType": "NSPrivacyAccessedAPICategoryUserDefaults",
        "NSPrivacyAccessedAPITypeReasons": ["CA92.1"]}]
    inventories = {"imports": set(), "network_api_matches": [], "user_defaults_files": []}
    forbidden = re.compile(r"\b(URLSession|URLRequest|NWConnection|WKWebView|Firebase|Mixpanel|Sentry|AdMob)\b")
    for folder in ("App", "Shared", "MonitorExtension", "ReportExtension"):
        for file in sorted((root / folder).glob("*.swift")):
            source = file.read_text(encoding="utf-8")
            inventories["imports"].update(re.findall(r"^import (\w+)", source, re.M))
            if "UserDefaults" in source:
                inventories["user_defaults_files"].append(file.relative_to(root).as_posix())
            for match in forbidden.finditer(source):
                inventories["network_api_matches"].append({"file": file.relative_to(root).as_posix(),
                                                          "symbol": match.group(0)})
    assert not inventories["network_api_matches"], inventories["network_api_matches"]
    assert inventories["user_defaults_files"] == ["App/ElapseModel.swift", "Shared/TutorialVisitStore.swift"]
    assert ".package(" not in (root / "Package.swift").read_text(encoding="utf-8")
    project = (root / "project.yml").read_text(encoding="utf-8")
    for identifier in ("com.zhangsfish.elapse", "com.zhangsfish.elapse.monitor", "com.zhangsfish.elapse.report"):
        assert "PRODUCT_BUNDLE_IDENTIFIER: " + identifier + "\n" in project
    expected = {
        "App/Elapse.entitlements": ["group.com.zhangsfish.elapse"],
        "MonitorExtension/ElapseMonitor.entitlements": ["group.com.zhangsfish.elapse"],
        "ReportExtension/ElapseReport.entitlements": None,
    }
    for path, groups in expected.items():
        with (root / path).open("rb") as file:
            entitlements = plistlib.load(file)
        assert entitlements["com.apple.developer.family-controls"] is True
        assert entitlements.get("com.apple.security.application-groups") == groups
    inventories["imports"] = sorted(inventories["imports"])
    inventories["bundle_ids_family_controls_report_boundary"] = "PASS_SOURCE_UNCHANGED"
    inventories["basis"] = "STATIC_SOURCE_ONLY_NOT_PACKET_CAPTURE_OR_LEGAL_APPROVAL"
    return inventories


def run(root=ROOT):
    provenance = json.loads((root / "store-assets/captures/en/PROVENANCE.json").read_text())
    assert set(provenance["production_trees"]) == set(PROTECTED)
    for path, expected in provenance["production_trees"].items():
        actual = subprocess.check_output(["git", "rev-parse", "HEAD:" + path], cwd=root, text=True).strip()
        assert actual == expected, "Frozen production tree changed: " + path
    captures = json.loads((root / "store-assets/captures/en/CAPTURES.json").read_text())
    rendered = json.loads((root / "store-assets/RENDER_MANIFEST_EN.json").read_text())
    assert len(captures) == len(rendered["frames"]) == 4
    for raw, frame in zip(captures, rendered["frames"]):
        for path, expected in (("captures/en/" + raw["file"], raw["sha256"]),
                               (frame["file"], frame["sha256"])):
            assert hashlib.sha256((root / "store-assets" / path).read_bytes()).hexdigest() == expected
        assert frame["source_sha"] == provenance["source_sha"]
        assert frame["in_phone_overlay"] is None
    bilingual = bilingual_asset_checks.check(root / "store-assets", require_chinese=(root / "store-assets/RENDER_MANIFEST_ZH_HANS.json").exists())
    return {"status": "PASS", "production_freeze": "PASS", "bilingual_assets": bilingual,
            "capture_source_sha": provenance["source_sha"],
            "metadata_counts": metadata_counts((root / "docs/APP_STORE_METADATA.md").read_text(encoding="utf-8")),
            "public_pages": check_pages(root / "public-pages"), "privacy_inventory": check_privacy(root),
            "portal_assigned": "NOT_REQUIRED_FOR_RELEASE_OPTIONAL_OWNER_READBACK",
            "app_privacy_answers": "DATA_NOT_COLLECTED_RECOMMENDED_OWNER_ASC_ATTESTATION",
            "app_review_submission": "NOT_RUN_NOT_AUTHORIZED"}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = run()
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))
