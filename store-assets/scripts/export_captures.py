"""Export only four named non-private Release screenshots, fail on missing evidence."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess

BASE = "e63cbe8c6327ff5e1e0bed1a209800c7ef661a4a"
RUNTIME = "fab87acc8f4b863451d9c91ee7605b4c33c47789"
NAMES = ["01-awareness", "02-choose-interval", "03-reminder", "04-today"]
PROTECTED = ["App", "Shared", "MonitorExtension", "ReportExtension", "Localization",
             "AppResources", "project.yml"]


def git(*args):
    return subprocess.check_output(["git", *args], text=True).strip()


def record_source(dest):
    assert not git("diff", BASE, "HEAD", "--", *PROTECTED), "Production freeze violated"
    assert not git("diff", RUNTIME, "HEAD", "--", *PROTECTED), "91.1 runtime changed"
    trees = {path: git("rev-parse", f"HEAD:{path}") for path in PROTECTED}
    data = {"source_sha": git("rev-parse", "HEAD"), "base_main": BASE,
            "frozen_runtime_sha": RUNTIME, "production_trees": trees,
            "production_diff": [], "configuration": "Release", "locale": "en / en_US",
            "device": "Fresh iPhone 17 Pro Max simulator", "status_bar": "9:41 / Wi-Fi / full battery",
            "version_build": "0.1.0 (91.1)", "not_uploaded_build": True,
            "run_url": f'https://github.com/{os.environ["GITHUB_REPOSITORY"]}/actions/runs/{os.environ["GITHUB_RUN_ID"]}',
            "private_state": False, "screen_time_authorization_injected": False,
            "sources": {NAMES[0]: "Genuine unauthorized home; no selected apps",
                        NAMES[1]: "Shipped Quick Start Choose Apps illustration",
                        NAMES[2]: "Shipped Quick Start Reminder illustration, not an OS notification",
                        NAMES[3]: "Shipped Quick Start Today illustration, not live usage"}}
    dest.mkdir(parents=True, exist_ok=True)
    (dest / "PROVENANCE.json").write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def export(source, dest):
    summary = json.loads((dest / "test-summary.json").read_text())
    assert summary["failedTests"] == 0 and summary["passedTests"] == 1
    assert summary["skippedTests"] == 0 and summary["totalTestCount"] == 1
    found = {}

    def walk(node):
        if isinstance(node, list):
            for value in node:
                walk(value)
        elif isinstance(node, dict):
            label = node.get("suggestedHumanReadableName", node.get("name", ""))
            for name in NAMES:
                prefix = "store-en-" + name
                if label.startswith(prefix):
                    filename = node.get("exportedFileName", node.get("fileName", node.get("filename")))
                    if filename:
                        path = (source / filename).resolve()
                        assert path.is_relative_to(source.resolve()), "Unsafe attachment path"
                        assert name not in found, "Ambiguous capture"
                        found[name] = path
            for value in node.values():
                walk(value)

    walk(json.loads((source / "manifest.json").read_text()))
    assert set(found) == set(NAMES), "Incomplete named capture set"
    records = []
    for name in NAMES:
        raw = found[name].read_bytes()
        assert raw[:8] == b"\x89PNG\r\n\x1a\n"
        assert struct.unpack(">II", raw[16:24]) == (1320, 2868)
        shutil.copyfile(found[name], dest / (name + ".png"))
        records.append({"file": name + ".png", "pixels": [1320, 2868],
                        "sha256": hashlib.sha256(raw).hexdigest()})
    (dest / "CAPTURES.json").write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
    print("PASS: four fresh non-private real Release captures exported")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("source", nargs="?", type=Path)
    parser.add_argument("dest", nargs="?", type=Path)
    parser.add_argument("--record-source", type=Path)
    args = parser.parse_args()
    if args.record_source:
        record_source(args.record_source)
    else:
        assert args.source and args.dest
        export(args.source, args.dest)
