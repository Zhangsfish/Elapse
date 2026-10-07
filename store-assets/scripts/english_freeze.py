"""Standard-library freeze guard. Never writes or regenerates English assets."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def check(root=ROOT):
    freeze = json.loads((root / "ENGLISH_FREEZE.json").read_text(encoding="utf-8"))
    for name, expected in freeze["sha256"].items():
        raw = (root / name).read_bytes()
        actual = hashlib.sha256(raw).hexdigest()
        # Existing Windows JSON CRLF checkout vs GitHub LF checkout only.
        # PNG/contact bytes never receive any normalization.
        assert actual == expected or (name in freeze["git_lf_json_sha256"] and
            actual == freeze["git_lf_json_sha256"][name]), "English freeze changed: " + name
    renderer = (root / "scripts/render_store.py").read_bytes().replace(b"\r\n", b"\n")
    assert hashlib.sha256(renderer).hexdigest() == freeze["english_renderer_normalized_lf_sha256"], "English renderer changed"
    return {"status": "PASS", "approved_reference_head": freeze["approved_reference_head"],
            "frozen_files": freeze["sha256"], "renderer": "UNCHANGED_NORMALIZED_LF"}


if __name__ == "__main__":
    print(json.dumps(check(), indent=2))
