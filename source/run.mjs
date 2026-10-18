// Headless check that the portfolio actually works, the same way a server
// component would run it: no DOM, no browser, just the program.
//
//   ./build.sh && node run.mjs
//
// It mounts the view, works out the path of each filter button the way the
// browser patcher does, fires a click at it, and then reads the patches Jorn
// sends back. If a path is wrong or the diff is wrong, this says so instead of
// the page quietly doing nothing.

import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const { Elm } = require("./build/build/main.js");

const app = Elm.Main.init();

const tick = () => new Promise((resolve) => setTimeout(resolve, 10));

let mounted = null;
let lastPatches = [];
let problems = 0;

// Stand in for client/jorn.js's `start`: answer each frame request at once,
// collect the patches and client effects that come back.
let lastEffects = [];

app.ports.toJorn.subscribe((message) => {
  if (message.mount) mounted = message.mount;
  if (message.frame) setTimeout(() => app.ports.fromJorn.send({ frame: true }), 0);
  if (message.patches) {
    lastPatches = message.patches;
    lastEffects = message.instructions || [];
  }
  if (message.error) {
    console.error("  FAIL app reported:", message.error);
    problems++;
  }
});

await tick();

if (!mounted) {
  console.error("nothing mounted");
  process.exit(1);
}

function textOf(node) {
  if (typeof node.text === "string") return node.text;
  return (node.children || []).map(textOf).join("");
}

// Walk the encoded tree the way client/jorn.js walks the DOM: indices into
// childNodes, text nodes included, starting at the root node itself.
function pathTo(predicate, node = mounted, path = []) {
  if (predicate(node)) return path;
  for (const [i, child] of (node.children || []).entries()) {
    const found = pathTo(predicate, child, [...path, i]);
    if (found) return found;
  }
  return null;
}

function nodeAt(path) {
  let node = mounted;
  for (const i of path) node = (node.children || [])[i];
  return node;
}

const click = (path) =>
  app.ports.fromJorn.send({ event: { path, name: "click", event: {} } });

const filterButton = (text) => (node) =>
  node.tag === "button" && (node.children || []).some((c) => c.text === text);

console.log("mounted ok");
console.log(`  ${textOf(mounted).length} characters of text on the page`);

const steps = ["upstream", "tools", "everything", "experiments"];

for (const label of steps) {
  const path = pathTo(filterButton(label));
  if (!path) {
    console.error(`  FAIL no button labelled "${label}" in the mounted tree`);
    problems++;
    continue;
  }

  lastPatches = [];
  click(path);
  await tick();

  // Which button did the patches mark active?
  const nowActive = lastPatches
    .filter(
      (p) => p.op === "set-attr" && p.name === "class" && /is-on/.test(p.value)
    )
    .map((p) => textOf(nodeAt(p.path)));

  const listChanged = lastPatches.some(
    (p) => p.op === "truncate" || p.op === "append"
  );

  const ok = nowActive.length === 1 && nowActive[0] === label;
  if (!ok) problems++;

  console.log(
    `  ${ok ? "ok  " : "FAIL"} click "${label}" at [${path}] ` +
      `-> ${String(lastPatches.length).padStart(2)} patches, ` +
      `active: ${nowActive.join(", ") || "none"}, ` +
      `work list ${listChanged ? "re-rendered" : "unchanged"}`
  );
}

// Re-selecting the current filter should be a no-op: nothing changed, so
// there is nothing to send.
lastPatches = [];
click(pathTo(filterButton("experiments")));
await tick();

const quiet = lastPatches.length === 0;
if (!quiet) problems++;
console.log(
  `  ${quiet ? "ok  " : "FAIL"} clicking the active filter again -> ` +
    `${lastPatches.length} patches`
);

// The theme toggle is different: it patches a class on the root node itself,
// which every other selector on the page hangs off.
const themeButton = pathTo(
  (node) => node.tag === "button" && /^(night|day)$/.test(textOf(node))
);

if (!themeButton) {
  console.error("  FAIL no theme toggle in the mounted tree");
  problems++;
} else {
  const before = (mounted.attrs || {}).class;
  lastPatches = [];
  click(themeButton);
  await tick();

  const rootPatch = lastPatches.find(
    (p) => p.op === "set-attr" && p.name === "class" && p.path.length === 0
  );
  const flipped = rootPatch && rootPatch.value !== before;
  if (!flipped) problems++;

  console.log(
    `  ${flipped ? "ok  " : "FAIL"} theme toggle at [${themeButton}] -> root class ` +
      `"${before}" became "${rootPatch ? rootPatch.value : "unchanged"}"`
  );
}

// The theme also has to reach <html>, and the testimonial arrows scroll a
// strip the tree doesn't own. Both leave Elm as client effects the shell
// registers, so check they go out with the right name and payload.
function expectEffect(label, path, name, payload) {
  if (!path) {
    console.error(`  FAIL no ${label} in the mounted tree`);
    problems++;
    return;
  }
  lastEffects = [];
  click(path);
  return tick().then(() => {
    const sent = lastEffects.find((e) => e.effect === "client" && e.name === name);
    const ok = sent && sent.payload === payload;
    if (!ok) problems++;
    console.log(
      `  ${ok ? "ok  " : "FAIL"} ${label} at [${path}] -> client effect ` +
        `${sent ? `${name}(${JSON.stringify(sent.payload)})` : "none"}`
    );
  });
}

const arrow = (label) => (node) =>
  node.tag === "button" && (node.attrs || {})["aria-label"] === label;

await expectEffect("theme toggle", themeButton, "theme", "paper");
await expectEffect("next testimonial", pathTo(arrow("Next")), "nudgeSaid", 1);
await expectEffect("previous testimonial", pathTo(arrow("Previous")), "nudgeSaid", -1);

console.log(problems ? `\n${problems} check(s) failed` : "\nall checks passed");
process.exit(problems ? 1 : 0);