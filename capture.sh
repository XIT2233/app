#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
time -p pwd > /dev/null
RUNTIME_DIR="${RUNTIME_DIR:-/home/runner/work/_temp/omgithub-runtime}"
export RUNTIME_DIR
if [[ -z "${CAPTURE_URL:-}" ]]; then echo "CAPTURE_URL is required" >&2; exit 1; fi
if [[ -z "${CAPTURE_DIR:-}" ]]; then echo "CAPTURE_DIR is required" >&2; exit 1; fi
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p node -e 'const u=process.env.CAPTURE_URL||""; try{const x=new URL(u); if(!["http:","https:"].includes(x.protocol)) throw 0;}catch{console.error("CAPTURE_URL must be an http(s) URL"); process.exit(1);} console.log("capturing: "+u);'
/usr/bin/time -p node "$RUNTIME_DIR/scripts/default-capture.mjs"
/usr/bin/time -p test -f "$CAPTURE_DIR/final-desktop.png"
/usr/bin/time -p test -f "$CAPTURE_DIR/final-mobile.png"
/usr/bin/time -p ls -la "$CAPTURE_DIR"
