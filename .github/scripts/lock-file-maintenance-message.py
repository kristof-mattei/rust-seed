#!/usr/bin/env python3

import os
import subprocess
import sys
import tomllib


def crate_versions(revision: str) -> set[str]:
    lock_file = subprocess.run(
        ["git", "show", f"{revision}:Cargo.lock"],
        check=True,
        stdout=subprocess.PIPE,
        text=True,
    ).stdout

    return {f"{package['name']} {package['version']}" for package in tomllib.loads(lock_file)["package"]}


subject = sys.stdin.read()
commit_sha = os.environ["COMMIT_SHA"]

try:
    updated = sorted(crate_versions(commit_sha) - crate_versions(f"{commit_sha}^"))
except Exception as error:
    print(f"{commit_sha}: {error}", file=sys.stderr)
    updated = []

if updated:
    print(f"{subject} ({', '.join(updated)})", end="")
else:
    print(subject, end="")
