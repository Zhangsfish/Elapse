"""Reuse strict English exporter guards, without changing the frozen exporter."""
import argparse
import json
import hashlib
import shutil
import struct
from pathlib import Path
import export_captures as english
from english_freeze import check


def record_source(dest):
    check()
    english.record_source(dest)
    path = dest / "PROVENANCE.json"
    data = json.loads(path.read_text(encoding="utf-8"))
    data["locale"] = "zh-Hans / zh_CN"
    data["attachment_prefix"] = "store-zh-hans-"
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def export(source, dest):
    summary = json.loads((dest / "test-summary.json").read_text())
    assert summary["failedTests"] == summary["skippedTests"] == 0
    assert summary["passedTests"] == summary["totalTestCount"] == 1
    found = {}

    def walk(node):
        if isinstance(node, list):
            for value in node:
                walk(value)
        elif isinstance(node, dict):
            label = node.get("suggestedHumanReadableName", node.get("name", ""))
            for name in english.NAMES:
                if label.startswith("store-zh-hans-" + name):
                    filename = node.get("exportedFileName", node.get("fileName", node.get("filename")))
                    if filename:
                        path = (source / filename).resolve()
                        assert path.is_relative_to(source.resolve()), "Unsafe attachment path"
                        assert name not in found, "Ambiguous capture"
                        found[name] = path
            for value in node.values():
                walk(value)

    walk(json.loads((source / "manifest.json").read_text()))
    assert set(found) == set(english.NAMES), "Incomplete named Chinese capture set"
    records = []
    for name in english.NAMES:
        raw = found[name].read_bytes()
        assert raw[:8] == b"\x89PNG\r\n\x1a\n"
        assert struct.unpack(">II", raw[16:24]) == (1320, 2868)
        shutil.copyfile(found[name], dest / (name + ".png"))
        records.append({"file": name + ".png", "pixels": [1320, 2868],
                        "sha256": hashlib.sha256(raw).hexdigest()})
    (dest / "CAPTURES.json").write_text(json.dumps(records, indent=2) + "\n", encoding="utf-8")
    print("PASS: four fresh non-private Chinese Release captures exported")


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
