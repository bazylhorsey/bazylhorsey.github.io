#!/usr/bin/env bash
# Fold build/ into one self-contained HTML file: build/portfolio.html
#
#   ./build.sh && ./bundle.sh
#
# For sending one file to someone. This is not the deploy path: the site is
# deployed from build/ as a normal folder, and that is what should stay the
# default. Use this when you want an artifact you can attach to an email or
# hand over on a stick, nothing more.
#
# What gets inlined:
#   portfolio.css      -> <style>
#   favicon.svg        -> data URI
#   build/main.js      -> <script>   (compiled Elm)
#   vendor/jorn.js     -> <script>   (the patcher, with "export" stripped)
#   the glue           -> <script>
#
# The patcher is an ES module with a single export and no imports, so dropping
# the keyword turns it into a classic script and the three tags can live in one
# file in the original order.

set -euo pipefail

cd "$(dirname "$0")"

SRC="build"
OUT="build/portfolio.html"

if [ ! -f "$SRC/build/main.js" ]; then
  echo "no $SRC/build/main.js, run ./build.sh first"
  exit 1
fi

python3 - "$SRC" "$OUT" <<'PY'
import pathlib, sys, re

src = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])


def read(name):
    return (src / name).read_text(encoding="utf-8")


def guard(text, tag):
    # A literal closing tag inside inlined source would end the tag early.
    return text.replace("</" + tag, "<\\/" + tag)


html = read("index.html")
css = guard(read("portfolio.css"), "style")
elm = guard(read("build/main.js"), "script")
jorn = guard(read("vendor/jorn.js"), "script")
icon = read("favicon.svg").strip()

# The patcher is an ES module. Inline as a classic script it has to stop being
# one, so drop the export keyword. It has no imports, so nothing else is needed.
jorn, exports = re.subn(r"^export\s+", "", jorn, flags=re.M)
if exports != 1:
    print(
        f"expected exactly 1 export in vendor/jorn.js, found {exports}",
        file=sys.stderr,
    )
    sys.exit(1)

# Drop the module import; the patcher is inlined as a classic script instead.
html = html.replace(
    '<link rel="icon" href="favicon.svg" type="image/svg+xml" />',
    '<link rel="icon" href="data:image/svg+xml,'
    + icon.replace("\n", "").replace("#", "%23").replace("<", "%3C").replace(">", "%3E").replace('"', "%22")
    + '" type="image/svg+xml" />',
)

html = html.replace(
    '<link rel="stylesheet" href="portfolio.css" />',
    "<style>\n" + css + "\n</style>",
)

html = html.replace(
    '<script src="build/main.js"></script>',
    "<script>\n" + elm + "\n</script>",
)

# "<script type=\"module\">" ... "</script>" -> the import line goes, the
# patcher gets its own classic tag in front of the glue.
def module_to_inline(match):
    body = match.group(1)
    body = re.sub(r"^\s*import\s+\{[^}]*\}\s+from\s+[^;]+;\s*$", "", body, flags=re.M)
    return "<script>\n" + jorn + "\n</script>\n    <script>\n" + body.strip() + "\n    </script>"


html, n = re.subn(
    r'<script type="module">(.*?)</script>', module_to_inline, html, flags=re.S
)

if n != 1:
    print(f"expected exactly one module script, found {n}", file=sys.stderr)
    sys.exit(1)

leftovers = re.findall(r'<(?:link[^>]+stylesheet|script[^>]+src=)', html)
if leftovers:
    print("still references external files: " + ", ".join(leftovers), file=sys.stderr)
    sys.exit(1)

out.write_text(html, encoding="utf-8")

kb = out.stat().st_size / 1024
print(f"wrote {out}  ({kb:.0f} KB, no external requests)")
PY