#!/bin/bash
# Rebuild the portfolio and serve build/ on http://127.0.0.1:8080
# Double-click in Finder, or run ./serve.command. Ctrl+C stops the server.
cd "$(dirname "$0")" || exit 1

if command -v elm >/dev/null 2>&1; then
  node jorn/cli/jorn.mjs build || { echo "build failed, serving the last good build/"; }
else
  echo "elm is not on PATH here, serving the existing build/ without rebuilding"
fi

# Free port 8080 if an older preview server is holding it.
old=$(lsof -ti tcp:8080 -sTCP:LISTEN 2>/dev/null)
if [ -n "$old" ]; then
  echo "stopping the server already on 8080 (pid $old)"
  kill $old 2>/dev/null
  sleep 1
fi

echo
echo "live at http://127.0.0.1:8080"
python3 -m http.server -d build 8080
