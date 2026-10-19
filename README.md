# bazylhorsey.github.io

https://bazylhorsey.github.io/

My portfolio. Written in Elm, rendered by [JORN](https://github.com/bazylhorsey/jorn).

There is no HTML for the page in here. `src/Main.elm` returns a `Jorn.Element`,
Jorn sends that tree to the browser once to mount, and sends only the diff
every time state changes. `public/index.html` is a shell with one `<div>` in it.

## Layout

```
.
├── elm.json          points at the JORN submodule in jorn/src
├── jorn/             JORN, as a git submodule pinned to one commit
├── src/
│   ├── Main.elm      the home page: model, update, view, content
│   ├── Essay.elm     /writing/distracted-forward-deployed-officer/
│   └── CaseStudy.elm /writing/escapes-multiply/
├── public/           the shell, stylesheet, font, icons and crawler files
├── build.sh          elm make + collect everything into build/
├── prerender.mjs     writes each page's HTML into build/ (run by build.sh)
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
./build.sh
```

That runs `elm make --optimize` and collects the result into `build/`, copying
`client/jorn.js` from the same JORN commit into `build/vendor/`, so the Elm
side and the patcher always match.

## Upgrade JORN

The submodule is pinned, so a new JORN release only lands when you move it:

```bash
git -C jorn fetch origin
git -C jorn checkout <tag or commit>
./build.sh && node run.mjs
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

Rebuilds when `elm` is on your PATH, then serves `build/` on
http://127.0.0.1:8080. Double-clicking it in Finder does the same.

## Deploy

Push to `main`. The `pages` workflow checks out the JORN submodule, runs
`./build.sh` and `node run.mjs`, and deploys `build/` to GitHub Pages. Pull
requests get the same build and check, without the deploy.

`build/` is a static folder with no server requirements, so it can also be
uploaded anywhere by hand. Nothing in it needs API keys or fetches fonts from
anywhere.

## Rules for editing it

1. **Content lives in `src/Main.elm`, not in markup.** The lists at the top of
   the file (`metrics`, `work`, `roles`, `pieces`, `tracks`) are plain data.
   Add a project, a role, a song there rather than building nodes by hand.
2. **One font file, the rest system.** Big Shoulders Display (OFL, self-hosted,
   29 KB) for headlines and big figures only. `system-ui` for prose,
   `ui-monospace` for metadata, dates, statuses and labels.
3. **No dependencies.** No npm packages, no CDN, no analytics. The only
   requests the deployed page makes are its own four files.
4. **No em dashes.** Sentence breaks, colons, commas, or parentheses. This
   applies to the copy in here too.
5. **Use the element helpers.** Since Jorn v0.1, `Jorn.Element.Html` has a
   function for every HTML element, so write `Html.blockquote`, not
   `Element.element "blockquote"`. Anything that belongs to the browser rather
   than the tree (the theme on `<html>`, scrolling the testimonial strip) goes
   out as an `Effect.client` that the shell in `public/index.html` registers.
