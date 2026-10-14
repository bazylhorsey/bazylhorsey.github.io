#!/usr/bin/env bash
# Publish build/ to GitHub Pages (https://bazylhorsey.github.io/).
#
#   ./build.sh && ./deploy.sh
#
# Expects a clone of github.com/bazylhorsey/bazylhorsey.github.io next to this
# folder, or SITE=/path/to/clone. The site repo gets the contents of build/ at
# its root (that is what Pages serves) and this source under source/.

set -euo pipefail
cd "$(dirname "$0")"

SITE="${SITE:-../bazylhorsey.github.io}"
if [ ! -d "$SITE/.git" ]; then
  echo "no clone at $SITE"
  echo "git clone https://github.com/bazylhorsey/bazylhorsey.github.io $SITE"
  exit 1
fi

# Replace everything except .git, then lay the build and the source back down.
find "$SITE" -mindepth 1 -maxdepth 1 ! -name .git -exec rm -rf {} +
cp -R build/. "$SITE/"
rm -f "$SITE/portfolio.html"           # the bundle.sh single-file copy, not for Pages
touch "$SITE/.nojekyll"                # serve files as-is, no Jekyll pass
mkdir -p "$SITE/source/public/fonts" "$SITE/source/src"
cp public/fonts/bigshoulders.woff2 public/fonts/BigShoulders-OFL.txt "$SITE/source/public/fonts/"
cp src/Main.elm "$SITE/source/src/"
cp public/index.html public/portfolio.css public/favicon.svg public/og.png \
   public/apple-touch-icon.png public/robots.txt public/sitemap.xml \
   "$SITE/source/public/"
cp README.md elm.json build.sh bundle.sh deploy.sh prerender.mjs run.mjs \
   audit.html serve.command .gitignore "$SITE/source/"

cat > "$SITE/README.md" <<'MD'
# bazylhorsey.github.io

https://bazylhorsey.github.io/

My portfolio. Written in Elm and rendered by
[Jorn](https://github.com/bazylhorsey/jorn), running in production.

The page is prerendered from the same Elm view at build time so crawlers get
real HTML, then Jorn mounts in the browser and owns every update after that:
the theme toggle and the work filters are Jorn diffs and patches.

The root of this repo is the built site, which is what GitHub Pages serves.
The source is in [`source/`](source/), and `source/README.md` covers building
and deploying.
MD

cd "$SITE"
git add -A
if git diff --cached --quiet; then
  echo "nothing changed"
  exit 0
fi
git commit -m "Deploy $(date +%Y-%m-%d)"
git push
echo "pushed. live in a minute or two at https://bazylhorsey.github.io/"
