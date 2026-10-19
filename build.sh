#!/usr/bin/env bash
# Build the portfolio into ./build, self-contained and ready to upload.
#
#   ./build.sh
#
# JORN is not on the Elm package registry yet, so it comes in as a git
# submodule at jorn/, pinned to one commit. After cloning this repo:
#
#   git submodule update --init

set -euo pipefail

cd "$(dirname "$0")"

JORN="jorn"
OUT="build"

if [ ! -d "$JORN/client" ]; then
  echo "no JORN checkout at $JORN"
  echo "run: git submodule update --init"
  exit 1
fi

mkdir -p "$OUT/build" "$OUT/vendor"

# 1. the Elm program: every element on the page
elm make src/Main.elm --optimize --output="$OUT/build/main.js"

# 2. the browser patcher that applies Jorn's diffs, from the same pinned
#    commit as the Elm side
cp "$JORN/client/jorn.js" "$OUT/vendor/jorn.js"

# 3. the page shell and its stylesheet
cp public/index.html public/portfolio.css public/favicon.svg public/favicon.ico \
   public/favicon-48.png public/favicon-192.png public/og.png public/apple-touch-icon.png "$OUT/"
# Older iOS asks for the -precomposed name first; same image.
cp public/apple-touch-icon.png "$OUT/apple-touch-icon-precomposed.png"

# 4. the one self-hosted font and its license
mkdir -p "$OUT/fonts"
cp public/fonts/bigshoulders.woff2 public/fonts/BigShoulders-OFL.txt "$OUT/fonts/"

# 5. crawler files
cp public/robots.txt public/sitemap.xml public/llms.txt "$OUT/"

# 5b. the essay's PDF, next to the page that carries the same words
mkdir -p "$OUT/writing"
cp public/writing/the-distracted-forward-deployed-officer.pdf "$OUT/writing/"

# 6. prerender the Elm view into index.html so crawlers that do not run
#    JavaScript still get the whole page. Jorn mounts over it in the browser.
node prerender.mjs

# 7. cache-bust: stamp each asset URL in index.html with a hash of its
#    contents. GitHub Pages caches files for 10 minutes, so without this a
#    returning visitor can get new HTML with an old main.js, and Jorn mounts
#    the old page right over the new prerendered one.
python3 - "$OUT" <<'PY2'
import hashlib, pathlib, sys
out = pathlib.Path(sys.argv[1])
for page in [
    out / "index.html",
    out / "writing/distracted-forward-deployed-officer/index.html",
    out / "writing/escapes-multiply/index.html",
]:
    html = page.read_text(encoding="utf-8")
    for ref, path in [
        ('href="/portfolio.css"', "portfolio.css"),
        ('src="/build/main.js"', "build/main.js"),
        ('from "/vendor/jorn.js"', "vendor/jorn.js"),
    ]:
        if ref not in html:
            sys.exit(f"cache-bust: {ref} not found in {page}")
        v = hashlib.sha256((out / path).read_bytes()).hexdigest()[:10]
        html = html.replace(ref, ref[:-1] + "?v=" + v + '"')
    page.write_text(html, encoding="utf-8")
    print(f"cache-busted asset URLs in {page}")
PY2

echo
echo "built $OUT/"
echo "preview:  python3 -m http.server -d $OUT 8080"
echo "deploy:   upload the contents of $OUT/ anywhere that serves static files"