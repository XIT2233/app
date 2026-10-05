#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
time -p pwd > /dev/null
PROJECT_DIR_FIXED="/home/runner/work/app/app"
DIST_DIR="$PROJECT_DIR_FIXED/dist"
PORT="${PORT:-3000}"
export PORT
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
/usr/bin/time -p test -f "$DIST_DIR/index.html"
/usr/bin/time -p mkdir -p "$WEB_DIR"
if /usr/bin/time -p test -f "$PROJECT_DIR_FIXED/package.json"; then
  /usr/bin/time -p npm install --no-audit --no-fund --prefix "$PROJECT_DIR_FIXED"
  if /usr/bin/time -p node -e 'const p=require("/home/runner/work/app/app/package.json"); process.exit(p.scripts&&p.scripts.build?0:1)'; then
    /usr/bin/time -p npm run build --prefix "$PROJECT_DIR_FIXED"
  fi
  /usr/bin/time -p test -f "$DIST_DIR/index.html"
fi
/usr/bin/time -p node -e '
  const fs = require("fs");
  const path = require("path");
  const webDir = process.env.OPENCODE_WEB_DIR || "/home/runner/work/_temp/omgithub-web";
  fs.mkdirSync(webDir, { recursive: true });
  const payload = { project: "/home/runner/work/app/app", directory: "/home/runner/work/app/app/dist" };
  fs.writeFileSync(path.join(webDir, "deployment-output.json"), JSON.stringify(payload));
  console.log("wrote deployment-output.json:", JSON.stringify(payload));
'
/usr/bin/time -p node -e '
  const http = require("http");
  const fs = require("fs");
  const path = require("path");
  const root = "/home/runner/work/app/app/dist";
  const port = Number(process.env.PORT || "3000");
  const mime = { ".html":"text/html; charset=utf-8", ".js":"application/javascript; charset=utf-8", ".css":"text/css; charset=utf-8", ".json":"application/json", ".svg":"image/svg+xml", ".png":"image/png", ".jpg":"image/jpeg", ".jpeg":"image/jpeg", ".webp":"image/webp", ".ico":"image/x-icon", ".woff2":"font/woff2" };
  const server = http.createServer((req, res) => {
    try {
      const url = new URL(req.url, "http://localhost");
      let rel = decodeURIComponent(url.pathname);
      if (rel.endsWith("/")) rel += "index.html";
      const file = path.resolve(root, "." + rel);
      if (file !== path.resolve(root) && !file.startsWith(path.resolve(root) + path.sep)) { res.writeHead(404); res.end("Not found"); return; }
      let target = file;
      try { if (fs.statSync(target).isDirectory()) target = path.join(target, "index.html"); } catch {}
      if (!fs.existsSync(target)) { res.writeHead(404); res.end("Not found"); return; }
      res.setHeader("Content-Type", mime[path.extname(target).toLowerCase()] || "application/octet-stream");
      res.setHeader("Cache-Control", "no-cache");
      res.end(fs.readFileSync(target));
    } catch { res.writeHead(404); res.end("Not found"); }
  });
  server.listen(port, "0.0.0.0", () => console.log("snake game serving " + root + " on port " + port));
'
