#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKDIR="${WORKDIR:-$ROOT_DIR/.probe-jdk25u}"
PATCH_FILE="${PATCH_FILE:-$ROOT_DIR/patches/jre_25/ios/jdk25u_ios.diff}"

if [[ ! -f "$PATCH_FILE" ]]; then
  echo "Missing patch file: $PATCH_FILE"
  echo "Create patches/jre_25/ios/jdk25u_ios.diff first."
  exit 2
fi

rm -rf "$WORKDIR"
git clone --depth 1 --filter=blob:none --sparse https://github.com/openjdk/jdk25u.git "$WORKDIR"

python3 - "$PATCH_FILE" "$WORKDIR/.sparse-paths.txt" <<'PY'
from pathlib import Path
import sys

src = Path(sys.argv[1]).read_text(errors="replace").splitlines()
out = Path(sys.argv[2])
paths = []
for line in src:
    if line.startswith("diff --git a/"):
        paths.append(line.split(" b/")[0][13:])
out.write_text("\n".join(paths) + "\n")
PY

git -C "$WORKDIR" sparse-checkout set --stdin < "$WORKDIR/.sparse-paths.txt"

if git -C "$WORKDIR" apply --check "$PATCH_FILE"; then
  echo "Patch applies cleanly to jdk25u."
else
  echo "Patch does not apply cleanly to jdk25u."
  exit 1
fi
