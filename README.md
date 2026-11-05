# bazylhorsey.github.io

https://bazylhorsey.github.io/

My portfolio. Written in Elm, rendered by [JORN](https://github.com/bazylhorsey/jorn).

There is no HTML in here. `src/Main.elm` returns a `Jorn.Element`, Jorn sends
that tree to the browser once to mount, and sends only the diff every time
state changes. `src/Site.elm` describes the static site with `Jorn.Static`:
every page is a whole document, `<head>` included, with the app's view already
inside it, and `jorn build` writes them all to `build/`.

## Layout

```
.
├── elm.json          points at the JORN submodule in jorn/src
├── jorn/             JORN, as a git submodule pinned to one commit
├── src/
│   ├── Main.elm      the app: model, update, view, content
│   ├── Site.elm      the static site: every page's head and HTML, the sitemap
│   ├── Essay.elm     /writing/distracted-forward-deployed-officer/
│   ├── CaseStudy.elm /writing/escapes-multiply/
│   └── PhantomZone.elm /writing/phantom-zone-for-ai/
├── public/           the stylesheet, font, icons and crawler files, copied as is
├── run.mjs           headless check: mounts, fires events, inspects patches
├── serve.command     rebuild and preview on http://127.0.0.1:8080
├── TESTIMONIALS.md   the original quotes the site cuts down from
├── build/            the deployable folder (generated, not committed)
└── .github/workflows/pages.yml   builds, checks and deploys on push to main
```

## Build

JORN is not on the Elm package registry yet, so it comes in as a git submodule
at `jorn/`. Clone with it, or fetch it after cloning:

```bash
git clone --recurse-submodules https://github.com/bazylhorsey/bazylhorsey.github.io
# or, in an existing clone
git submodule update --init
```

Then:

```bash
node jorn/cli/jorn.mjs build
```

That is `jorn build`, from the same JORN commit as the Elm side. It runs
`src/Site.elm` in Node and writes `build/`:

- each page, with the app's view already in its HTML, so crawlers and link
  previews that never run JavaScript get the whole page
- everything in `public/`
- the app, compiled with `elm make --optimize`, as `main.js`
- JORN's `client/jorn.js` as `jorn.js`, so the patcher and the Elm side always
  match
- `sitemap.xml`, made from the same list as the pages

Every URL a page loads a script or the stylesheet from gets a hash of that
file's contents. GitHub Pages caches files for ten minutes, so without it a
returning visitor could get new HTML with an old `main.js`. It checks every
path before it writes anything, and only replaces `build/` once the new one is
whole.

It compiles with the `elm` that npm installed in `node_modules`, or else the
one on your PATH.

## Upgrade JORN

The submodule is pinned, so a new JORN release only lands when you move it:

```bash
git -C jorn fetch origin
git -C jorn checkout <tag or commit>
node jorn/cli/jorn.mjs build && node run.mjs
git add jorn && git commit -m "Bump Jorn"
```

## Check it still works

```bash
node run.mjs
```

Runs the compiled program headless, the way a server component would: it
mounts the view, works out each filter button's path the same way the browser
patcher does, fires clicks at them, and reads the patches that come back. It
also clicks the theme toggle and checks the root class actually changed, and
clicks the active filter twice to confirm a no-op change sends zero patches.

If a path or a diff breaks, it says so here instead of the page quietly doing
nothing.

## Preview

```bash
./serve.command
```

Rebuilds when `elm` is on your PATH or in `node_modules`, then serves `build/`
on http://127.0.0.1:8080. Double-clicking it in Finder does the same.

## Deploy

Push to `main`. The `pages` workflow checks out the JORN submodule, runs
`jorn build` and `node run.mjs`, and deploys `build/` to GitHub Pages. Pull
requests get the same build and check, without the deploy.

`build/` is a static folder with no server requirements, so it can also be
uploaded anywhere by hand. Nothing in it needs API keys or fetches fonts from
anywhere.

## Rules for editing it

1. **Content lives in `src/Main.elm`, not in markup.** The lists at the top of
   the file (`metrics`, `work`, `roles`, `posts`, `podcasts`, `testimonials`,
   `tracks`) are plain data. Add a project, a role, a song there rather than
   building nodes by hand.
2. **Pages live in `src/Site.elm`.** Each page's title, description, Open Graph
   tags and JSON-LD are in `pages` there, and the sitemap is made from the same
   list. A new page is a new entry in `pages` and a new `Main.Page`.
3. **One font file, the rest system.** Big Shoulders Display (OFL, self-hosted,
   29 KB) for headlines and big figures only. `system-ui` for prose,
   `ui-monospace` for metadata, dates, statuses and labels.
4. **No dependencies.** No npm packages, no CDN, no analytics. The only
   requests the deployed page makes are its own four files.
5. **No em dashes.** Sentence breaks, colons, commas, or parentheses. This
   applies to the copy in here too.
6. **Use the element helpers.** Since Jorn v0.1, `Jorn.Element.Html` has a
   function for every HTML element, so write `Html.blockquote`, not
   `Element.element "blockquote"`. Anything that belongs to the browser rather
   than the tree (the theme on `<html>`, scrolling the testimonial strip) goes
   out as an `Effect.client` that the page script in `src/Site.elm` registers.
