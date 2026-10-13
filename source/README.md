# bazylhorsey.github.io

My portfolio. Written in Elm, rendered by [JORN](https://github.com/bazylhorsey/jorn).

There is no HTML for the page in here. `src/Main.elm` returns a `Jorn.Element`,
Jorn sends that tree to the browser once to mount, and sends only the diff
every time state changes. `public/index.html` is a shell with one `<div>` in it.

## Layout

```
.
├── elm.json          points at the JORN checkout in ../jorn/src
├── src/Main.elm      the entire page: model, update, view, content
├── public/           the shell and the stylesheet
│   ├── index.html
│   ├── portfolio.css
│   └── favicon.svg
├── build.sh          elm make + collect everything into build/
├── run.mjs           headless check: mounts, fires events, inspects patches
└── build/            the deployable folder (generated, committed on purpose)
```

## Build

```bash
./build.sh
```

That runs `elm make --optimize` and collects the result into `build/`, copying
`client/jorn.js` from the JORN checkout into `build/vendor/` so the deployed
folder does not depend on the clone.

JORN is not on the Elm package registry yet, so it is consumed from a local
clone. It expects to sit next to this folder. If it lives somewhere else:

```bash
JORN=~/src/jorn ./build.sh
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
python3 -m http.server -d build 8080
```

## Deploy

Upload the contents of `build/`. It is a static folder with no server
requirements: `index.html`, `portfolio.css`, `favicon.svg`, `og.png` (the link
preview image), `build/main.js` and `vendor/jorn.js`. Nothing else, no API keys, no fonts fetched from
anywhere.

It is live at https://bazylhorsey.github.io/. The `bazylhorsey.github.io`
repo holds the contents of `build/` at its root, with this source under
`source/`. Rebuild, then run `./deploy.sh` to copy the build over and push.

## Check the layout at real widths

```bash
python3 -m http.server -d build 8080
# then open http://127.0.0.1:8080/audit.html
```

`audit.html` loads the page in an offscreen iframe at 375, 768, 1280, 1600,
1920, and 2560 pixels and flags two things: text collapsed into a
one-word-per-line ribbon, and anything spilling past the viewport. Both are
easy to miss if you only ever look at one window size. `node run.mjs` covers
the Elm side, this covers the CSS side.

It caught a real one: the `::before` counter in the claims list is a grid item,
so the paragraph was wrapping back into the 4.5rem number column and rendering
as a ribbon. That only happens above 700px, where the mobile override collapses
the grid. It looked perfect in a narrow window and was broken on every desktop
browser.

## Rules for editing it

1. **Content lives in `src/Main.elm`, not in markup.** The lists at the top of
   the file (`metrics`, `work`, `roles`, `pieces`, `tracks`) are plain data.
   Add a project, a role, a song there rather than building nodes by hand.
2. **System fonts only.** `system-ui` for prose, `ui-monospace` for anything
   that is metadata, a date, a status, or a number. No font files.
3. **No dependencies.** No npm packages, no CDN, no analytics. The only
   requests the deployed page makes are its own four files.
4. **No em dashes.** Sentence breaks, colons, commas, or parentheses. This
   applies to the copy in here too.
5. **JORN is early.** `Html` covers a small set of elements, so `b`, `article`,
   `table` and friends go through `Element.element "tagname"`. Check the
   module before assuming something is exported.