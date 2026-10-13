#!/usr/bin/env bash
# Build the portfolio into ./build, self-contained and ready to upload.
#
#   ./build.sh
#
# JORN is not on the Elm package registry yet, so it is consumed from a local
# clone. Point JORN somewhere else if the clone is not a sibling:
#
#   JORN=~/src/jorn ./build.sh

set -euo pipefail

cd "$(dirname "$0")"

JORN="${JORN:-../jorn}"
OUT="build"

if [ ! -d "$JORN/client" ]; then
  echo "no JORN checkout at $JORN"
  echo "clone https://github.com/bazylhorsey/jorn next to this folder, or set JORN=/path/to/jorn"
  exit 1
fi

mkdir -p "$OUT/build" "$OUT/vendor"

# 1. the Elm program: every element on the page
elm make src/Main.elm --optimize --output="$OUT/build/main.js"

# 2. the browser patcher that applies Jorn's diffs, copied so the
#    deployed folder does not depend on the clone
cp "$JORN/client/jorn.js" "$OUT/vendor/jorn.js"

# 3. the page shell and its stylesheet
cp public/index.html public/portfolio.css public/favicon.svg public/og.png public/apple-touch-icon.png "$OUT/"
# Older iOS asks for the -precomposed name first; same image.
cp public/apple-touch-icon.png "$OUT/apple-touch-icon-precomposed.png"

# 4. the layout audit, so a deployed copy can still be checked
cp audit.html "$OUT/audit.html"

# 5. crawler files
cp public/robots.txt public/sitemap.xml "$OUT/"

# 6. prerender the Elm view into index.html so crawlers that do not run
#    JavaScript still get the whole page. Jorn mounts over it in the browser.
node prerender.mjs

echo
echo "built $OUT/"
echo "preview:  python3 -m http.server -d $OUT 8080"
echo "audit:    http://127.0.0.1:8080/audit.html"
echo "deploy:   upload the contents of $OUT/ anywhere that serves static files"