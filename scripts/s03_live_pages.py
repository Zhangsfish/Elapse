"""Anonymous HTTPS check of deployed Everwhile Support/Privacy; never logs bodies."""
import argparse
import datetime
import hashlib
import json
from pathlib import Path
import urllib.parse
import urllib.request

from s03_preflight import PageParser

BASE = "https://zhangsfish.github.io/Elapse/"


def verify(source=Path(__file__).resolve().parents[1] / "public-pages"):
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    records = []
    for name in ("index.html", "privacy.html", "style.css"):
        url = BASE if name == "index.html" else BASE + name
        # No cookie jar, Authorization header, user session or login.
        with opener.open(urllib.request.Request(url, headers={"User-Agent": "Everwhile-anonymous-preflight"}),
                         timeout=30) as response:
            raw = response.read()
            assert response.status == 200
            assert response.url.startswith(BASE) and response.url.startswith("https://")
        expected = (source / name).read_bytes()
        assert raw == expected, "Deployed source mismatch: " + name
        text = raw.decode("utf-8")
        record = {"url": url, "http_status": 200, "anonymous": True,
                  "sha256": hashlib.sha256(raw).hexdigest(), "exact_source_match": True}
        if name.endswith("html"):
            page = PageParser()
            page.feed(text)
            assert page.languages == {"en", "zh-Hans"} and "Everwhile" in text
            assert "mailto:zhangs.taq@gmail.com" in page.links
            assert {"index.html", "privacy.html"} <= set(page.links)
            assert not set(page.tags) & {"script", "iframe", "form", "input", "img"}
            record.update(languages=sorted(page.languages), cross_links=True, mailto=True,
                          remote_js=False, analytics=False, login_required=False)
        records.append(record)
    return {"status": "LIVE_VERIFIED", "observed_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
            "pages": records, "basis": "ANONYMOUS_HTTP_AND_EXACT_STATIC_SOURCE_NOT_OS_MAIL_CLIENT_TEST"}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    result = verify()
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    print(json.dumps(result, indent=2))
