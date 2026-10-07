"""Owner-authorized Pages/status operations; credentials remain only in memory.

No Apple credentials. Never dump raw GitHub responses or credential errors.
Only the fixed Elapse repository and allowlisted operations are reachable.
"""
import argparse
import json
import os
import subprocess
import urllib.error
import urllib.request

BASE = "https://api.github.com/repos/Zhangsfish/Elapse"


def credential():
    result = subprocess.run(
        ["git", "-c", "credential.interactive=never", "credential", "fill"],
        input="protocol=https\nhost=github.com\n\n", text=True,
        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, timeout=20,
        env={**os.environ, "GIT_TERMINAL_PROMPT": "0", "GCM_INTERACTIVE": "never"},
    )
    if result.returncode:
        raise RuntimeError("CREDENTIAL_UNAVAILABLE")
    fields = dict(line.split("=", 1) for line in result.stdout.splitlines() if "=" in line)
    if not fields.get("password"):
        raise RuntimeError("CREDENTIAL_UNAVAILABLE")
    return fields["password"]


def request(path, token, method="GET", body=None):
    headers = {"User-Agent": "Everwhile-S03-closeout", "Accept": "application/vnd.github+json",
               "X-GitHub-Api-Version": "2022-11-28", "Authorization": "Bearer " + token}
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(BASE + path, data=data, headers=headers, method=method)
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    try:
        with opener.open(req, timeout=25) as response:
            raw = response.read()
            return response.status, json.loads(raw) if raw else {}
    except urllib.error.HTTPError as error:
        return error.code, {}  # Never echo a response containing credentials/account fields.


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("operation", choices=["status", "enable-pages", "dispatch-pages", "dispatch-readback"])
    parser.add_argument("--ref", default="main")
    args = parser.parse_args()
    if args.ref not in ("main", "codex/s03-b-portal-closeout"):
        raise RuntimeError("REF_NOT_ALLOWED")
    token = credential()
    if args.operation == "enable-pages":
        code, _ = request("/pages", token)
        if code == 404:
            code, _ = request("/pages", token, "POST", {"build_type": "workflow"})
        print(json.dumps({"operation": args.operation, "http_status": code}))
    elif args.operation.startswith("dispatch-"):
        workflow = "s03-public-pages.yml" if args.operation == "dispatch-pages" else "s03-review-rc.yml"
        code, _ = request("/actions/workflows/" + workflow + "/dispatches", token,
                          "POST", {"ref": args.ref})
        print(json.dumps({"operation": args.operation, "ref": args.ref, "http_status": code}))
    else:
        code, pages = request("/pages", token)
        repo_code, repo = request("", token)
        runs_code, runs = request("/actions/workflows/s03-public-pages.yml/runs?per_page=3", token)
        print(json.dumps({"pages_http_status": code, "pages": {
            key: pages.get(key) for key in ("status", "build_type", "html_url", "https_enforced")},
            "repo_http_status": repo_code, "permissions": repo.get("permissions"),
            "runs_http_status": runs_code, "runs": [{key: r.get(key) for key in
                ("id", "head_sha", "status", "conclusion", "html_url")}
                for r in runs.get("workflow_runs", [])]}, indent=2))


if __name__ == "__main__":
    try:
        main()
    except Exception:
        print("S03_GITHUB_OPERATION_NOT_VERIFIED")
        raise SystemExit(1)
